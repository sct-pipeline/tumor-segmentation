#!/bin/bash
#
# Pipeline for spinal cord tumor data.
#
# Generate sc segmentation, preprocess data before training.
#
# Note: All images have .nii extension.
#
# Usage:
#   ./process_data.sh <SUBJECT_ID> <FILEPARAM>
#
# Author: Andreanne Lemay

# Uncomment for full verbose
# set -v

# Immediately exit if error
set -e

# Exit if user presses CTRL+C (Linux) or CMD+C (OSX)
trap "echo Caught Keyboard Interrupt within script. Exiting now.; exit" INT

# Retrieve input params
SUBJECT=$1
FILEPARAM=$2


# FUNCTIONS 
# ==============================================================================

# Crop image around spinal cord
crop_image_around_sc(){
  local file="$1"
	local contrast="$2"
	sct_get_centerline -i ${file}.nii.gz -c ${contrast}
	sct_create_mask -i ${file}.nii.gz -p centerline,${file}_centerline.nii.gz -o mask_${file}.nii.gz -size 40
	sct_crop_image -i ${file}.nii.gz -m mask_${file}.nii.gz -o ${file}.nii.gz
}

# SCRIPT STARTS HERE
# ==============================================================================
source $FILEPARAM
# Go to results folder, where most of the outputs will be located
cd $PATH_RESULTS
# Copy source images
mkdir -p data
cd data
cp -r $PATH_DATA/$SUBJECT .
cp -r $PATH_DATA/derivatives .
# Go to data folder
cd $SUBJECT/anat/
# Setup file names
file_t2w=${SUBJECT}_T2w
file_t1w=${SUBJECT}_T1w

crop_image_around_sc $file_t1w t1
crop_image_around_sc $file_t2w t2

rm -r tmp

cd $PATH_DATA/derivatives/labels/$SUBJECT/anat/

file_t2w=${SUBJECT}_T2w_seg-tumor
file_t1w=${SUBJECT}_T1w_seg-tumor

crop_image_around_sc $file_t1w t1
crop_image_around_sc $file_t2w t2



rm -r tmp

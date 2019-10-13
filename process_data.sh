#!/bin/bash
#
# Pipeline for spinal cord tumor data.
#
# Generate sc segmentation, preprocess data before training.
#
# Note: All images have .nii extension.
#
# Usage:
#   sct_run_batch <FILEPARAM> process_data.sh
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

# SCRIPT STARTS HERE
# ==============================================================================
source $FILEPARAM
# Go to results folder, where most of the outputs will be located
cd $PATH_RESULTS
# Copy source images and segmentations
mkdir -p data/derivatives/labels
cd data

cp -r $PATH_DATA/$SUBJECT .
cp -r $PATH_DATA/derivatives/labels/$SUBJECT $PATH_RESULTS/data/derivatives/labels
# Go to data folder
cd $SUBJECT/anat/
# Setup file names
file_t2w=${SUBJECT}_T2w
file_t1w=${SUBJECT}_T1w

sct_get_centerline -i ${file_t2w}.nii.gz -c t2
sct_create_mask -i ${file_t2w}.nii.gz -p centerline,${file_t2w}_centerline.nii.gz -o mask_${file_t2w}.nii.gz
file_mask=`pwd`/mask_${file_t2w}.nii.gz
sct_crop_image -i ${file_t1w}.nii.gz -m ${file_mask} -o ${file_t1w}.nii.gz
sct_crop_image -i ${file_t2w}.nii.gz -m ${file_mask} -o ${file_t2w}.nii.gz

cd $PATH_RESULTS/data/derivatives/labels/$SUBJECT/anat/

file_t2w_seg=${SUBJECT}_T2w_seg-tumor
file_t1w_seg=${SUBJECT}_T1w_seg-tumor

sct_crop_image -i ${file_t1w_seg}.nii.gz -m ${file_mask} -o ${file_t1w_seg}.nii.gz
sct_crop_image -i ${file_t2w_seg}.nii.gz -m ${file_mask} -o ${file_t2w_seg}.nii.gz

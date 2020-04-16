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
# shellcheck disable=SC1090
source $FILEPARAM
# Go to results folder, where most of the outputs will be located
cd $PATH_RESULTS
# Copy source images and segmentations
mkdir -p data/derivatives/labels
cd data

cp -r $PATH_DATA/$SUBJECT .
cp -r $PATH_DATA/derivatives/labels/$SUBJECT $PATH_RESULTS/data/derivatives/labels

# Go to data folder
cd $PATH_RESULTS/data/$SUBJECT/anat/
## Setup file names
file_t2w=${SUBJECT}_T2w
file_t1w=${SUBJECT}_T1w

path_t1w=`pwd`/${file_t1w}.nii.gz

# Oversample to avoid losing slice info when cropping
sct_resample -i ${file_t2w}.nii.gz -vox 512x512x100 -x spline -o ${file_t2w}.nii.gz;

sct_get_centerline -i ${file_t2w}.nii.gz -c t2;
sct_create_mask -i ${file_t2w}.nii.gz -p centerline,${file_t2w}_centerline.nii.gz;
sct_crop_image -i ${file_t2w}.nii.gz -m mask_${file_t2w}.nii.gz -o ${file_t2w}.nii.gz;
cropped_img=`pwd`/${file_t2w}.nii.gz;


if [ -f ${path_t1w} ]; then
  sct_resample -i ${file_t1w}.nii.gz -vox 512x512x100 -x spline -o ${file_t1w}.nii.gz;
  sct_crop_image -i ${file_t1w}.nii.gz -ref ${cropped_img} -o ${file_t1w}.nii.gz;
  sct_resample -i ${file_t1w}.nii.gz -vox 96x512x16 -x spline -o ${file_t1w}.nii.gz;
fi

cd $PATH_RESULTS/data/derivatives/labels/$SUBJECT/anat/

file_t2w_seg=${SUBJECT}_T2w_seg-tumor
file_t1w_seg=${SUBJECT}_T1w_seg-tumor

if [ -f ${path_t1w} ]; then
  sct_resample -i ${file_t1w_seg}.nii.gz -vox 512x512x100 -x linear -o ${file_t1w_seg}.nii.gz;
  sct_crop_image -i ${file_t1w_seg}.nii.gz -ref ${cropped_img} -o ${file_t1w_seg}.nii.gz;
  sct_resample -i ${file_t1w_seg}.nii.gz -vox 96x512x16 -x linear -o ${file_t1w_seg}.nii.gz;
  sct_maths -i ${file_t1w_seg}.nii.gz -o ${file_t1w_seg}.nii.gz -bin 0.9
  sct_image -i ${file_t1w_seg}.nii.gz -setorient AIL;
fi

sct_resample -i ${file_t2w_seg}.nii.gz -vox 512x512x100 -x linear -o ${file_t2w_seg}.nii.gz;
sct_crop_image -i ${file_t2w_seg}.nii.gz -ref ${cropped_img} -o ${file_t2w_seg}.nii.gz;
sct_resample -i ${file_t2w_seg}.nii.gz -vox 96x512x16 -x linear -o ${file_t2w_seg}.nii.gz;
sct_maths -i ${file_t2w_seg}.nii.gz -o ${file_t2w_seg}.nii.gz -bin 0.9;
sct_image -i ${file_t2w_seg}.nii.gz -setorient AIL;

cd $PATH_RESULTS/data/$SUBJECT/anat/
sct_resample -i ${file_t2w}.nii.gz -vox 96x512x16 -x spline -o ${file_t2w}.nii.gz;
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

# Go to data labels folder
cd $PATH_RESULTS/data/derivatives/labels/$SUBJECT/anat/

file_t2w_seg=${SUBJECT}_T2w_seg-tumor
file_t1w_seg=${SUBJECT}_T1w_seg-tumor
file_t1w_edema=${SUBJECT}_T1w_edema
file_t1w_cavity=${SUBJECT}_T1w_cavity
file_t2w_edema=${SUBJECT}_T2w_edema
file_t2w_cavity=${SUBJECT}_T2w_cavity

sct_maths -i ${file_t2w_seg}.nii.gz -o ${file_t2w_seg}.nii.gz -bin 0.9;
sct_image -i ${file_t2w_seg}.nii.gz -setorient AIL;

sct_maths -i ${file_t1w_seg}.nii.gz -o ${file_t1w_seg}.nii.gz -bin 0.9;
sct_image -i ${file_t1w_seg}.nii.gz -setorient AIL;

path_edema=`pwd`/${file_t1w_edema}.nii.gz
if [ -f ${path_edema} ]; then
  sct_maths -i ${file_t2w_seg}.nii.gz -o ${file_t2w_seg}.nii.gz -bin 0.9;
  sct_image -i ${file_t2w_seg}.nii.gz -setorient AIL;

  sct_maths -i ${file_t1w_seg}.nii.gz -o ${file_t1w_seg}.nii.gz -bin 0.9;
  sct_image -i ${file_t1w_seg}.nii.gz -setorient AIL;

  sct_maths -i ${file_t2w_seg}.nii.gz -o ${file_t2w_seg}.nii.gz -add ${file_t2w_edema}.nii.gz;
  sct_maths -i ${file_t1w_edema}.nii.gz -o ${file_t1w_edema}.nii.gz -add ${file_t1w_edema}.nii.gz;
fi

path_cavity=`pwd`/${file_t1w_cavity}.nii.gz
if [ -f ${path_cavity} ]; then
  sct_maths -i ${file_t2w_seg}.nii.gz -o ${file_t2w_seg}.nii.gz -bin 0.9;
  sct_image -i ${file_t2w_seg}.nii.gz -setorient AIL;

  sct_maths -i ${file_t1w_seg}.nii.gz -o ${file_t1w_seg}.nii.gz -bin 0.9;
  sct_image -i ${file_t1w_seg}.nii.gz -setorient AIL;

  sct_maths -i ${file_t2w_seg}.nii.gz -o ${file_t2w_seg}.nii.gz -add ${file_t2w_cavity}.nii.gz;
  sct_maths -i ${file_t1w_seg}.nii.gz -o ${file_t1w_seg}.nii.gz -add ${file_t1w_cavity}.nii.gz;
fi

sct_maths -i ${file_t2w_seg}.nii.gz -o ${file_t2w_seg}.nii.gz -bin 0.9;
sct_maths -i ${file_t1w_seg}.nii.gz -o ${file_t1w_seg}.nii.gz -bin 0.9;

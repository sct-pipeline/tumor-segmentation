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

if [ -f ${path_t1w} ]; then
  sct_register_multimodal -i ${file_t1w}.nii.gz -d ${file_t2w}.nii.gz -x spline
  mv ${file_t2w}_reg.nii.gz ${file_t2w}.nii.gz
  mv ${file_t1w}_reg.nii.gz ${file_t1w}.nii.gz
  warp_T2w2T1w=`pwd`/warp_${file_t2w}2${file_t1w}.nii.gz
  warp_T1w2T2w=`pwd`/warp_${file_t1w}2${file_t2w}.nii.gz
fi

cd $PATH_RESULTS/data/derivatives/labels/$SUBJECT/anat/

file_t2w_seg=${SUBJECT}_T2w_seg-tumor
file_t1w_seg=${SUBJECT}_T1w_seg-tumor

if [ -f ${path_t1w} ]; then
  sct_apply_transfo -i ${file_t1w_seg}.nii.gz -d ${file_t2w_seg}.nii.gz -w ${warp_T1w2T2w} -o ${file_t1w_seg}.nii.gz -x linear
  sct_apply_transfo -i ${file_t2w_seg}.nii.gz -d ${file_t1w_seg}.nii.gz -w ${warp_T2w2T1w} -o ${file_t2w_seg}.nii.gz -x linear
fi
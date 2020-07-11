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
#FILEPARAM=$2

# SCRIPT STARTS HERE
# ==============================================================================
# shellcheck disable=SC1090
#source $FILEPARAM
# Go to results folder, where most of the outputs will be located
cd $PATH_RESULTS;
# Copy source images and segmentations
mkdir -p data/derivatives/labels;
cd data;

cp -r $PATH_DATA/$SUBJECT .;
cp -r $PATH_DATA/derivatives/labels/$SUBJECT $PATH_RESULTS/data/derivatives/labels;

# Go to data folder
cd $PATH_RESULTS/data/$SUBJECT/anat/;
## Setup file names
file_t2w=${SUBJECT}_T2w;
file_t1w=${SUBJECT}_T1w;
path_t1w=`pwd`/${file_t1w}.nii.gz;

if [ -f ${path_t1w} ]; then
  sct_resample -i ${file_t1w}.nii.gz -mm 0.5x0.5x2 -o ${file_t1w}.nii.gz;
  sct_resample -i ${file_t2w}.nii.gz -mm 0.5x0.5x2 -o ${file_t2w}.nii.gz;
  sct_register_multimodal -i ${file_t1w}.nii.gz -d ${file_t2w}.nii.gz -m $PATH_RESULTS/data/derivatives/labels/$SUBJECT/anat/${file_t2w}_sc-mask.nii.gz -param step=1,type=im,algo=affine,metric=CC;

  mv ${file_t1w}_reg.nii.gz ${file_t1w}.nii.gz;
  rm ${file_t2w}_reg.nii.gz
  rm warp_${file_t2w}2${file_t1w}.nii.gz;
  rm warp_${file_t1w}2${file_t2w}.nii.gz;
fi

cd $PATH_RESULTS/data/derivatives/labels/$SUBJECT/anat/;

file_t2w_seg=${SUBJECT}_T2w_seg-tumor;
file_t1w_seg=${SUBJECT}_T1w_seg-tumor;
file_t2w_edema=${SUBJECT}_T2w_edema;
file_t1w_edema=${SUBJECT}_T1w_edema;
file_t1w_mask=${SUBJECT}_T1w_sc-mask;
file_t2w_mask=${SUBJECT}_T2w_sc-mask;
file_t1w_centerline=${SUBJECT}_T1w_centerline;
file_t2w_centerline=${SUBJECT}_T2w_centerline;
path_edema=`pwd`/${file_t2w_edema}.nii.gz;

if [ -f ${path_t1w} ]; then
  sct_resample -i ${file_t2w_seg}.nii.gz -mm 0.5x0.5x2 -o ${file_t2w_seg}.nii.gz;
  sct_resample -i ${file_t1w_seg}.nii.gz -mm 0.5x0.5x2 -o ${file_t1w_seg}.nii.gz;
  sct_resample -i ${file_t2w_mask}.nii.gz -mm 0.5x0.5x2 -o ${file_t2w_mask}.nii.gz;
  sct_resample -i ${file_t1w_mask}.nii.gz -mm 0.5x0.5x2 -o ${file_t1w_mask}.nii.gz;
  sct_resample -i ${file_t2w_centerline}.nii.gz -mm 0.5x0.5x2 -o ${file_t2w_centerline}.nii.gz;
  sct_resample -i ${file_t1w_centerline}.nii.gz -mm 0.5x0.5x2 -o ${file_t1w_centerline}.nii.gz;
  if [ -f ${path_edema} ]; then
      sct_resample -i ${file_t2w_edema}.nii.gz -mm 0.5x0.5x2 -o ${file_t2w_edema}.nii.gz;
      sct_resample -i ${file_t1w_edema}.nii.gz -mm 0.5x0.5x2 -o ${file_t1w_edema}.nii.gz;
  fi
fi

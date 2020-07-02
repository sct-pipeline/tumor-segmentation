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
#  sct_resample -i ${file_t1w}.nii.gz -mm 0.2x0.2x0.5 -o ${file_t1w}.nii.gz;
#  sct_resample -i ${file_t2w}.nii.gz -mm 0.2x0.2x0.5 -o ${file_t2w}.nii.gz;
#  sct_crop_image -i ${file_t1w}.nii.gz -ref ${file_t2w}.nii.gz -o ${file_t1w}.nii.gz;
#  sct_resample -i ${file_t1w}.nii.gz -mm 0.5x0.5x2 -o ${file_t1w}.nii.gz;
#  sct_resample -i ${file_t2w}.nii.gz -mm 0.5x0.5x2 -o ${file_t2w}.nii.gz;
#  sct_resample -i ${path_mask}${file_t2w}_centerline.nii.gz -mm 0.5x0.5x2 -o ${path_mask}${file_t2w}_centerline.nii.gz;
  # step below to improve with dedicated optic model
  sct_get_centerline -i ${file_t1w}.nii.gz -c t1 -method optic;
  sct_create_mask -i ${file_t1w}.nii.gz -size 30mm -f cylinder -p centerline,${file_t1w}_centerline.nii.gz -o mask.nii.gz;
#  sct_crop_image -i ${file_t1w}.nii.gz -m mask.nii.gz -o ${file_t1w}.nii.gz;
#  sct_crop_image -i ${file_t2w}.nii.gz -m mask.nii.gz -o ${file_t2w}.nii.gz;
  sct_register_multimodal -i ${file_t1w}.nii.gz -d ${file_t2w}.nii.gz -m mask.nii.gz -param step=1,type=im,algo=slicereg,metric=CC;
#
  mv ${file_t2w}_reg.nii.gz ${file_t2w}.nii.gz;
  mv ${file_t1w}_reg.nii.gz ${file_t1w}.nii.gz;
  warp_T2w2T1w=`pwd`/warp_${file_t2w}2${file_t1w}.nii.gz;
  warp_T1w2T2w=`pwd`/warp_${file_t1w}2${file_t2w}.nii.gz;
fi

cd $PATH_RESULTS/data/derivatives/labels/$SUBJECT/anat/;

file_t2w_seg=${SUBJECT}_T2w_seg-tumor;
file_t1w_seg=${SUBJECT}_T1w_seg-tumor;
file_t2w_edema=${SUBJECT}_T2w_edema;
file_t1w_edema=${SUBJECT}_T1w_edema;
path_edema=`pwd`/${file_t2w_edema}.nii.gz;

if [ -f ${path_t1w} ]; then
#  sct_resample -i ${file_t1w_seg}.nii.gz -mm 0.2x0.2x0.5 -o ${file_t1w_seg}.nii.gz;
#  sct_crop_image -i ${file_t1w_seg}.nii.gz -ref $PATH_RESULTS/data/$SUBJECT/anat/${file_t2w}.nii.gz -o ${file_t1w_seg}.nii.gz;
#  sct_resample -i ${file_t2w_seg}.nii.gz -mm 0.2x0.2x0.5 -o ${file_t2w_seg}.nii.gz;
#  sct_crop_image -i ${file_t2w_seg}.nii.gz -ref $PATH_RESULTS/data/$SUBJECT/anat/${file_t2w}.nii.gz -o ${file_t2w_seg}.nii.gz;
#  sct_resample -i ${file_t2w_seg}.nii.gz -mm 0.5x0.5x2 -o ${file_t2w_seg}.nii.gz;
#  sct_resample -i ${file_t1w_seg}.nii.gz -mm 0.5x0.5x2 -o ${file_t1w_seg}.nii.gz;
  sct_apply_transfo -i ${file_t1w_seg}.nii.gz -d ${file_t2w_seg}.nii.gz -w ${warp_T1w2T2w} -o ${file_t1w_seg}.nii.gz -x linear;
  sct_apply_transfo -i ${file_t2w_seg}.nii.gz -d ${file_t1w_seg}.nii.gz -w ${warp_T2w2T1w} -o ${file_t2w_seg}.nii.gz -x linear;
  if [ -f ${path_edema} ]; then
      sct_apply_transfo -i ${file_t1w_edema}.nii.gz -d ${file_t2w_edema}.nii.gz -w ${warp_T1w2T2w} -o ${file_t1w_edema}.nii.gz -x linear;
      sct_apply_transfo -i ${file_t2w_edema}.nii.gz -d ${file_t1w_edema}.nii.gz -w ${warp_T2w2T1w} -o ${file_t2w_edema}.nii.gz -x linear;
#      sct_resample -i ${file_t2w_edema}.nii.gz -mm 0.5x0.5x2 -o ${file_t2w_edema}.nii.gz;
#      sct_resample -i ${file_t1w_edema}.nii.gz -mm 0.5x0.5x2 -o ${file_t1w_edema}.nii.gz;
  fi
fi

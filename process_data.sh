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


# FUNCTIONS - Unused for now
# ==============================================================================

# Check if manual label already exists. If it does, copy it locally. If it does
# not, perform labeling.
label_if_does_not_exist(){
  local file="$1"
  local file_seg="$2"
  # Update global variable with segmentation file name
  FILELABEL="${file}_labels"
  if [ -e "${PATH_SEGMANUAL}/${file}_labels-manual.nii" ]; then
    echo "Found manual label: ${PATH_SEGMANUAL}/${file}_labels-manual.nii"
    rsync -avzh "${PATH_SEGMANUAL}/${file}_labels-manual.nii" ${FILELABEL}.nii
  else
    # Generate labeled segmentation
    sct_label_vertebrae -i ${file}.nii -s ${file_seg}.nii -c t1 -qc ${PATH_QC} -qc-subject ${SUBJECT}
    # Create labels in the cord at C2 and C3 mid-vertebral levels
    sct_label_utils -i ${file_seg}_labeled.nii -vert-body 2,3 -o ${FILELABEL}.nii
  fi
}

# Check if manual segmentation already exists. If it does, copy it locally. If
# it does not, perform seg.
segment_if_does_not_exist(){
  local file="$1"
  local contrast="$2"
  # Update global variable with segmentation file name
  FILESEG="${file}_seg"
  if [ -e "${PATH_SEGMANUAL}/${FILESEG}-manual.nii" ]; then
    echo "Found manual segmentation: ${PATH_SEGMANUAL}/${FILESEG}-manual.nii"
    rsync -avzh "${PATH_SEGMANUAL}/${FILESEG}-manual.nii" ${FILESEG}.nii
    sct_qc -i ${file}.nii -s ${FILESEG}.nii -p sct_deepseg_sc -qc ${PATH_QC} -qc-subject ${SUBJECT}
  else
    # Segment spinal cord
    sct_deepseg_sc -i ${file}.nii -c $contrast -qc ${PATH_QC} -qc-subject ${SUBJECT}
  fi
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
# Go to data folder
cd $SUBJECT/anat/
# Setup file names
file_t2w=${SUBJECT}_T2w.nii.gz
file_t1w=${SUBJECT}_T1w.nii.gz

sct_deepseg_sc -i ${file_t1w} -c t1 -qc ${PATH_QC} -qc-subject ${SUBJECT}
sct_deepseg_sc -i ${file_t2w} -c t2 -qc ${PATH_QC} -qc-subject ${SUBJECT}

cd ../manual_label

# Setup file names
file_t2w_lesion_seg=${SUBJECT}_T2_manual_lesion_label.nii.gz
file_t1w_lesion_seg=${SUBJECT}_T1_manual_lesion_label.nii.gz

# Segmentations are different for T1w and T2w images, union of both segmentation is created

sct_maths -i ${file_t2w_lesion_seg} -add ${file_t1w_lesion_seg} -o tmp.nii.gz
sct_maths -i tmp.nii.gz -otsu 1 -o ${SUBJECT}_lesion_label.nii.gz
rm tmp.nii.gz



#
#   Script to move tumor segmentation files to respect BIDS standards
#

import os
import shutil

BIDS_PATHS = ['/usr/Spine_Cord_Data/Tumor/Astrocytoma_144_BIDS',
              '/usr/Spine_Cord_Data/Tumor/Ependymoma_393_BIDS',
              '/usr/Spine_Cord_Data/Tumor/Hemandioblastoma_264_BIDS']

for BIDS_PATH in BIDS_PATHS:
    NEW_LABELS_PATH = os.path.join(BIDS_PATH, 'derivatives', 'labels')
    subjects = os.listdir(BIDS_PATH)
    for subject in subjects:
        # Only select subject folders
        if 'sub' in subject:
            NEW_SUBJECT_SEG_PATH = os.path.join(NEW_LABELS_PATH, subject, 'anat')
            if not os.path.exists(NEW_SUBJECT_SEG_PATH):
                # Create directory
                os.makedirs(NEW_SUBJECT_SEG_PATH)
            PATH_TO_SUBJECT = os.path.join(BIDS_PATH, subject, 'manual_label')
            files = os.listdir(PATH_TO_SUBJECT)
            for file in files:
                PATH_TO_SEG = os.path.join(PATH_TO_SUBJECT, file)
                NEW_PATH_TO_SEG = os.path.join(NEW_SUBJECT_SEG_PATH, file)
                if os.path.exists(PATH_TO_SEG):
                    # Move the tumor segmentation file
                    shutil.move(PATH_TO_SEG, NEW_PATH_TO_SEG)
            # Remove empty folder 'manual label'
            os.rmdir(PATH_TO_SUBJECT)

from __future__ import print_function

import nibabel as nib
import numpy as np
from torch import nn
from bids_neuropoly import bids
from spinalcordtoolbox.image import Image
from shutil import copyfile
import os
from ivadomed.transforms import CenterCrop

class DiceLoss(nn.Module):
    """DiceLoss.

    .. seealso::
        Milletari, Fausto, Nassir Navab, and Seyed-Ahmad Ahmadi. "V-net: Fully convolutional neural networks for
        volumetric medical image segmentation." 2016 fourth international conference on 3D vision (3DV). IEEE, 2016.

    Args:
        smooth (float): Value to avoid division by zero when images and predictions are empty.

    Attributes:
        smooth (float): Value to avoid division by zero when images and predictions are empty.
    """
    def __init__(self, smooth=1.0):
        super(DiceLoss, self).__init__()
        self.smooth = smooth

    def forward(self, prediction, target):
        iflat = prediction.reshape(-1)
        tflat = target.reshape(-1)
        intersection = (iflat * tflat).sum()

        return - (2.0 * intersection + self.smooth) / (iflat.sum() + tflat.sum() + self.smooth)

# rootDataPath = "/home/andreanne/Documents/dataset/tumor_segmentation_masks/results/data"
rootDataPath = "/home/andreanne/Documents/dataset/tumor_segmentation_new_edema/results/data"
bids_ds = bids.BIDS(rootDataPath)
df = bids.BIDS(rootDataPath).participants.content
subject_lst = df['participant_id'].tolist()
contrast_lst = ["T2w"]
bids_subjects = [s for s in bids_ds.get_subjects() if s.record["subject_id"] in subject_lst]
max_dim = 0
filename = 0
dice_sum = 0
counter = 0
dirty = 0
h_ = 0
w_ = 0
d_ = 0

for s in subject_lst:
    img_shape = None
    for subject in bids_subjects:
        files = []
        if subject.record["subject_id"] == s:
            if subject.record["modality"] in ["T2w"]:
                input_file = subject.record.absolute_path
                files.append(input_file)
                files.append(input_file.replace("T2w", "T1w"))
                derivatives = subject.get_derivatives("labels")
                for deriv in derivatives:
                    if deriv.endswith(subject.record["modality"] + "_edema.nii.gz") or deriv.endswith(subject.record["modality"] + "_seg-tumor.nii.gz"):
                        files.append(deriv)
                        files.append(deriv.replace("T2w", "T1w"))
                data = []
                for file in files:
                    if os.path.exists(file):
                        input_nii = nib.load(file)
                        data.append(input_nii.get_fdata().shape)

                if len(set(data)) != 1:
                    # print(files[0])
                    transform = CenterCrop(size=data[0])
                    for i in files:
                        if os.path.exists(i):
                            img_nii = nib.load(i)
                            img = img_nii.get_fdata()
                            cropped, _ = transform(img, {'crop_params': {}})
                            print(cropped.shape)
                            nib_image = nib.Nifti1Image(cropped, img_nii.affine)
                            nib.save(nib_image, i)


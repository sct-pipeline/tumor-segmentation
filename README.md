# tumor-segmentation

Pipeline for the segmentation of spinal tumors

## Data
The data needs to be organized according to the [BIDS](http://bids.neuroimaging.io/) convention, as shown below:

~~~
data/
└── dataset_description.json
└── participants.tsv
└── sub-001
    └── anat
        └── sub-amu01_T1w.nii.gz
        └── sub-amu01_T1w.json
        └── sub-amu01_T2w.nii.gz
        └── sub-amu01_T2w.json
└── derivatives
    └── labels
        └── sub-001
            └── anat
                └── sub-001_T1w_seg-tumor.nii.gz --> Tumor segmentation
~~~

More information for converting and organizing BIDS data is available [here](https://spine-generic.readthedocs.io/en/latest/documentation.html#data-conversion-dicom-to-bids).

## Code

Coming soon.

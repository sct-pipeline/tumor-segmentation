# tumor-segmentation

Pipeline for the segmentation of spinal tumors

## Data
The data is organized according to the [BIDS](http://bids.neuroimaging.io/) convention, as shown below:

~~~
Tumor_BIDS/
└── dataset_description.json
└── participants.tsv
└── sub-Astr144
    └── anat
        └── sub-Astr144_T1w.nii.gz
        └── sub-Astr144_T1w.json
        └── sub-Astr144_T2w.nii.gz
        └── sub-Astr144_T2w.json
└── sub-Hema264
└── sub-Epen393
└── derivatives
    └── labels
        └── sub-Astr144
            └── anat
                └── sub-Astr144_T1w_seg-tumor.nii.gz --> Tumor segmentation
~~~

The prefixes 'Astr', 'Epen' and 'Hema' respectively correspond to the tumor types Astrocytoma, Ependymoma and Hemangioblastoma. The subject numbers for 'Astr' subjects go from 144 to 263, for 'Hema' subjects from 264 to 392 and for 'Epen' subjects from 393 to 523.

More information for converting and organizing BIDS data is available [here](https://spine-generic.readthedocs.io/en/latest/documentation.html#data-conversion-dicom-to-bids).

## Preprocessing Data
Currently, the preprocessing script crops the images around the spinal cord.

To prepare the data for training, run the following line ```sct_run_batch parameters/parameters.sh process_data.sh``` . This will process the BIDS repository specified in the parameters.sh file. Modify the parameters file if needed to select the images to be processed.

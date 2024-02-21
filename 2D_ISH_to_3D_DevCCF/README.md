# Registering ADMBA ISH Gene Expression to DevCCF
Code for aligning 2D Allen Developing Mouse Brain Altas (AMDBA) ISH datasets to the Developmental Mouse Brain Common Coordinate Framework (DevCCF) in **Kronman et al. (doi: 10.1101/2023.09.14.557789)**

## Overall Description
This set of scripts:
1. Builds 3D specimen level brain datasets from 2D ADMBA experiment level ISH raw data and analyzed expression data. (`1_SectionNExpression.py`)
2. Extracts individual gene expression from each set of expression data (`2_ExtractGenes.py`)
3. Resamples the data to a standard 512x512 resoltion in the sectioning plane for computational stability (`3_ResampleData.py`)
4. Uses deep learning to from the ANTsPyNet to create brain masks (`4_mask_image.py`)
5. Aligns the raw section data and individual 3D gene expression profiles to age-matched DevCCF templates (`5_process_data_bspline_full_dataset`)

Additional details can be found in the [DevCCF manuscript](https://kimlab.io/brain-map/DevCCF/)
## Python Dependencies
- pandas
- itk
- SimpleITK
- os
- sys
- json
- argparse
- logging
- numpy
- antspyx
- antspynet
- numpy
- shutil
- glob
- time
- tempfile
- datetime

This has been testing with python 3.9 and 3.10



---
---
---

# Preprocessing & Registration Protocol: 

## Step 1: SectionNExpression
`1_SectionNExpression.py` is a function that builds 3D specimen volumes from 2D Allen Developing Mouse Brain Altas ISH datasets. It generates volumes for raw section data and calculated gene expression data of each specimen. Initial alignment is aided by template data stored in `atlas_metadata.json`. Missing sections are filled with zeros


#### **Example Call**
> python SectionNExpression.py -p /project/picsl/jtduda/data/Allen/DevCCF/dev_markers_batch_v2/ -a /project/picsl/jtduda/data/Allen/DevCCF/atlas_models/ -o /project/picsl/jtduda/data/Allen/DevCCF/subjects_corrected_v2/

-p = directory should contain a file called "section_datasets_metadata.csv" and subdirs for all datasets
     each subdir should have an alignment json, a metadata json and directores called "expression_images" and "section_images"

-a = directory should contain a file called "atlas_metadata.json" and subdirs for all atlases (e.g. E11.5, etc)

-o = where output will be stored

See help call for additional information



## Step 2: Extract Genes
`2_ExtractGenes.py` is a function that generates 3D gene expression profiles for each experimental ISH expression data experiment. It pulls only files of the same gene from the 3D expression profiles and sets all other sections to zero.

#### **Example Call**
> python 2_SectionNExpression.py -i /path/to/gene/expresson/maps -m /path/to/metadata/csv/ -o /output/directory

See help call for additional information


## Step 3: ResampleData
`3_ResampleData.py` is a script that takes a list of input images and resamples them to 512 x 512 in the imaging plane, then saves them to a new directory. For the DevCCF, `1_SectionNExpression.py` output 3D volumes were resampled.

## Step 4: Create Brain Masks
`4_mask_image.py` is can be run as a script or function that uses the antspynet library to apply deep learning to create brain masks from the raw section data in the previous step. For in skull datasets, the brain mask separates the brain from the skull using: `antspynet.allen_ex5_brain_extraction`. For brain only datasets, the brain mask separates the brain from surrounding environment using `antspynet.allen_histology_brain_mask`. These masks are used to aid registration in the next step.

This function needs only the location of the resampled section data. See help call for additional information.


## Step 5: Process Data with Bspline Interpolation
`5_process_data_bspline_full_dataset` is a script that uses the resampled section data and masks to align each sample level dataset and individual gene expresesion dataset with age matched DevCCF morphology using the following steps:

  1. **Initial Linear Multimetric Registration:**
     - Perform initial alignment using linear multimetric registration from DevCCF MRI templates (FA and ADC contrasts) to the reconstructed histological sample volume.

  2. **Slice-Wise Correction:**
     - Correct the 3D sample reconstruction slice by slice.
     - Utilize nonlinear multimetric registration of each sample section to the neighboring experimental section and the aligned MRI template section mask.

  3. **Refinement of Template-to-Subject Alignment:**
     - Refine the template-to-subject alignment by nonlinearly registering the age-matched MRI templates to the slice-wise corrected sample reconstruction.

  4. **Warping of Gene Expression Volumes:**
     - Apply B-spline approximation to fill analyzed gene expression volumes for each individual experiment.
     - Warp gene expression volumes to DevCCF morphology using saved transform parameters from sample slice-wise correction and inverse transform parameters from refined template-to-subject alignment.

  5. **Registration Method Details:**
     - All registrations utilize the ANTsPy `antsRegistrationSyNQuick` transform type.
     - Mutual information similarity metric is used for most registrations, except for slice-wise correction using the MRI mask, which employs the mean squared difference similarity metric.


---
---
---
## Disclaimer:
* This script is provided as-is and may require customization to suit specific use cases. There are many hardcoded paths and values that are optimized for our datasets. You may need to modify some values to optimize for your data. Users are encouraged to review and modify the script as needed for their research projects.

# DevCCF Code Release

This Repository contains a partial set of in house code used in creating the Developmental Mouse Brain Common Coordinate Framework (DevCCF) in Kronman et al. (doi: 10.1101/2023.09.14.557789). This incluses the following projects, each with it's own detailed ReadMe file.

- **Create_Template**:  
  - Code used to generate the Developmental Mouse Brain Common Coordinate Framework (DevCCF) templates using Advanced Normalization Tools (ANTs) `antsMultivariateTemplateConstruction2.sh`.
- **Multimodal_Registration**
  - Facilitates the registration of multimodal brain imaging data using the ANTs software (`antsRegistration`) by aligning 3D template landmarks
- **2D ISH to 3D DevCCF**
  - Code for aligning 2D Allen Developing Mouse Brain Altas (AMDBA) ISH datasets to the DevCCF
- [**LSFM Image Stitcher**](https://github.com/yongsookimlab/LSFM_Image_Stitcher) *(Link goes to repository)*
  - This code is designed to stitch together images taken by light sheet fluorescence microscopy (LSFM) using SmartSPIM (product of LifeCanvas Technologies). It takes raw TIF (.tif) files from the SmartSPIM system and stitches them together based on the best cross matching coordinates. The code calls on ImageJ for image processing.
- [**DevCCF to CCFv3 mapping for Figure 5**](https://github.com/AllenInstitute/DevCCF_CCFv3_mapping) *(Link goes to repository)*
  - Code for generating analyses for Figure 5 mapping DevCCF and CCFv3 annotations to one another.

## Disclaimer:
* This script is provided as-is and may require customization to suit specific use cases. There are many hardcoded paths and values that are optimized for our datasets. You may need to modify some values to optimize for your data. Users are encouraged to review and modify the script as needed for their research projects.
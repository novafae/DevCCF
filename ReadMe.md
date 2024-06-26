# Developmental Mouse Brain Common Coordinate Framework (DevCCF) Code Release

This Repository contains a partial set of in house code used in creating the Developmental Mouse Brain Common Coordinate Framework (DevCCF) in Kronman et al. (doi: 10.1101/2023.09.14.557789). This incluses the following projects, each with it's own detailed ReadMe file.

- **Create_Template**:  
  - Code used to generate the Developmental Mouse Brain Common Coordinate Framework (DevCCF) templates using Advanced Normalization Tools (ANTs) `antsMultivariateTemplateConstruction2.sh`.
- **Multimodal_Registration**
  - Facilitates the registration of multimodal brain imaging data using the ANTs software (`antsRegistration`) by aligning 3D template landmarks
- **2D ISH to 3D DevCCF**
  - Code for aligning 2D Allen Developing Mouse Brain Altas (AMDBA) ISH datasets to the DevCCF
- **LSFM Image Stitcher**
  - This code is designed to stitch together images taken by light sheet fluorescence microscopy (LSFM) using SmartSPIM (product of LifeCanvas Technologies). It takes raw TIF (.tif) files from the SmartSPIM system and stitches them together based on the best cross matching coordinates. The code calls on ImageJ for image processing.
  - See `20220331_YTW_BetterStitcher` Folder
- [**DevCCF to CCFv3 mapping for Figure 5**](https://github.com/AllenInstitute/DevCCF_CCFv3_mapping) *(Link goes to repository)*
  - Code for generating analyses for Figure 5 mapping DevCCF and CCFv3 annotations to one another.



## Disclaimer:
* This script is provided as-is and may require customization to suit specific use cases. There are many hardcoded paths and values that are optimized for our datasets. You may need to modify some values to optimize for your data. Users are encouraged to review and modify the script as needed for their research projects.



## License
Shield: [![CC BY 4.0][cc-by-shield]][cc-by]

This work is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].

[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg




## Conditions for Use
The DevCCF is a [Brain Initiative Cell Census Network](https://biccn.org/) (BICCN) resource.

BICCN data, tools, and resources, including the DevCCF are generally released under the Creative Commons Attribution 4.0 International Public License (CC BY 4.0, https://creativecommons.org/licenses/by/4.0/legalcode) (“CC BY 4.0 License”). Under the  CC BY 4.0 License external data users may freely download, analyze and publish results based on any BICCN open-access data and tools as soon as they are released, provided they give appropriate credit, a link to the license, and indicate if changes were made.  The CC BY 4.0 License applies to all open-access datasets generated by individual members of the Network, regardless of type or size.

Researchers using unpublished BICCN data are encouraged to contact the data producers to discuss possible coordinated publications; however, this is optional. The Network will continue to publish the results of its own analysis efforts in independent publications.




## Citation Information
We require that researchers who use BICCN datasets (published or unpublished) in any tools, web applications, presentations, and publications cite and acknowledge the BICCN and BICCN production laboratory(s) for referenced dataset(s).

DevCCF Preprint citation:
Kronman, F. A. et al. Developmental Mouse Brain Common Coordinate Framework. bioRxiv 2023.09.14.557789 (2023) doi:10.1101/2023.09.14.557789.

DevCCF citation will be updated once published in peer review.



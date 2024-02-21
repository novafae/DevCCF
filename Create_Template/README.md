# DevCCF ANTs Template Construction Script
This is the in house code used to generate the Developmental Mouse Brain Common Coordinate Framework (DevCCF) templates.


## Detailed description of code's functionality (pseudocode)
This script facilitates the construction of brain imaging templates using the Advanced Normalization Tools (ANTs) software. It takes input if the form of one or more brain images. Input images must have corretly assigned metadata (origin, orientation, spacing). Each image is flipped over the midline and saved as a copy. All input images and copies are input to the ANTs `antsMultivariateTemplateConstruction2.sh` script. The output includes a symmetric intensity and morphologic average template of all input. See `antsMultivariateTemplateConstruction2.sh` help for additional help with parameter optimization. 


### Disclaimer:
* This script is provided as-is and may require customization to suit specific use cases. There are many hardcoded values that are optimized for our datasets. You may need to modify some values to optimize for your data. Users are encouraged to review and modify the script as needed for their research projects.


## System Requirements
* All software dependencies and operating systems (including version numbers)
* Versions the software has been tested on
* Any required non-standard hardware


### Operating System Requirements
* This is intended to run on a computing cluster. We built it for SLURM


### Software Dependencies:
* Advanced Normalization Tools (ANTs)
* MATLAB (if flipping images; tested on version 2019a or newer) with the following toolboxes:
* If flipping, ensure `antsFlip.m` is available


## Installation guide
Download the code. No installation necessary.


### Instructions:
1. Customize the input parameters in the script according to your requirements.
2. Execute the script using a Bash-compatible shell (e.g., Linux terminal).


## Important Notes:
* The script is designed to be used with SLURM (Simple Linux Utility for Resource Management) batch job system, allowing for parallel processing and efficient resource utilization on high-performance computing clusters.
* Ensure that all input images are in a compatible format supported by ANTs.
* Verify that the specified output directory exists and has write permissions.
* Adjust the number of threads and memory allocation based on your system specifications.
* Review the ANTs documentation for detailed information on transformation types, options, and usage.
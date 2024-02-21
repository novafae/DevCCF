# DevCCF Multimodal Registration Script
Code for landmark based multimodal registration for in Kronman et al. (doi: 10.1101/2023.09.14.557789). For full protocol, see DevCCF_MultimodalReg_Protocol.md

This is the in house code facilitates multimodal registration using the Advanced Normalization Tools (ANTs) software. It enables researchers to register brain imaging data, such as MRI and LSFM, for various neuroimaging analyses and studies.


## Code's functionality (pseudocode)
This script facilitates the registration of multimodal brain imaging data using the Advanced Normalization Tools (ANTs) software by aligning 3D template landmarks with optional inclusion of templates themselves. The script also allows repeat use of generated transforms to align further data. 

### To Create Label Images
1. An initial registration between multimodal templates was run using `antsRegistrationQuickSyN.sh`.
2. Registration was viewed in ITK-SNAP for quality
3. A template mask was created, where values of 1 represent brain, and 0 represent not brain
4. Misaligned areas were segmented on for both templates
5. **Label Images**: Misaligned areas were removed from the template mask, leaving a landmark file where nonbrain areas and segmented landmark regions are 0, and remaining brain areas are 1.

**NOTE**: See Protocol for Additional Label Generation Details


### Script Steps
1. **Job Configuration**: SLURM directives (#SBATCH) to configure job parameters such as name, output/error logs, account, email notifications, partition, resources, and time limit.
2. **User Input**: Define user input values, detailed in script
3. **Create the output directory** if it does not exist 
4. **Copy Metadata**: If enabled, copy metadata from templates to labels using ANTs `CopyImageHeaderInformation` command 
5. `CopyImageHeaderInformation`: If enabled, set up initial transforms if applying previous transforms first
6. **Label Image Splitting**: If enabled, split label images into separate files based on specified label numbers using the `ThresholdImage` command.
7. **Registration Process**: Perform the registration if the Register flag is set using the ANTs `antsRegistration` command. It includes rigid, affine, and B-spline SyN transformations with mutual information (linear registration) or mean square difference metrics (nonlinear registration).
8. **Transformation Application**: Apply transformations to templates and annotations and any additional data and label images using the `antsApplyTransforms` command after registration. Generate transformed output files based on specified input images and transformation matrices.



### Disclaimer:
* This script is provided as-is and may require customization to suit specific use cases. There are many hardcoded values that are optimized for our datasets. You may need to modify some values to optimize for your data. Users are encouraged to review and modify the script as needed for their research projects.


## Output:
Registered template and label images, as well as transformed files with the specified output prefix. Output includes warped data, labels, and original annotations if provided in input.

**NOTE**: See ANTs `antsRegistration` help for additional parameter and output details


## System Requirements

### Operating System Requirements
* This is intended to run on a computing cluster. We built it for SLURM


### Software Dependencies:
- ANTs (Advanced Normalization Tools)
- SLURM (Simple Linux Utility for Resource Management)
- MATLAB (optional for image resampling): antsResample.m and antsResample_series.m


## Installation guide
Download the code. No installation necessary.


### Instructions to Run Code:
1. Customize the input parameters in the script according to your requirements.
2. Execute the script using a SLURM computing cluster.


## Important Notes:
- The script is designed to be used with SLURM (Simple Linux Utility for Resource Management) batch job system, allowing for parallel processing and efficient resource utilization on high-performance computing clusters.
- Prior to execution, verify the correctness of input data paths and parameters.
- Customize flags and parameters as per specific requirements.
- Monitor job progress and adjust resource allocation if necessary.
- Thoroughly examine the output files to ensure accuracy and completeness of the registration process.
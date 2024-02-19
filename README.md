# DevCCF
Companion code for the Developmental Mouse Brain Common Coordinate Framework (DevCCF)


## System Requirements
* All software dependencies and operating systems (including version numbers)
* Versions the software has been tested on
* Any required non-standard hardware

### Operating System Requirements
* Windows 10 or 11
* RAM: 
* Cores:

### Software Dependencies:
MATLAB (tested on version 2022a or newer) with the following toolboxes:
*	Curve Fitting Toolbox
*	Image Processing Toolbox
*	Optimization Toolbox
*	Parallel Computing Toolbox
*	Signal Processing Toolbox
*	Wavelet Toolbox


## Installation guide

### Instructions:
To Install this program, simply unzip the main directory and store it in a location that you can access via MATLAB. This should only take seconds.

### Typical install time on a "normal" desktop computer:

## Demo

* Instructions to run on data
* Expected output
* Expected run time for demo on a "normal" desktop computer


Input:
Expected Output:
Run Time: 


## Instructions for use

* How to run the software on your data
* (OPTIONAL) Reproduction instructions

1.	Open Multi_Input.csv
2.	Beginning on row 3, fill out following information for a dataset you want to stitch. Additional datasets may be entered in a new row.
    *	**Sorce_folder** - Location of Input Tiles (Must faster if running on solid state drive [SSD])
    *	**Working_folder** - Location to copy input to if Source is network drive. _Must have double the size of input data, and be SSD (~10x slower on disk drive)_
    *	**final_labdrive_location** - Location to copy results to at the end. Can be a network drive. Leave blank to keep in working_folder
    *	**channel_for_stitching** - LSFM channel used for stitching. Based on input data format (e.g if channel 00, use 0)
    *	**making_shrink_after_stitching**
          * 1: Make resampled version of stitched image when complete
          * 0: Do not make resampled version of stitched image when complete
    *	**shrink_ratio** - resample paramaters. E.g. [10 1] means 10x downsizing on XY and 1x downsizing on Z
    *	**max_cores** - maximum number of cores to run stitching. Use 0 for all cores.
    *	**inverting_x_y** - Required: always use 1.
    *	**copy_data_to_working_drive**
          * 1: Copy Data to working drive and run code (Recommended if source is network drive or if not SSD)
          * 0: Run code from data in Source folder.
    *	**recalculate_y_normalization** - Depreciated. Always use 0.
    *	**hard_fix_empty_space** - Required: always Use 1
    *	**magnification** - Defines magnification of microscope. Current options: 4x or 15x
    *	**MaximumStepLength** - Maximum shift allowed while stitching (Default: 0.35)
4.	Save and close the CSV.
5.	In MATLAB, open ‘RUN_THIS_FILE_FKupdate.m
6.	In the USER INPUT section, update the location of ‘Multi_Input.csv’
7.	Run the Program

*We have done our best to make this package portable. However, there are many hardcoded values that are optimized for our datasets. You may need to modify some values to optimize for your data.


## Detailed description of code's functionality (pseudocode)



This program takes LSFM data acquired as a set of tiled images and stitches them together to form a 3D image (stored as a set of 2D images). This is a parallelized stitching algorithm optimized for conserving hard drive space and memory consumption initially based on Wobbly Stitcher17. The algorithm starts by collecting metadata and calculating tile normalization parameters to be applied during stitching. Stitching begins by collecting 10% outer edges of each image tile and making a maximum intensity projection (MIP) of outer edges in the axial (z) direction for every set of 32 slices of the entire stack. The algorithm then aligns z coordinates of MIP images across image columns, followed by the x and y coordinate alignment. Finally, 32 slices within each MIP are adjusted based on curve fitting to reach final coordinates of each tile. This is run on one channel and other channels from the same acquisition time are stitched using identical parameters. This algorithm only reads the raw images two times (at the beginning and the final writing), which significantly reduces the bottleneck of reading large files in a storage drive. Finally, there are options to create resampled versions of the dataset and move the data to an alternate location.


## Code Location






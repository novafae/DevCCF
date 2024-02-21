## USER INPUT #############################################
files ='/gpfs/Home/cuk476/GeneExpression/20231027_all_coronal_batch/1_subjects_reconstructed_resampled/*_section_resampled.nii.gz'
###########################################################
axis = 2 # which axis to iterate through (Default: 2 for z axis)
overwrite = 0 # Overwrite current mask if exists


import operator
import ants
import glob
import os
import argparse
import antspynet
print(' ')
print(' ')
print(' ')

try:
    parser = argparse.ArgumentParser(description='Mask Image Script')
    # Add command-line arguments
    parser.add_argument('files', type=str, help='Input file(s) path  (may include wildcard)')
    parser.add_argument('--axis', type=int, default=axis, help='Axis value (default: 2)')
    parser.add_argument('--overwrite', type=int, default=0, help='Overwrite existing masks (default: 0)')

    # Parse the command-line arguments
    args = parser.parse_args()
    # Get input from command-line argument
    files = args.files
    axis = args.axis
    overwrite = args.overwrite
    print('Running from BASH')
except:
    print('Running from PYTHON')


# Find all files
f = glob.glob(files)

print(str(len(f)) + ' FILES FOUND...')

count = 1
for image_fName in f:
    print( str(count) + '/' + str(len(f)) + ': ' + image_fName)
    count = count + 1
    
    # Set Output Name
    image_mask_fName = image_fName.replace('.nii', '_mask.nii')
    
    # Skip if Mask Exist
    if os.path.exists(image_mask_fName):
        if overwrite:
            print('  OVERWRITING CURRENT MASK')
        else:
            print('  Mask Exists, Skipping')
            continue

    # Read Image
    print('Creating Mask: ' + image_fName)
    image = ants.image_read(image_fName)

    # Select if sagittal or coronal
    if operator.contains(image_fName, "sagittal"):
        view = "sagittal"
    elif operator.contains(image_fName, "coronal"):
        view = "coronal"

    # Create Mask Images
    if operator.contains(image_fName, "_E11") or operator.contains(image_fName, "_E13") or operator.contains(image_fName, "_E15"):
        print('Extracting Brain from Skull')
        image_mask = antspynet.allen_ex5_brain_extraction(image, view=view, which_axis=axis, verbose=True)
    else:
        print('Extracting Brain from surroundings')
        image_mask = antspynet.allen_histology_brain_mask(image, which_axis=axis, verbose=True)

    # Save
    ants.image_write(ants.threshold_image(image_mask, 0.5, 1.1, 1, 0), image_mask_fName)
    
print('Complete!')

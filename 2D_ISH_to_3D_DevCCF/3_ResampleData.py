import ants
import numpy as np
import os
import glob

## USER INPUT #######################
os.environ["ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS"] = "8"

base_directory = '/path/to/base/directory/'                                 # Insert Base Directory Path if Applicable

input_directory = base_directory + "2_subjects_reconstructed/"              # Location of Output from SectionNExpression
output_directory = base_directory + "3_subjects_reconstructed_resampled/"   # Output Directory
must_contain = '950'                                                        # String that must be in the file profile (e.g. a subject number)

#####################################

# Make Directory
if not os.path.exists(output_directory):
    os.makedirs(output_directory)

# Get Files
subject_files = glob.glob(input_directory + "/*" + must_contain + "*.nii.gz")

# For each file...
for i in range(len(subject_files)):
    
    # Set Output filename
    print(subject_files[i], "(", i+1, "out of", len(subject_files), ")")
    resampled_file = output_directory + os.path.basename(subject_files[i]).replace(".nii.gz","_resampled.nii.gz")
    
    # Skip if it already exists
    if os.path.exists(resampled_file):
        continue

    # Read Input
    subject_image = ants.image_read(subject_files[i])

    # Split Channels and get size
    subject_channels = ants.split_channels(subject_image)
    size = subject_image.shape

    # Set new size to 512 x 512
    resampling_params = (512, 512, size[2])

    # Resample
    subject_channels_resampled = list()
    for j in range(len(subject_channels)):
        subject_channels_resampled.append(ants.resample_image(subject_channels[j], resampling_params, True, 0))
    
    # Merge channels
    subject_image = ants.merge_channels(subject_channels_resampled)
    
    # Save Output
    ants.image_write(subject_image, resampled_file)
        

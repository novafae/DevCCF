#!/bin/bash -l

#SBATCH --job-name=T_P04_2SyN20um
#SBATCH --output=/gpfs/Home/cuk476/1_DevBrain/P04/LSFM/NewSubects/TemplateUpdate/2SyN20um/T_P04_2SyN20um_results.%j.txt
#SBATCH --error=/gpfs/Home/cuk476/1_DevBrain/P04/LSFM/NewSubects/TemplateUpdate/2SyN20um/T_P04_2SyN20um_errors.%j.txt
#SBATCH --account lab_kim
#SBATCH --mail-user=ckronman@pennstatehealth.psu.edu
#SBATCH --mail-type=ALL
#SBATCH --partition dense
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 80
#SBATCH --mem=0G
#SBATCH --time=unlimited

# Penn State dense partition: max cpus-per-task 88 / max mem 1500G (input as 0)
# Penn State compute partition: max cpus-per-task 44 / max mem ~350G (input as 0)
echo 'Starting Job...'

# This Bash script automates the creation of brain imaging templates using the Advanced Normalization Tools (ANTs) software. It streamlines the template construction process, enabling researchers in the field of neuroimaging to efficiently generate templates for analysis and research purposes.
# Written By: Fae Nova
# Last Edited: 20240221

#==========================================================================================================================================
# USER INPUT

# Location to save output. This is usually the same as the directory for output and error files in SBATCH instructions
output_directory=/gpfs/Home/cuk476/1_DevBrain/P04/LSFM/NewSubects/TemplateUpdate/2SyN20um/

# The file prefix added to all output file names
output_prefix=T_P04_2SyN20um_

# Input Images (You can use wildcard * for multiple files. filename name Name must start with '*' to accommadate flipped images)
input_images='/gpfs/Home/cuk476/1_DevBrain/P04/LSFM/NewSubects/P04_*/4_Warped_MIlong/*_Warped.nii.gz'

# Initializing Template. For first run, leave empty (''); For subsequent runs, use output template from previous step.
prev_template='/gpfs/Home/cuk476/1_DevBrain/P04/LSFM/NewSubects/TemplateUpdate/1SyN50um/T_P04_LSFM_Update_1SyN50um_template0_20um.nii.gz'

export ITK_GLOBAL_DEFAULT_NUMBER_OF_THEADS=5 	# Number of theads to use when registering each image (ideal is 4-8)
threads=15	  					# Number of Images that can be run in parallel. (can be less than total number of images)
                                # NOTE: threads * ITK_GLOBAL_DEFAULT_NUMBER_OF_THEADS = cpus-per-task < 88 (for dense partition) or 44 (for compute/gpu partition)

transformation=SyN				# Type of Transformation (Rigid, Affine, SyN, BSplineSyN, etc)
                                # Usually will use SyN. If using SyN you can't get convergence, try Rigid. Then Affine, then SyN at lowest resoltion
								# See antsRegistration from ants package for more information about each

SyN_Options=[0.1,3,0]			# SyN Options (Default = [0.1,3,0])    0.1 is pairwise gradient step; 3 is std of gausian kernel (smoothing similarity metric field in voxel space; incr for less deformation))
                                # 0.1 is pairwise gradient step (moving image flexibility) for each indidvidual registration to the current template
                                # Default: 0.1 | Recommended range: 0.1 - 0.3. Larger allows more flexibility but can cause overfitting
                                # 3 is std of gausian kernel (smoothing similarity metric field in voxel space; incr for less deformation)

iterations=100x100x70x20  		# Max Iterations (Default: 100x100x70x20)
shrink_factors=6x4x2x1			# Default: 6x4x2x1 (-f)
smoothing_factors=3x2x1x0		# Defaule: 3x2x1x0  (-s)

gradient_step=0.25				# Gradient step size (default = 0.25). Smaller is more cautious and better refinement. Usually larger in the beginning and move to 0.1 for final steps.

drift=1							# Set -y. Use 0 if image is drifting (Default 1). Image drift means your image is only partially viewable in the field of view
imgStat=1						# Image Stat to Summarize Image 0=Mean; 1=NormalizedMean 2=Median (Default=1)
sharpening=0					# 0=None; 1=Laplacian; 2=UnsharpMask (Default=1).  Laplacian sharpens image, which can make LSFM line artifacts worse. Use 0 for LSFM. 1 otherwise
saveIterations=1                # 1=Save intermediate steps | 0=do not save intermediate steps
similarity_metric='CC'			# CC=cross correlation (Default); MI=mutual information; MSQ = mean square difference; DEMONS=demon's metric

flip=1                          # 1: Flip all input images to make symetric template. 0: Do not flip input images. If 1, intput filename must start with '*'
                                # NOTE: REQUIRES antsFlip Function if flip=1
 If flipping, put location of antsflip.m
antsflip_filelocation="/gpfs/Home/cuk476/Scripts/MATLAB"

# For additional parameter details, see ANTs help pages (https://github.com/ANTsX/ANTs/) and antsMultivariateTemplateContruction2.sh script
#==========================================================================================================================================

# Advanced Input
num_modalities=1
modality_weights=1
legacy=0  # Use legacy version of (antsMultivariateTemplateConstruction.sh)

# Set full length output location
out_pre=${output_directory}/${output_prefix}

# Print Input Image File Names
echo INPUT IMAGES: 
for i in ${input_images}; do
	echo $input_images
done
echo ""

# Flip images if needed
for i in ${input_images}; do
	fFolder="$(dirname "${i}")"
	fName="$(basename "${i}")"    
	if [ ${flip} -eq 1 ] && [ ! -f ${fFolder}/f${fName} ] && [[ "$fName" != "f"* ]] && [[ ${i} != *"BIAS"* ]] && [[ ${i} != *"MASK"* ]] && [[ ${fName} != *"template0f"* ]] && [[ ${i} != *"mask"* ]]; then
		echo Flipping ${i}
		# Load MATLAB
		module load matlab

		# Get Current Path
		script_path=$0
		antsflip_filelocation=$(dirname $(readlink -f "$script_path"))
		antsflip_filelocation=\"${antsflip_filelocation}\"

		# Run MATLAB
		matlab -nodisplay -nosplash -sd ${antsflip_filelocation} -r "antsFlip('3', '${i}', 0, 0, '')"
	fi
done        


# Load Matlab
module load matlab

# Prev Template or not
empty=''
if [ "$prev_template" != "$empty" ]; then
	echo Running Template Construction WITH Previous Template: $prev_template 
	prev_template="-r 0 -z $prev_template"
else
	echo Running Template Construction WITHOUT Previous Template
	prev_template='-r 1'
fi

# Run Template Construction
if [ ${legacy} -eq 1 ]; then
	echo "Running AntsMultivariateTemplateConstruction.sh (retro)"
	command="antsMultivariateTemplateConstruction.sh -d 3 -o $out_pre -c 2 -j $threads -y $drift -a $imgStat -A $sharpening -g $gradient_step -b $saveIterations -n 0 -t GR -m $iterations -s $similarity_metric -k $num_modalities -w $modality_weights $prev_template $input_images"
else
	echo "Running AntsMultivariateTemplateConstruction2.sh"
	command="antsMultivariateTemplateConstruction2.sh -d 3 -c 2 -j $threads -y $drift -a $imgStat -A $sharpening -g $gradient_step -b $saveIterations -n 0 -t $transformation$SyN_Options -q $iterations -f $shrink_factors -s $smoothing_factors -m $similarity_metric -k $num_modalities -w $modality_weights $prev_template -o $out_pre $input_images"
fi

echo $command
eval "$command"


# Show Command
echo 'Command: '
history 2

echo 'Complete!'
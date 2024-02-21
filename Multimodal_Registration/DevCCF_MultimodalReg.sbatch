#!/bin/bash -l

#SBATCH --job-name=P56_CCF2MRI_symmetric_2LandmarkReg
#SBATCH --output=/gpfs/Home/cuk476/1_DevBrain/P56/MultimodalReg/CCF2MRI_symmetric/2LandmarkReg/P56_CCF2MRI_symmetric_2LandmarkReg_results.%j.txt
#SBATCH --error=/gpfs/Home/cuk476/1_DevBrain/P56/MultimodalReg/CCF2MRI_symmetric/2LandmarkReg/P56_CCF2MRI_symmetric_2LandmarkReg_errors.%j.txt
#SBATCH --account lab_kim
#SBATCH --mail-user=ckronman@pennstatehealth.psu.edu
#SBATCH --mail-type=ALL
#SBATCH --partition compute
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 8
#SBATCH --mem 200G
#SBATCH --time=unlimited 

echo 'Starting Job...'

#== USER INPUT ========================================================================
export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=8

baseDirectory=/gpfs/Home/cuk476/1_DevBrain/P56/MultimodalReg/CCF2MRI_symmetric

Register=0  		# Run Registration?
include_data=0		# Use template/data image in registration? Note: takes much longer. Value is set weigh of this data. (0 is none; .5 is half as much as labels; 1 is equal; 2 is twice as much; etc.)

# Label Images designating Landmarks (must contain word "LABELS")
movingLabelImage=${baseDirectory}/CCF_multimodal_registration_annotation_50_coronal_LABELS_v5_Symmetric_NoAC_ASR_Oriented.nii.gz
fixedLabelImage=${baseDirectory}/T_P56_MRI-adc_SymmetricStereotaxicTemplate_50um_LABELSv1.nii.gz
fix_label_metdata=0 # If 1, this copies metadata from templates to labels.

# Original Annotations from Moving Image (to transform). This would be original annotations if they exist. Otherwise leave blank
movingOriginalAnnotationImage=/gpfs/Home/cuk476/1_DevBrain/AllenCCF/CCFv3_10um_annotations_16b_LSP_Oriented2.nii.gz

# Data Images (Templates matching label images)
movingImage=${baseDirectory}/CCF_average_template_50_Oriented_SetSpacing.nii.gz
fixedImage=${baseDirectory}/T_P56_MRI-dwi_SymmetricStereotaxicTemplate_50um.nii.gz

# Location and prefix for Output
outputPrefix=/gpfs/Home/cuk476/1_DevBrain/P56/MultimodalReg/CCF2MRI_symmetric/2LandmarkReg/P56_CCF2MRI_symmetric_2LandmarkReg_

# Transform Info:
firstTransform=0 # If 1, run transforms right after registration
newTransform=1	 # If 1, run transforms at a later time than registration (seperately)
fix_metadata=0	 # Copy metadata from templates/data files to transform files
TransformFiles=/gpfs/Home/cuk476/1_DevBrain/P56/MultimodalReg/CCF2MRI_symmetric/2LandmarkReg/CCFv3_annotation_10um_updated_LSP_metafix_ASR.nii.gz # Files to transform
inverseTransformFiles= # Files to inverse transform

#==========================================================================

## ADVANCED USER INPUT ####
initial_transform=0 # Use initial Transform in antsRegistration (1:yes)
initial_transforms_outputPrefix=/gpfs/Home/cuk476/1_DevBrain/P56/MultimodalReg/CCF2MRI_symmetric/1TestReg_fa_g2/P56_CCF2MRI_symmetric_1TestReg_fa_g2_ # initial transform output prefix

split_labels=1  	# Advanced Input Only | Split the input labels to use only those defined by label numbers. This requires manual changes 
label_numbers="1"	# Advanced Input Only | This script is set up only to handle using Label value of 1

# Transform Settings
set_output_resolution_in_mm=0 	# Set to desired resolution of transformed images in mm (.02 = 20um). Don't go above 0.01 unless you know what you're doing. This is set in mm. your image metadata must be set properly in mm.
								# Note: leave as 0 to keep current resolution
#==========================================================================

# Make Output Directory & Copy Batch File
output_directory="$(dirname "${outputPrefix}")"
mkdir -p $output_directory
if [ $Register -ne 0 ] ; then
	cp $0 ${outputPrefix}DevCCF_MultimodalReg.sbatch
else
	cp $0 ${outputPrefix}DevCCF_MultimodalReg-AdditionalTransform.sbatch
fi


if [ $fix_label_metdata -eq 1 ]; then
	CopyImageHeaderInformation $movingImage $movingLabelImage $movingLabelImage 1 1 1; 
	CopyImageHeaderInformation $fixedImage $fixedLabelImage $fixedLabelImage 1 1 1; 
fi

# Use initial transforms?
if [ $initial_transform -eq 1 ]; then
	initial_transforms="-r ${initial_transforms_outputPrefix}1Warp.nii.gz -r ${initial_transforms_outputPrefix}0GenericAffine.mat"
	initial_transforms_inverse="-r [${initial_transforms_outputPrefix}0GenericAffine.mat,1] -r ${initial_transforms_outputPrefix}1InverseWarp.nii.gz"
	initial_transforms_t="-t ${initial_transforms_outputPrefix}1Warp.nii.gz -t ${initial_transforms_outputPrefix}0GenericAffine.mat"
	initial_transforms_inverse_t="-t [${initial_transforms_outputPrefix}0GenericAffine.mat,1] -t ${initial_transforms_outputPrefix}1InverseWarp.nii.gz"
	initial_transforms_ti="-t ${outputPrefix}3Warp.nii.gz -t ${outputPrefix}2GenericAffine.mat"
	initial_transforms_inverse_ti="-t [${outputPrefix}2GenericAffine.mat,1] -t ${outputPrefix}3InverseWarp.nii.gz"
else
	initial_transforms="-r [${fixedLabelImage},${movingLabelImage},1]"
	initial_transforms_inverse=" "
	initial_transforms_t=" "
	initial_transforms_inverse_t=" "
	initial_transforms_ti=" "
	initial_transforms_inverse_ti=" "
fi

if [[ "$include_data" = "0" ]]; then
	include_data=""
else
	include_data="-m MI[${fixedImage},${movingImage},${include_data},32]"
fi

if [ $Register -eq 1 ]; then

	# Select only First Label
	#for i in {1..3}
	if [ $split_labels -eq 1 ]; then
		for i in $label_numbers
			do

			# if [[ -f "${fixedLabelImage/LABELS/LABELS${i}}" ]] && [[ -f "${movingLabelImage/LABELS/LABELS${i}}" ]]; then
			# 	echo "label $i images already exists."

			# else
				echo "Creating label $i images."

				fixedSingleLabelImage=${fixedLabelImage/LABELS/LABELS${i}}
				movingSingleLabelImage=${movingLabelImage/LABELS/LABELS${i}}

				ThresholdImage 3 $fixedLabelImage $fixedSingleLabelImage $i $i 1 0
				ThresholdImage 3 $movingLabelImage $movingSingleLabelImage $i $i 1 0
			# fi
		done

		# Register
		antsRegistration -d 3 -o ${outputPrefix} -v 1 \
							${initial_transforms} \
						-t Rigid[0.2] \
							-m MI[${fixedLabelImage/LABELS/LABELS1},${movingLabelImage/LABELS/LABELS1},1,32,Random,0.25] \
							-c [500x200,0,10] \
							-f 8x4 \
							-s 2x1 \
						-t Affine[0.2] \
							-m MI[${fixedLabelImage/LABELS/LABELS1},${movingLabelImage/LABELS/LABELS1},1,32,Random,0.25] \
							-c [500x200x200x100,0,10] \
							-f 8x6x4x2 \
							-s 3x2x1x0 \
						-t BSplineSyN[0.25,1.0,0,3] \
							-m MSQ[${fixedLabelImage/LABELS/LABELS1},${movingLabelImage/LABELS/LABELS1},1,1] \
							${include_data} \
							-c [100x100x70x0,0,10] \
							-f 6x4x2x1 \
							-s 3x2x1x0 
						
	else
		antsRegistration -d 3 -o ${outputPrefix} -v 1 \
		${initial_transforms} \
	-t Rigid[0.2] \
		-m MI[${fixedLabelImage},${movingLabelImage},1,32,Random,0.25] \
		-c [500x200x100x50,0,10] \
		-f 8x4x2x1 \
		-s 2x1x1x0 \
	-t Affine[0.2] \
		-m MI[${fixedLabelImage},${movingLabelImage},1,32,Random,0.25] \
		-c [500x200x200x100,0,10] \
		-f 8x6x4x2 \
		-s 3x2x1x0 \
	-t BSplineSyN[0.25,1.0,0,3] \
		-m MSQ[${fixedLabelImage},${movingLabelImage},1,1] \
		${include_data} \
		-c [100x100x70x0,0,10] \
		-f 6x4x2x1 \
		-s 3x2x1x0 
	fi

fi



if [ $firstTransform -eq 1 ]; then
	
	CreateWarpedGridImage 3 ${outputPrefix}1InverseWarp.nii.gz ${outputPrefix}1InverseWarpedGrid.nii.gz 1x0x1

	# Data
	antsApplyTransforms -d 3 -v 1 \
							-i $movingImage \
							-r $fixedLabelImage \
							-o ${outputPrefix}WarpedData.nii.gz \
							-n BSpline \
							$initial_transforms_ti \
							-t ${outputPrefix}1Warp.nii.gz \
							-t ${outputPrefix}0GenericAffine.mat
							
	# Inverse Data
	antsApplyTransforms -d 3 -v 1 \
							-i $fixedImage \
							-r $movingLabelImage \
							-o ${outputPrefix}InverseWarpedData.nii.gz \
							-n BSpline \
							-t [${outputPrefix}0GenericAffine.mat -1] \
							-t ${initial_transforms_outputPrefix}1InverseWarp.nii.gz \
							$initial_transforms_inverse_ti

	# Affine Labels
	#antsApplyTransforms -d 3 -v 1 \
							# -i $movingLabelImage \
							# -r $fixedLabelImage \
							# -o ${outputPrefix}AffineWarpedLabel.nii.gz \
							# -n MultiLabel \
							# $initial_transforms_ti \
							# -t ${outputPrefix}0GenericAffine.mat

	# LABELS
	antsApplyTransforms -d 3 -v 1 \
							-i $movingLabelImage \
							-r $fixedLabelImage \
							-o ${outputPrefix}WarpedLabels.nii.gz \
							-n MultiLabel \
							$initial_transforms_ti \
							-t ${outputPrefix}1Warp.nii.gz \
							-t ${outputPrefix}0GenericAffine.mat

	# Inverse labels
	antsApplyTransforms -d 3 -v 1 \
							-i $fixedLabelImage \
							-r $movingLabelImage \
							-o ${outputPrefix}InverseWarpedLabels.nii.gz \
							-n $MultiLabel \
							-t [${outputPrefix}0GenericAffine.mat,1] \
							-t ${initial_transforms_outputPrefix}1InverseWarp.nii.gz \
							$initial_transforms_inverse_ti
							
	# OriginalAnnotations
	antsApplyTransforms -d 3 -v 1 \
							-i $movingOriginalAnnotationImage \
							-r $fixedLabelImage \
							-o ${outputPrefix}WarpedOriginalAnnotationLabels.nii.gz \
							-n MultiLabel \
							$initial_transforms_ti \
							-t ${outputPrefix}1Warp.nii.gz \
							-t ${outputPrefix}0GenericAffine.mat
fi

if [ $newTransform -eq 1 ]; then

	# Set to 20um for transform
	if [ $set_output_resolution_in_mm != 0. ]; then
		new_size=$set_output_resolution_in_mm		# in millimeters
		new_size_string=$(echo "$set_output_resolution_in_mm * 1000" | bc)
		new_size_string=${new_size_string%.*}um
		# Load Matlab


		# Get Current Path
		script_path=$0
		antsResample_series_filelocation=$(dirname $(readlink -f "$script_path"))
		antsResample_series_filelocation=\"${antsResample_series_filelocation}\"


		module load matlab
		if [ ! -f "${movingLabelImage%%.nii*}_${new_size_string}.nii.gz" ]; then
			printf "\nConverting moving label images to ${new_size_string} for transforms"
			matlab -nodisplay -nosplash -sd "/gpfs/Home/cuk476/Scripts/MATLAB" -r "antsResample_series('$movingLabelImage', {'.nii' }, $new_size, 0, 0, {'asdf';})"
		fi
		if [ ! -f "${fixedLabelImage%%.nii*}_${new_size_string}.nii.gz" ]; then
			printf "Converting fixed label images to ${new_size_string} for transforms\n"
			matlab -nodisplay -nosplash -sd "/gpfs/Home/cuk476/Scripts/MATLAB" -r "antsResample_series('$fixedLabelImage', {'.nii' }, $new_size, 0, 0, {'asdf';})"
		fi
		movingLabelImage=${movingLabelImage%%.nii*}_${new_size_string}.nii.gz
		fixedLabelImage=${fixedLabelImage%%.nii*}_${new_size_string}.nii.gz
		echo "label Images set to ${new_size_string}!" 
	fi
		
	echo Applying New Transforms
	for transformFile in $TransformFiles; do
	
		echo Transforming $transformFile
		transform_folder="$(dirname "${transformFile}")" # Get transform folder
		transform_fName="$(basename "${transformFile}")" # Get transform file name
		transform_output_name=${outputPrefix}transformed_${transform_fName%%.nii*}.nii.gz
		if [ $set_output_resolution_in_mm != 0. ]; then
			transform_output_name=${transform_output_name%%.nii*}_${new_size_string}.nii.gz
		fi

		# Fix Labels Metadata?
		if [ $fix_metadata -ne 0 ]; then
			fix_spacing=1 # Set spacing to that of moving image by default
			if  [ $fix_metadata -eq 2 ]; then
				fix_spacing=0 	#if fix_metadata set to 2, don't update spacing
			fi
			echo Copying metadata from $movingImage
			echo ... to ${transformFile}
			CopyImageHeaderInformation $movingImage $transformFile $transformFile 1 1 ${fix_spacing}; 
		fi

		if [[ "${transform_fName,,}" == *annotat* ]] ||  [[ "${transform_fName,,}" == *label* ]] ||  [[ "${transform_fName,,}" == *segment* ]] ||  [[ "${transform_fName,,}" == *mask* ]] && [[ "${transform_fName,,}" != *masked* ]]; then
			TransformInterpolation=MultiLabel
		else
			TransformInterpolation=BSpline
		fi
		echo Interpolation Method: $TransformInterpolation

		antsApplyTransforms -d 3 -v 1 \
							-i $transformFile \
							-r $fixedLabelImage \
							-o $transform_output_name \
							-n $TransformInterpolation \
							$initial_transforms_ti \
							-t ${outputPrefix}1Warp.nii.gz \
							-t ${outputPrefix}0GenericAffine.mat			 
	done
	
	for inverse_transformFile in $inverseTransformFiles; do
		
		inverse_transform_folder="$(dirname "${inverse_transformFile}")" # Get transform folder
		inverse_transform_fName="$(basename "${inverse_transformFile}")" # Get transform file name
		inverse_transform_output_name=${outputPrefix}inversetransformed_${inverse_transform_fName%%.nii*}.nii.gz
		if [ $set_output_resolution_in_mm != 0. ]; then
			inverse_transform_output_name=${inverse_transform_output_name%%.nii*}_${new_size_string}.nii.gz
		fi
			
					# Fix Labels Metadata?
		if [ $fix_metadata -ne 0 ]; then
			fix_spacing=1 # Set spacing to that of moving image by default
			if  [ $fix_metadata -eq 2 ]; then
				fix_spacing=0 	#if fix_metadata set to 2, don't update spacing
			fi
			echo Copying metadata from $fixedImage
			echo ... to $inverse_transformFile
			CopyImageHeaderInformation $fixedImage $inverse_transformFile $inverse_transformFile 1 1 ${fix_spacing}; 
		fi
			
		if [[ "${inverse_transform_fName,,}" == *annotat* ]] ||  [[ "${inverse_transform_fName,,}" == *label* ]] ||  [[ "${inverse_transform_fName,,}" == *segment* ]] ||  [[ "${inverse_transform_fName,,}" == *mask* ]]; then
			TransformInterpolation=MultiLabel
		else
			TransformInterpolation=BSpline
		fi
		
		antsApplyTransforms -d 3 -v 1 \
							-i $inverse_transformFile \
							-r $movingLabelImage \
							-o $inverse_transform_output_name \
							-n $TransformInterpolation \
							-t [${outputPrefix}0GenericAffine.mat,1] \
							-t ${outputPrefix}1InverseWarp.nii.gz \
							$initial_transforms_inverse_ti

	done
	
fi
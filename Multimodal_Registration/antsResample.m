% Scale up image in ANTs
function smooth_output = antsResample(input, new_XYZ_dimension, smoothing_sigma, convert2u16)
% Input can be a file, folder, or files with *. STRING
% new_XYZ_dimension is a new file dimension in the units of original file. NUMBER
% smoothing_sigma is the smoothing kernel in pixels. NUMBER

%% USER INPUT
% input = 'C:\CK\P56_Template_LSFM\P56_JN0038\namP56_JN0038_Bg.nii';
% new_XYZ_dimension = [0.1, .05, .02];          % This is the new voxel dimensions. Be sure to check units! (you can do so using niftiinfo if .nii, or ImageJ if .nii.gz)
% smoothing_sigma = 0.5;                        % In Pixels (.5 is like average)
dimension = 3;
addvox = 0;

files = dir(input);

for j = 1:length(new_XYZ_dimension)
    disp(['Rescaling Image to ', num2str(1000*new_XYZ_dimension), 'um isotropic']);
    for i = 1:length(files)
        
        %% Define File Names
        file = [files(i).folder, filesep, files(i).name];
        rrr = dir(file);
        rescale_output = [rrr.folder, filesep, 'r', extractBefore(rrr.name, '.nii'), '_', num2str(1000*new_XYZ_dimension(j)), 'um.nii.gz'];
        smooth_output = [rrr.folder, filesep, 'sr', extractBefore(rrr.name, '.nii'), '_', num2str(1000*new_XYZ_dimension(j)), 'um.nii.gz'];
        if contains(rescale_output, '/hpc/') || contains(rescale_output, '/gpfs/')
            rescale_output = [rrr.folder, filesep, extractBefore(rrr.name, '.nii'), '_', num2str(1000*new_XYZ_dimension(j)), 'um.nii.gz'];
            smooth_output = [rrr.folder, filesep, extractBefore(rrr.name, '.nii'), '_', num2str(1000*new_XYZ_dimension(j)), 'um.nii.gz'];
        end
        
        % If label, set to nearest neighbor interpolation
        if contains(files(i).name, 'annotat', 'IgnoreCase', true) || contains(files(i).name, 'label', 'IgnoreCase', true) || contains(files(i).name, 'segment', 'IgnoreCase', true) || contains(files(i).name, 'mask', 'IgnoreCase', true)
            nn_interp = 1;
        else
            nn_interp = 0;
        end

        
        wsl = '';
        if ispc
            file = pc2wsl(file);
            rescale_output = pc2wsl(rescale_output);
            smooth_output = pc2wsl(smooth_output);            
            prep_wsl
        end
        
        %% SCALE IT UP
        % ResampleImageBySpacing  ImageDimension inputImageFile  outputImageFile outxspc outyspc {outzspacing}  {dosmooth?}  {addvox} {nn-interp?}
        %  addvox pads each dimension by addvox
        disp(['Scaling to ', num2str(1000*new_XYZ_dimension), 'um isotropic...'])
        rescale_command = ['ResampleImageBySpacing ', num2str(dimension), ' ', file, ' ', rescale_output,  ...
            ' ', num2str(new_XYZ_dimension(j)), ' ', num2str(new_XYZ_dimension(j)), ' ', num2str(new_XYZ_dimension(j)), ' 0 ', num2str(addvox), ' ', num2str(nn_interp)];
        disp('Rescale Command: ')
        disp(['    ', rescale_command])
        system([wsl, rescale_command])

        %% SMOOTH IT OUT
        % SmoothImage ImageDimension image.ext smoothingsigma outimage.ext {sigma-is-in-spacing-units-(0)/1} {medianfilter-(0)/1}
        %  If using median filter, sigma is the radius of filtering, in voxels
        %  A separate sigma can be specified for each dimension, e.g., 1.5x1x2
        if ~smoothing_sigma==0
            disp(['Smoothing by ', num2str(smoothing_sigma), ' voxels...'])
            smooth_command = ['SmoothImage ', num2str(dimension), ' ', rescale_output, ' ', num2str(smoothing_sigma), ' ' smooth_output];
            disp('Smooth Command: ')
            disp(['    ', smooth_command])
            system([wsl, smooth_command])
        else
            smooth_output = rescale_output;
        end
        
        %% CONVERT TO 16bit
        if convert2u16
            disp(['Converting to uint16', num2str(smoothing_sigma), ' voxels...'])
            convert_command = ['ConvertImagePixelType ', smooth_output, ' ', smooth_output, '  3'];
            disp('Convertion Command: ')
            disp(['    ', convert_command])
            system([wsl, convert_command])
        end
    end
end
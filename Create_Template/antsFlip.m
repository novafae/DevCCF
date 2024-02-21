function output = antsFlip(dimension, files, axis, always_new_reflection, reused_reflection_mat ) 
%% This file uses ANTs to filp an image and adjust the corresponding header
% dimension = the image dimension (2 or 3)
% input = the input file (should be N4 corrected if using to create a symmetric template)
% output_path = the output file location
% axis = the axis to flip. x:0, y:1, z:2

%% User Input
% % File names must be in Mac format for mac or WSL format for PC
% dimension = '3'; % Image dimension (2 or 3)
% input = 'D:\lab_members\CK\2_N4BiasCorrection\n_avg_dwi.nii.gz'; % Input file
% output_path = 'D:\lab_members\CK\3_SymmetricTemplateConstruction\'; % Output file

overwrite = 0;
cast2u16 = 0;
% always_new_reflection = 1;
%ignore = {'Whole', 'tensor', 'rawdata', 'mask', 'bias'};
ignore = {'Whole', 'tensor', 'rawdata', 'bias'};
%%

files = dir(files); %, filesep, '*.nii*']); % Get files

% Ignore
for i = 1:length(ignore)
    files = files(~contains({files.name},ignore{i},'IgnoreCase',true));
end
ncores = length(files);
% reflection_mat = [files(1).folder, filesep, 'reflection_matrix.mat']; % Name reflection Matrix

if ismac
    % Add ANTs to Path
    c1='export ANTSPATH=/opt/ANTs/bin/; ';
    c2='export PATH=${ANTSPATH}:$PATH; ';
    
    % Set number of ANTs Threads
    c3='export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4; ';
    
    wsl = [c1 c2 c3];
elseif ispc
    
    % Goes to WSL on PC
    prep_wsl
    
    % Set number of ANTs Threads
    c3='export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=4; ';
    
else
    wsl = '';
    % error('ERROR: Could not determing computer platform (Mac or PC). Script failed.');
end
last_subject_directory = '';
for i = 1:length(files)
    if ~strcmp(reused_reflection_mat,'')
        reflection_mat = reused_reflection_mat;
    else
        reflection_mat = [files(i).folder, filesep, extractBefore(files(i).name, '.nii') '_reflection_matrix.mat']; % Name reflection Matrix
    end
    file = [files(i).folder, filesep, files(i).name]; % input, reference space
    disp(' ');
    disp(['Flipping: ', file]);
    
    if overwrite == 1
        output = file;
    else
        output =  [files(i).folder, filesep, 'f', files(i).name]; % output
    end
    
    % Convert names if PC
    if ispc
        output = pc2wsl(output);
        file = pc2wsl(file); 
        reflection_mat = pc2wsl(reflection_mat);
    end
    
    % Pull it all together;
    if (~strcmp(last_subject_directory, files(i).folder) || always_new_reflection) && strcmp(reused_reflection_mat,'') % If the subject directory has changed, calculate new reflection matrix
        disp('Calculating Reflection Matrix...')
        command1 = ['ImageMath ', dimension, ' ', reflection_mat, ' ReflectionMatrix ', file, ' ' num2str(axis), '; '] ;
    else
        command1 = '';
    end
    
%     % Cast to u16
%     if cast2u16
%         data_type = ' -u short ';
%     else
         data_type = '';
%     end
    
    command2 = ['antsApplyTransforms -d ', dimension, ' -i ', file, ' -r ', file, data_type, ' -o ', output, ' -n NearestNeighbor -t ', reflection_mat, ' -v 1;'];

    % Run the command
    system([wsl, command1, command2]);
    last_subject_directory = files(i).folder;
    
    %% CONVERT TO 16bit
        if cast2u16
            disp(['Converting to uint16: ', output])
            convert_command = ['ConvertImagePixelType ', output, ' ', output, '  3'];
            disp('Convertion Command: ')
            disp(['    ', convert_command])
            system([wsl, convert_command])
        end

end
output = dir([files(1).folder, filesep, 'f*.nii*']);
end
% Better Stitcher v 1.01,  released 2021 0326
% An improved version of the wably stitcher done by YTW in YK lab
% UPDATE: 20220201 Multiple Input Option added by FK
%
% Takes input as the full path to a .csv sheet with all settings 
% and stitches one sample after another

clear
close all


%% USER INPUT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Full Path To Excel File (folder and file) - see Multi_Input.csv as an example
CSV_File = 'D:\lab_members\BB\Multi_Input_03_22.csv';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% Load CSV Sheet
% rows_to_load = [2,number_of_files+1];
MultiInput = Import_CSV_File(CSV_File);
disp(MultiInput)
[number_of_files, ~] = size(MultiInput);

%% Loop Through Excel Sheet rows
for i = 1:number_of_files
    
    clearvars -except MultiInput number_of_files i
    
    if ~strcmp(MultiInput.Sorce_folder(i), "") % If there's actually data there
        
        %% Basic setting
        Sorce_folder = char(MultiInput.Sorce_folder(i));      % This one "refered" to be SSD
        Working_folder = char(MultiInput.Working_folder(i)); % This one "have" to be SSD that is double of the data size, non-SSD will make it 10x slower
        channel_for_stitching = MultiInput.channel_for_stitching(i); % The channel used for stitching, ie, C00 -> 0
        final_labdrive_location = MultiInput.final_labdrive_location(i); % The location on the labdrive for data storage
        
        disp('  ')
        disp(['Stitching Data from: '] )
        disp([' ', Sorce_folder])
        disp('to Working Directory: ')
        disp([' ', Working_folder])
        disp(['Based on channel ', num2str(channel_for_stitching)])
        
        % Shrink Settings
        making_shrink_after_stitching = MultiInput.making_shrink_after_stitching(i); %can only mak shrink if you chosed to make tif above
        shrink_ratio = str2num(MultiInput.shrink_ratio(i));  % [10 1] means 10x downsizing on XY and 1x downsizing on Z
        
        % Number of Cores (Set to 0 to use all cores)
        max_cores = MultiInput.max_cores(i);
        if max_cores == 0
            max_cores = str2num(getenv('NUMBER_OF_PROCESSORS'));
        end
        
        % On or Off Settings (0=Off; 1 = On)
        inverting_x_y = MultiInput.inverting_x_y(i); % Just put 1. Putting 0 do not work, this function is still under wokingg
        % delete_tif_in_working_folder = 1;
        copy_data_to_working_drive = MultiInput.copy_data_to_working_drive(i);
        recalculate_y_normalization = MultiInput.recalculate_y_normalization(i);
        hard_fix_empty_space = MultiInput.hard_fix_empty_space(i);
        
        % 4x or 15x magnification
        magnification = MultiInput.magnification(i);

        
        % Illumination correction setting
        if strcmp(magnification, '4x')
            %%% default value for 4x
            disp('Magnification: 4x')
            tile_y_gausian_sigma(1) = 1.0673e+03;
            tile_y_gausian_mu(1) = 906.5935;
            tile_y_gausian_sigma(2) = 1.0673e+03;
            tile_y_gausian_mu(2) = 906.5935;
        elseif strcmp(magnification, '15x')
            %%% default value for 15x
            disp('Magnification: 4x')
            tile_y_gausian_sigma(1) = 1.230155529305395e+04;
            tile_y_gausian_mu(1) = 1.129565050405089e+03;
            tile_y_gausian_sigma(2) = 1.230155529305395e+04;
            tile_y_gausian_mu(2) = 1.129565050405089e+03;
        else
            error('magnification not set properly')
        end
        
        % Wably setting
        z_truncate = MultiInput.z_truncate(i);
        shift_allowed = 30;
        [optimizer, metric] = imregconfig('monomodal');
        thresh_hold_percent_0 =0.05;
        curvitting_algrithm = 'smooth_spline';
        smooth_index = 8;
        
        optimizer.MaximumStepLength = MultiInput.MaximumStepLength(i);
        optimizer.MaximumIterations = 500;
        optimizer.RelaxationFactor = 0.6;
        
        % pystripe setting
        py_striping = MultiInput.py_striping(i);
        sigma_background = 256;
        sigma_foreground = 128;
        ez_thresh_holding = 1;
        using_gpu = 0;

        %% Computation

        tic
        file_naming_scheme;
        disp('    Reading Metadata...')
        read_meta_data;
        disp('    Indexing Files...')
        file_indexing;
        toc
        
        % copy metadata
        disp('     Copying metadata')
        copyfile([Sorce_folder, filesep, '*.txt'], Working_folder)
        copyfile([Sorce_folder, filesep, '*.ini'], Working_folder)
        
        % Normalization
        if recalculate_y_normalization
            tic
            disp('    Calulating tile normalization...')
            tile_normalization_re;
            toc
        end
        
        
        % Stitching
        disp('    Starting Stitching...')
        tic
        warning('off','all');
        
        wably_stitcher_re;
        warning('on','all');
        toc
        
        
        tic
        shifting_inndex_optimizaer;
        toc
        
        
        tic
        stitching_for_real;
        toc
        
        disp(['Stitching Complete for ', Sorce_folder])
        
        %% archival
        % [~, system_memory] = memory;
        % memory_cap = system_memory.PhysicalMemory.Available.*0.9;
        % num_of_cores_stc = 28;
        % memory_modulation_ws = 3.0;
        % stitching_for_2_color;
        % figure;plot(center_points.xxx_shift','DisplayName','center_points.xxx_shift')
        % figure;plot(center_points.yyy_shift','DisplayName','center_points.yyy_shift')
        
        %% Move to LabDrive
        if ~strcmpi(final_labdrive_location, "")
            disp('Moving Files to LabDrive')
            if isempty(dir(final_labdrive_location))
                mkdir(final_labdrive_location)
            end
            movefile([Working_folder, filesep, '*'], [char(final_labdrive_location), filesep])
        end

    end
end

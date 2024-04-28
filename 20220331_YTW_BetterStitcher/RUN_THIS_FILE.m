% Better Stitcher v 1.01,  released 2021 0326
% An improved version of the wably stitcher done by YTW in YK lab


clear
close all
% Basic setting
Sorce_folder = 'E:\lab_member\HB\20210223_16_57_04_HB_HB408_3_16wk_WTctrl_AbdAorta_DRAQ5-488_Iba1-594_CD31-647_15x_1um_Rsht_Transfer'; % This one "refered" to be SSD
Working_folder = 'E:\lab_member\HB\testing'; % This one "have" to be SSD that is double of the data size, non-SSD will make it 10x slower
channel_for_stitching = 2; % The channel used for stitching, ie, C00 -> 0

making_shrink_after_stitching = 1; %can only mak shrink if you chosed to make tif above
shrink_ratio = [20, 1];  % [10 1] means 10x downsizing on XY and 1x downsizing on Z
max_cores = 0;
if max_cores == 0
    max_cores = str2num(getenv('NUMBER_OF_PROCESSORS'));
end

inverting_x_y = 1; % Just put 1. Putting 0 do not work, this function is still under wokingg

% delete_tif_in_working_folder = 1;

copy_data_to_working_drive = 1;
recalculate_y_normalization = 0;
hard_fix_empty_space = 1;



%%% Illumination correction setting
%%% default value for 4x
% tile_y_gausian_sigma(1) = 1.0673e+03;
% tile_y_gausian_mu(1) = 906.5935;
% tile_y_gausian_sigma(2) = 1.0673e+03;
% tile_y_gausian_mu(2) = 906.5935;
%%% default value for 15x
tile_y_gausian_sigma(1) = 1.230155529305395e+04;
tile_y_gausian_mu(1) = 1.129565050405089e+03;
tile_y_gausian_sigma(2) = 1.230155529305395e+04;
tile_y_gausian_mu(2) = 1.129565050405089e+03;


% Wably setting
z_truncate = 200;
shift_allowed = 30;
[optimizer, metric] = imregconfig('monomodal');
thresh_hold_percent_0 =0.05;
 curvitting_algrithm = 'smooth_spline';
smooth_index = 8;

optimizer.MaximumStepLength = 0.35;
optimizer.MaximumIterations = 500;
optimizer.RelaxationFactor = 0.6;

%%% pystripe setting
py_striping = 1;
sigma_background = 256;
sigma_foreground = 128;
ez_thresh_holding = 1;
using_gpu = 0;


%%% Computation

tic
file_naming_scheme;
read_meta_data;
file_indexing;
toc

if recalculate_y_normalization
    tic
    tile_normalization_re;
    toc
end


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


%%% archival
% [~, system_memory] = memory;
% memory_cap = system_memory.PhysicalMemory.Available.*0.9;
% num_of_cores_stc = 28;
% memory_modulation_ws = 3.0;
% stitching_for_2_color;
% figure;plot(center_points.xxx_shift','DisplayName','center_points.xxx_shift')
% figure;plot(center_points.yyy_shift','DisplayName','center_points.yyy_shift')




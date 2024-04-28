% Better Stitcher v 0.99,  released Feb, 23, 2021
% An improved version of the wably stitcher done by YTW in YK lab


clear
close all
% Basic inputs
Sorce_folder = 'E:\lab_member\YTW\KN387_raw'; % This one "refered" to be SSD
Working_folder = 'E:\lab_member\YTW\KN387_testing'; % This one "have" to be SSD that is double of the data size, non-SSD will make it 10x slower
channel_for_stitching = 0;
inverting_x_y = 1; % Just put 1. Putting 0 do not work, this function is still under wokingg

% delete_tif_in_working_folder = 1;
% delete_pre_stitched_npy = 1;
% delete_stitched_npy = 1;
copy_data_to_working_drive = 0;
% recalculate_y_normalization = 0;
hard_fix_empty_space = 1;

tile_y_gausian_sigma(1) = 0;
tile_y_gausian_mu(1) = 0;
tile_y_gausian_sigma(2) = 0;
tile_y_gausian_mu(2) = 0;


tic
file_naming_scheme;
read_meta_data;
file_indexing;
toc
clear tilling_queue

kk = 0;

for ii = 1:size(read_file_name,1)
    for jj = 1:size(read_file_name,2)
        for ll = 1:size(read_file_name,4)
            kk = kk+1;
            tilling_queue(kk).channel = ll;
            tilling_queue(kk).side = iamge_set_folder_detail(ii,jj,ll);
            tilling_queue(kk).tile_id = [ii, jj];
            tilling_queue(kk).res_i = tiling_info.x_pixel;
            tilling_queue(kk).res_j = tiling_info.y_pixel;
            
        end
    end
end

for side_ii = 1:2
    if ~isempty(find([tilling_queue(:).side] == side_ii))
        parfor kk = find([tilling_queue(:).side] == side_ii)
            
            image_1_mean = zeros(tiling_info.x_pixel,tiling_info.y_pixel);
            count_1 = zeros(tiling_info.x_pixel,tiling_info.y_pixel);
            
            for ll = 1:10:tiling_info.z_pixel
                img_temp_1 = double(imread(read_file_name{tilling_queue(kk).tile_id(1),tilling_queue(kk).tile_id(2),ll,tilling_queue(kk).channel}));
                
                if inverting_x_y
                    img_temp_1 = img_temp_1';
                end
                thresh_1 = 200;
                thresh_2 = 5000;
                flag = img_temp_1>thresh_1 & img_temp_1<thresh_2;
                
                image_1_mean = image_1_mean + (img_temp_1 .* flag);
                count_1 = count_1 + flag;
                
            end
            image_1_mean(isnan(image_1_mean(:))) = 0;
            image_observatory{kk} = image_1_mean;
            image_observatory_2{kk} = count_1;
            
        end
        
        
        flag = [tilling_queue(:).channel] == channel_for_stitching & [tilling_queue(:).side] == side_ii;
        
        asdasd = zeros(size(image_observatory{1}));
        asdasd_2 = zeros(size(image_observatory{1}));
        for ii = find(flag)
            
            asdasd = asdasd+ image_observatory{ii};
            asdasd_2 = asdasd_2+ image_observatory_2{ii};
        end
        
        asdasd = asdasd./asdasd_2;
        
        xxx = 1:tiling_info.y_pixel;
        
        [tile_y_gausian_sigma(side_ii),tile_y_gausian_mu(side_ii),A] = mygaussfit(xxx,mean(asdasd,1))
        figure;imshow(asdasd,[0, 1.5.*max(asdasd(:))]);hold
        figure;plot([mean(asdasd,1); A .* exp( -(xxx-tile_y_gausian_mu(side_ii)).^2 ./ (2*tile_y_gausian_sigma(side_ii).^2) )]');
    end
    
end
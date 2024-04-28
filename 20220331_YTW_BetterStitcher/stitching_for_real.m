

%%% center_points  tiling_info read_file_name


xxx_min = floor(min(center_points.xxx  + min(center_points.xxx_shift,[],2)) - tiling_info.x_pixel./2) -1 ;
xxx_max = ceil(max(center_points.xxx  + max(center_points.xxx_shift,[],2)) + tiling_info.x_pixel./2) +1;
yyy_min = floor(min(center_points.yyy  + min(center_points.yyy_shift,[],2)) - tiling_info.y_pixel./2) -1;
yyy_max = ceil(max(center_points.yyy  + max(center_points.yyy_shift,[],2)) + tiling_info.y_pixel./2) +1;

center_points.xxx_img  =  center_points.xxx - xxx_min  ;
center_points.yyy_img  =  center_points.yyy - yyy_min ;

final_img_size = [(xxx_max-xxx_min +1), (yyy_max-yyy_min +1)];

center_points.xxx_shift_img = center_points.xxx_shift + center_points.xxx_img - tiling_info.x_pixel./2;
center_points.yyy_shift_img = center_points.yyy_shift + center_points.yyy_img -  tiling_info.y_pixel./2;

zzz_min = floor(-max(center_points.zzz_shifting));


new_reading_file_ind = {};
old_kk_index_look_up = [];
for ii = 1:size(read_file_name,1)
    for jj = 1:size(read_file_name,2)
        for kk = 1:size(read_file_name,3)
            kk_prime = kk - round(center_points.zzz_shifting(sub2ind([tiling_info.x_tiles,tiling_info.y_tiles],ii,jj))) - zzz_min + 1;
            for ll = 1:size(read_file_name,4)
                new_reading_file_ind{ii,jj,kk_prime,ll} = read_file_name{ii,jj,kk,ll};
            end
            old_kk_index_look_up(ii,jj,kk_prime) = kk;
            center_points_prime.xxx_shift_img(ii,jj,kk_prime) = center_points.xxx_shift_img(sub2ind([tiling_info.x_tiles,tiling_info.y_tiles],ii,jj),kk);
            center_points_prime.yyy_shift_img(ii,jj,kk_prime) = center_points.yyy_shift_img(sub2ind([tiling_info.x_tiles,tiling_info.y_tiles],ii,jj),kk);
        end
    end
end



out_ch_folder = {};
for ll = 1:size(read_file_name,4)
    out_ch_folder{ll} = [Working_folder, '/stitched_', num2str(ll-1,'%02d')];
    mkdir(out_ch_folder{ll} )
end
out_file_name_tif = {};
for kk_prime = 1:size(new_reading_file_ind,3)
    for ll = 1:size(new_reading_file_ind,4)
        out_file_name_tif{kk_prime,ll} = [out_ch_folder{ll}, '/Z', num2str(kk_prime,'%05d'), '_ch', num2str(ll-1,'%02d') '.tif'];
    end
end


out_ch_shrink_folder = {};
for ll = 1:size(read_file_name,4)
    out_ch_shrink_folder{ll} = [Working_folder, '/stitched_', num2str(ll-1,'%02d'), '_shrink'];
    mkdir(out_ch_shrink_folder{ll} )
end
out_file_name_shrink_tif = {};
for kk_prime = 1:size(new_reading_file_ind,3)
    for ll = 1:size(new_reading_file_ind,4)
        out_file_name_shrink_tif{kk_prime,ll} = [out_ch_shrink_folder{ll}, '/Z', num2str(kk_prime,'%05d'), '_ch', num2str(ll-1,'%02d') '.tif'];
    end
end


for nn = 1:2
    yyy_correction_1{nn} = 1:tiling_info.y_pixel;
    yyy_correction_1{nn} = 1./exp( -(yyy_correction_1{nn}-tile_y_gausian_mu(nn)).^2 / (2.*tile_y_gausian_sigma(nn).^2) );
end


if py_striping & ez_thresh_holding
    image_2_max = [image_1_max{:}];
    threshold = single(multithresh(image_2_max,1));
else
    threshold = -1;
end



nLoops = size(new_reading_file_ind,3).*size(new_reading_file_ind,4);
% updateWaitbar = waitbarParfor(nLoops, "Calculation in progress...");

% parfor mm = 1:nLoops
if using_gpu
    g = gpuDevice(1);
    reset(g);
    max_cores = 2;
end

parfor (mm = 1:nLoops , max_cores)
    % for mm = 1:nLoops
    [kk_prime,ll] = ind2sub([size(new_reading_file_ind,3), size(new_reading_file_ind,4)],mm);
    img_temp = zeros(final_img_size);
    for ii = 1:size(new_reading_file_ind,1)
        for jj = 1:size(new_reading_file_ind,2)
            kk = old_kk_index_look_up(ii,jj, kk_prime);
            if ~isempty(new_reading_file_ind{ii,jj,kk_prime,ll})
                img_temp_2 = imread(new_reading_file_ind{ii,jj,kk_prime,ll});
                nn = iamge_set_folder_detail(ii,jj,ll);
                img_temp_2 = double(img_temp_2').*yyy_correction_1{nn};
                
                if (ii ~=1 ) & ~isempty(new_reading_file_ind{ii-1,jj,kk_prime,ll})
                    overlap_temp = round(tiling_info.x_pixel - (center_points_prime.xxx_shift_img(ii,jj,kk_prime) - center_points_prime.xxx_shift_img(ii-1,jj,kk_prime)));
                    ramp_temp = (1:overlap_temp)./overlap_temp;
                    img_temp_2(1:overlap_temp,:) = img_temp_2(1:overlap_temp,:).*ramp_temp';
                end
                if (jj ~=1 ) & ~isempty(new_reading_file_ind{ii,jj-1,kk_prime,ll})
                    overlap_temp = round(tiling_info.y_pixel - (center_points_prime.yyy_shift_img(ii,jj,kk_prime) - center_points_prime.yyy_shift_img(ii,jj-1,kk_prime)));
                    ramp_temp = (1:overlap_temp)./overlap_temp;
                    img_temp_2(:,1:overlap_temp) = img_temp_2(:,1:overlap_temp).*ramp_temp;
                end
                if (ii ~= tiling_info.x_tiles) & ~isempty(new_reading_file_ind{ii+1,jj,kk_prime,ll})
                    overlap_temp = round(tiling_info.x_pixel - (center_points_prime.xxx_shift_img(ii+1,jj,kk_prime) - center_points_prime.xxx_shift_img(ii,jj,kk_prime)));
                    ramp_temp = flip((1:overlap_temp)./overlap_temp);
                    img_temp_2(end-overlap_temp+1:end,:) = img_temp_2(end-overlap_temp+1:end,:).*ramp_temp';
                end
                if (jj ~= tiling_info.y_tiles ) & ~isempty(new_reading_file_ind{ii,jj+1,kk_prime,ll})
                    overlap_temp = round(tiling_info.y_pixel - (center_points_prime.yyy_shift_img(ii,jj+1,kk_prime) - center_points_prime.yyy_shift_img(ii,jj,kk_prime)));
                    ramp_temp = flip((1:overlap_temp)./overlap_temp);
                    img_temp_2(:,end-overlap_temp+1:end) = img_temp_2(:,end-overlap_temp+1:end).*ramp_temp;
                end
                
                
                ping_location_xxx = floor(center_points_prime.xxx_shift_img(ii,jj,kk_prime));
                %                 small_shift_xxx = mod(center_points_prime.xxx_shift_img(ii,jj,kk_prime),1);
                ping_location_yyy = floor(center_points_prime.yyy_shift_img(ii,jj,kk_prime));
                %                 small_shift_yyy = mod(center_points_prime.yyy_shift_img(ii,jj,kk_prime),1);
                %                 img_temp_2 = imtranslate(img_temp_2,[small_shift_xxx, small_shift_yyy],'OutputView','full');
                img_temp(ping_location_xxx+1:ping_location_xxx+size(img_temp_2,1),ping_location_yyy+1:ping_location_yyy+size(img_temp_2,2)) = ...
                    img_temp(ping_location_xxx+1:ping_location_xxx+size(img_temp_2,1),ping_location_yyy+1:ping_location_yyy+size(img_temp_2,2)) + img_temp_2;
            end
        end
    end
    
    if py_striping
        if using_gpu
            img_temp = pystripe_gpu(img_temp','sigma_background',sigma_background, 'sigma_foreground',sigma_foreground, 'threshold', threshold )';
        else
            img_temp = pystripe(img_temp','sigma_background',sigma_background, 'sigma_foreground',sigma_foreground, 'threshold', threshold )';
        end
    end
    imwrite(uint16(img_temp'),out_file_name_tif{kk_prime,ll});
    if making_shrink_after_stitching
        if mod(kk_prime,shrink_ratio(2)) == 0
            imwrite(uint16(imresize(img_temp',1./shrink_ratio(1))),out_file_name_shrink_tif{kk_prime,ll});
        end
    end
    %     updateWaitbar();
end
























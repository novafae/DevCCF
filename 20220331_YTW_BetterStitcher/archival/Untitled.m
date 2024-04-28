
parfor  total_wab_queue = 1:(shifting_key_n.*length(stitching_queue))
    
    [kk, mm] = ind2sub([length(stitching_queue), shifting_key_n], total_wab_queue);
    
    
    image_1_max = zeros(z_truncate,stitching_queue(kk).res_i);
    image_2_max = zeros(z_truncate,stitching_queue(kk).res_i);
    
    img_temp_1_max = zeros(stitching_queue(kk).overlap_size);
    img_temp_2_max = zeros(stitching_queue(kk).overlap_size);
    
    img_temp_1_sum = zeros(stitching_queue(kk).overlap_size);
    img_temp_2_sum = zeros(stitching_queue(kk).overlap_size);
    
    for ll = 1:z_truncate
        
        img_temp_1 = imread(read_file_name{stitching_queue(kk).tile_1(1),stitching_queue(kk).tile_1(2),((mm-1).*z_truncate + ll),channel_for_stitching}, 'PixelRegion', stitching_queue(kk).window_1 );
        img_temp_2 = imread(read_file_name{stitching_queue(kk).tile_2(1),stitching_queue(kk).tile_2(2),((mm-1).*z_truncate + ll),channel_for_stitching}, 'PixelRegion', stitching_queue(kk).window_2 );
        
        if inverting_x_y
            img_temp_1 = img_temp_1';
            img_temp_2 = img_temp_2';
        end
        
        img_temp_1_max = max(cat(3,img_temp_1_max,  img_temp_1),[],3);
        img_temp_2_max = max(cat(3,img_temp_2_max,  img_temp_2),[],3);
        img_temp_1_sum = img_temp_1_sum + img_temp_1./z_truncate;
        img_temp_2_sum = img_temp_2_sum + img_temp_2./z_truncate;
        
        img_temp_1 = max(img_temp_1,[],stitching_queue(kk).max_direction );
        img_temp_2 = max(img_temp_2,[],stitching_queue(kk).max_direction );
        
        if stitching_queue(kk).max_direction == 2
            img_temp_1 = img_temp_1';
            img_temp_2 = img_temp_2';
        end
        
        image_1_max(ll,:) = img_temp_1;
        image_2_max(ll,:) = img_temp_2;
        
    end
    
    
    try
        lastwarn('') % Clear last warning message
        tform = imregtform(img_temp_1_max,img_temp_2_max,'translation',optimizer,metric);
        [warnMsg, warnId] = lastwarn;
        if ~isempty(warnMsg)
            trform_2_pfor{total_wab_queue} = [nan nan];
        else
            if rssq(tform.T(3,1:2)) < shift_allowed
                trform_2_pfor{total_wab_queue} = tform.T(3,1:2);
            else
                trform_2_pfor{total_wab_queue} = [nan nan];
            end
        end
    catch
        trform_2_pfor{total_wab_queue} = [nan nan];
    end
    intensity_profile_pfor{total_wab_queue} = mean([img_temp_1_sum,img_temp_2_sum],'all');
    image_1_max_pfor{total_wab_queue} = image_1_max;
    image_2_max_pfor{total_wab_queue} = image_2_max;
    %image_observatory{kk} = [image_1_max, image_2_max];
    
end

for kk = 1:length(stitching_queue)
    for mm = 1:shifting_key_n
        total_wab_queue = sub2ind([length(stitching_queue), shifting_key_n],kk,mm);
        trform_2{kk}{mm} = trform_2_pfor{total_wab_queue};
        intensity_profile{kk}(mm) = intensity_profile_pfor{total_wab_queue};
    end
end

for kk = 1:length(stitching_queue)
    image_1_max = zeros(tiling_info.z_pixel,stitching_queue(kk).res_i);
    image_2_max = zeros(tiling_info.z_pixel,stitching_queue(kk).res_i);
    
    
    for mm = 1:shifting_key_n
        total_wab_queue = sub2ind([length(stitching_queue), shifting_key_n],kk,mm);
        image_1_max(((mm-1).*z_truncate + 1):((mm-1).*z_truncate + z_truncate),:) = image_1_max_pfor{total_wab_queue};
        image_2_max(((mm-1).*z_truncate + 1):((mm-1).*z_truncate + z_truncate),:) = image_2_max_pfor{total_wab_queue};
    end
    try
        tform = imregtform(image_1_max_f,image_2_max,'translation',optimizer,metric);
        trform{kk} = tform.T(3,1:2);
    catch
        trform{kk} = [0 0];
    end
    warning('off','all')
    for ll = 1:length(img_temp_2_sum_accum)
        
    end
    warning('on','all')
    %image_observatory_2{kk} = {img_temp_1_sum_accum, img_temp_2_sum_accum};
    
    
end
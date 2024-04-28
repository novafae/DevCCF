
%
shifting_key_n = floor(tiling_info.z_pixel./z_truncate);
% shifting_key_n = 20;
% z_truncate = floor(tiling_info.z_pixel./shifting_key_n);
clear stitching_queue tform

kk = 0;
for ii = 1:size(read_file_name,1)-1
    for jj = 1:size(read_file_name,2)
        kk = kk+1;
        stitching_queue(kk).tile_1 = [ii, jj];
        stitching_queue(kk).tile_2 = [ii+1, jj];
        stitching_queue(kk).res_i = tiling_info.y_pixel;
        stitching_queue(kk).window_1 = { [tiling_info.x_pixel-tiling_info.x_overlap+1, tiling_info.x_pixel] , [1, tiling_info.y_pixel ] };
        stitching_queue(kk).window_2 = { [1, tiling_info.x_overlap] , [1, tiling_info.y_pixel ] };
        stitching_queue(kk).max_direction = 1;
        stitching_queue(kk).overlap_size = [tiling_info.x_overlap, tiling_info.y_pixel];
        if inverting_x_y
            stitching_queue(kk).window_1 = {stitching_queue(kk).window_1{2}, stitching_queue(kk).window_1{1}};
            stitching_queue(kk).window_2 = {stitching_queue(kk).window_2{2}, stitching_queue(kk).window_2{1}};
        end
    end
end

for ii = 1:size(read_file_name,1)
    for jj = 1:size(read_file_name,2)-1
        kk = kk+1;
        stitching_queue(kk).tile_1 = [ii, jj];
        stitching_queue(kk).tile_2 = [ii, jj+1];
        stitching_queue(kk).res_i = tiling_info.x_pixel;
        stitching_queue(kk).window_1 = { [1, tiling_info.x_pixel ], [tiling_info.y_pixel-tiling_info.y_overlap+1, tiling_info.y_pixel] };
        stitching_queue(kk).window_2 = { [1, tiling_info.x_pixel ], [1, tiling_info.y_overlap] };
        stitching_queue(kk).max_direction = 2;
        stitching_queue(kk).overlap_size = [tiling_info.x_pixel, tiling_info.y_overlap];
        
        if inverting_x_y
            stitching_queue(kk).window_1 = {stitching_queue(kk).window_1{2}, stitching_queue(kk).window_1{1}};
            stitching_queue(kk).window_2 = {stitching_queue(kk).window_2{2}, stitching_queue(kk).window_2{1}};
        end
    end
end



stitching_queue = stitching_queue([2 6 12 13]);


tform = {};
trform_2 = {};
intensity_profile = {};

parfor  total_wab_queue = 1:(shifting_key_n.*length(stitching_queue))
    
    [kk, mm] = ind2sub([length(stitching_queue), shifting_key_n], total_wab_queue);
    
    
    image_1_max = zeros(z_truncate,stitching_queue(kk).res_i);
    image_2_max = zeros(z_truncate,stitching_queue(kk).res_i);
    
    img_temp_1_max = zeros(stitching_queue(kk).overlap_size);
    img_temp_2_max = zeros(stitching_queue(kk).overlap_size);
    
    img_temp_1_sum = uint16(zeros(stitching_queue(kk).overlap_size));
    img_temp_2_sum = uint16(zeros(stitching_queue(kk).overlap_size));
    
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
    
    warning('off','all')
    
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
    
    warning('on','all')
    
    
    
    image_observatory{total_wab_queue}{1} = img_temp_1_max;
    image_observatory{total_wab_queue}{2} = img_temp_2_max;
    
end



%{


parfor kk = 1:length(stitching_queue)
    for mm = 1:shifting_key_n
        total_wab_queue = sub2ind([length(stitching_queue), shifting_key_n],kk,mm);
        trform_2{kk}{mm} = trform_2_pfor{total_wab_queue};
        intensity_profile{kk}(mm) = intensity_profile_pfor{total_wab_queue};
    end
end

parfor kk = 1:length(stitching_queue)
    image_1_max = zeros(tiling_info.z_pixel,stitching_queue(kk).res_i);
    image_2_max = zeros(tiling_info.z_pixel,stitching_queue(kk).res_i);
    
    
    for mm = 1:shifting_key_n
        total_wab_queue = sub2ind([length(stitching_queue), shifting_key_n],kk,mm);
        image_1_max(((mm-1).*z_truncate + 1):((mm-1).*z_truncate + z_truncate),:) = image_1_max_pfor{total_wab_queue};
        image_2_max(((mm-1).*z_truncate + 1):((mm-1).*z_truncate + z_truncate),:) = image_2_max_pfor{total_wab_queue};
    end
    try
        tform = imregtform(image_1_max,image_2_max,'translation',optimizer,metric);
        trform{kk} = tform.T(3,1:2);
    catch
        trform{kk} = [0 0];
    end
    
    
    %image_observatory_2{kk} = {img_temp_1_sum_accum, img_temp_2_sum_accum};
    
    
end



intensity_profile_max = 0;
for kk = find([stitching_queue(:).max_direction] == 1)
    intensity_profile_max = max([intensity_profile_max,intensity_profile{kk}]) ;
end


shifting_key = {};

for kk = find([stitching_queue(:).max_direction] == 1)
    temp = [];
    for ll = 1:length( trform_2{kk} )
        temp(ll) = trform_2{kk}{ll}(1);
    end
    temp( intensity_profile{kk} < intensity_profile_max.*thresh_hold_percent_0) = nan;
    shifting_key{kk}{1} = temp;
end

for kk = find([stitching_queue(:).max_direction] == 1)
    temp = [];
    for ll = 1:length( trform_2{kk} )
        temp(ll) = trform_2{kk}{ll}(2);
    end
    temp( intensity_profile{kk} < intensity_profile_max.*thresh_hold_percent_0) = nan;
    shifting_key{kk}{2} = temp;
end


intensity_profile_max = 0;

for kk = find([stitching_queue(:).max_direction] == 2)
    intensity_profile_max = max([intensity_profile_max,intensity_profile{kk}]) ;
end


for kk = find([stitching_queue(:).max_direction] == 2)
    temp = [];
    for ll = 1:length( trform_2{kk} )
        temp(ll) = trform_2{kk}{ll}(1);
    end
    temp( intensity_profile{kk} < intensity_profile_max.*thresh_hold_percent_0) = nan;
    shifting_key{kk}{1} = temp;
end


for kk = find([stitching_queue(:).max_direction] == 2)
    temp = [];
    for ll = 1:length( trform_2{kk} )
        temp(ll) = trform_2{kk}{ll}(2);
    end
    temp( intensity_profile{kk} < intensity_profile_max.*thresh_hold_percent_0) = nan;
    shifting_key{kk}{2} = temp;
end

if hard_fix_empty_space
    
    for kk = 1:length(stitching_queue)
        if (nnz(isnan(shifting_key{kk}{1})) == length(shifting_key{kk}{1}))
            shifting_key{kk}{1} = zeros(size(shifting_key{kk}{1}));
        else
            while  ~(nnz(isnan(shifting_key{kk}{1})) == 0)
                for jj = 1:shifting_key_n-1
                    if (isnan(shifting_key{kk}{1}(jj))) & (~isnan(shifting_key{kk}{1}(jj+1)))
                        shifting_key{kk}{1}(jj) = shifting_key{kk}{1}(jj+1);
                    end
                    if (isnan(shifting_key{kk}{1}(jj+1))) & (~isnan(shifting_key{kk}{1}(jj)))
                        shifting_key{kk}{1}(jj+1) = shifting_key{kk}{1}(jj);
                    end
                end
            end
        end
        if (nnz(isnan(shifting_key{kk}{2})) == length(shifting_key{kk}{2}))
            shifting_key{kk}{2} = zeros(size(shifting_key{kk}{2}));
        else
            while  ~(nnz(isnan(shifting_key{kk}{2})) == 0)
                for jj = 1:shifting_key_n-1
                    if (isnan(shifting_key{kk}{2}(jj))) & (~isnan(shifting_key{kk}{2}(jj+1)))
                        shifting_key{kk}{2}(jj) = shifting_key{kk}{1}(jj+1);
                    end
                    if (isnan(shifting_key{kk}{2}(jj+1))) & (~isnan(shifting_key{kk}{2}(jj)))
                        shifting_key{kk}{2}(jj+1) = shifting_key{kk}{2}(jj);
                    end
                end
            end
        end
    end
end











%}



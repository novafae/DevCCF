
%

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
        if inverting_x_y
            stitching_queue(kk).window_1 = {stitching_queue(kk).window_1{2}, stitching_queue(kk).window_1{1}};
            stitching_queue(kk).window_2 = {stitching_queue(kk).window_2{2}, stitching_queue(kk).window_2{1}};
        end
    end
end
tic
[optimizer, metric] = imregconfig('monomodal');
tform = {};
parfor kk = 1:length(stitching_queue)
    %for kk = 1
    
    image_1_max = zeros(tiling_info.z_pixel,stitching_queue(kk).res_i);
    image_2_max = zeros(tiling_info.z_pixel,stitching_queue(kk).res_i);
    
    for ll = 1:tiling_info.z_pixel
        
        img_temp_1 = imread(read_file_name{stitching_queue(kk).tile_1(1),stitching_queue(kk).tile_1(2),ll,channel_for_stitching}, 'PixelRegion', stitching_queue(kk).window_1 );
        img_temp_2 = imread(read_file_name{stitching_queue(kk).tile_2(1),stitching_queue(kk).tile_2(2),ll,channel_for_stitching}, 'PixelRegion', stitching_queue(kk).window_2 );
        
        if inverting_x_y
            img_temp_1 = img_temp_1';
            img_temp_2 = img_temp_2';
        end
        
        img_temp_1 = max(img_temp_1,[],stitching_queue(kk).max_direction );
        img_temp_2 = max(img_temp_2,[],stitching_queue(kk).max_direction );
        
        if stitching_queue(kk).max_direction == 2
            img_temp_1 = img_temp_1';
            img_temp_2 = img_temp_2';
        end
        image_1_max(ll,:) = img_temp_1;
        image_2_max(ll,:) = img_temp_2;
        
    end

    image_observatory{kk} = [image_1_max, image_2_max];
    
    try
        tform = imregtform(image_1_max,image_2_max,'translation',optimizer,metric);
        trform{kk} = tform.T(3,1:2);
        %     stitching_queue(kk).trform = tform.T(3,1:2);
    catch
        trform{kk} = [0 0];
    end
end
toc

% [~,R_reg]  = imregister(image_1_max,image_2_max,'translation');

for kk = 1:length(stitching_queue)
figure; imshow(image_observatory{kk},[0 3000])

end
% x = fminsearch(fun,x0)
%}
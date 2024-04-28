
tiling_info_xy = [tiling_info.x_tiles, tiling_info.y_tiles];
clear center_points
cnetertile_x = round(tiling_info.x_tiles./2);
cnetertile_y = round(tiling_info.y_tiles./2);

[center_points.x, center_points.y] = ind2sub(tiling_info_xy,find(ones(tiling_info.x_tiles, tiling_info.y_tiles)));

center_points.xxx = (center_points.x - cnetertile_x).*double(tiling_info.x_pixel - tiling_info.x_overlap);
center_points.yyy = (center_points.y - cnetertile_y).*double(tiling_info.y_pixel - tiling_info.y_overlap);



%%% stitching_queue
%%% shifting_key_full


%%% tiling_info.z_pixel tiling_info.x_pixel tiling_info.y_pixel
%%% tiling_info.x_overlap tiling_info.y_overlap
%%% tiling_info.x_tiles, tiling_info.y_tiles, ~, tiling_info.ch_num

%%% center_points shifting_key_full


for ii = 1:length(stitching_queue)
    tile_1_ind(ii) = sub2ind(tiling_info_xy,stitching_queue(ii).tile_1(1),stitching_queue(ii).tile_1(2));
    tile_2_ind(ii) = sub2ind(tiling_info_xy,stitching_queue(ii).tile_2(1),stitching_queue(ii).tile_2(2));
end

options = optimoptions(...
    'fminunc','MaxFunctionEvaluations',100000, ...
    'MaxIterations', 100000, ...
    'Display', 'off', ...
    'OptimalityTolerance', 1E-8, ...
    'StepTolerance', 1E-8, ...
    'FiniteDifferenceType', 'central'...
    );


%% x_y location

xxx_shift = zeros([length(center_points.x), tiling_info.z_pixel]);
yyy_shift = zeros([length(center_points.x), tiling_info.z_pixel]);

parfor zz = 1:tiling_info.z_pixel
    
    xy_shifting_0 = zeros(length(center_points.x)-1,2);
    %     xy_shifting = zeros(length(center_points.x),2);
    %calculating_error(xy_shifting(2:end,:), shifting_key_full, stitching_queue);
    shifting_key_temp = [];
    for ii = 1:length(stitching_queue)
        shifting_key_temp(ii,1) = shifting_key_full{ii}{1}(zz);
        shifting_key_temp(ii,2) = shifting_key_full{ii}{2}(zz);
    end
    
    calculating_error = @(xy_shifting) cal_err_sub_fn(xy_shifting, tile_2_ind, tile_1_ind, shifting_key_temp);
    %     xy_shifting = fminsearch(calculating_error,xy_shifting_0,options);
    xy_shifting = fminunc(calculating_error,xy_shifting_0,options);
    
    xy_shifting = [0 0 ;xy_shifting];
    xy_shifting = xy_shifting - xy_shifting(sub2ind(tiling_info_xy,cnetertile_x,cnetertile_y),:);
    
    xxx_shift(:,zz) = xy_shifting(:,1);
    yyy_shift(:,zz) = xy_shifting(:,2);
end



fititing_profile = 1/(1 + (length(zz_temp)./smooth_index).^3./6);
for ii = 1:size(xxx_shift,1)
    xxx_shift(ii,:) = csaps(zz_temp,xxx_shift(ii,:),fititing_profile,zz_temp);
    yyy_shift(ii,:) = csaps(zz_temp,yyy_shift(ii,:),fititing_profile,zz_temp);
end

center_points.xxx_shift = xxx_shift;
center_points.yyy_shift = yyy_shift;


figure;plot(center_points.xxx_shift','DisplayName','center_points.xxx_shift')
figure;plot(center_points.yyy_shift','DisplayName','center_points.yyy_shift')


%% z location






z_shifting_0 = zeros(length(center_points.x)-1,1);

shifting_key_temp = [];
for queue_id_temp = 1:length(stitching_queue)
    shifting_key_temp(queue_id_temp,1) = trform{queue_id_temp}(2);
end

calculating_error = @(z_shifting) cal_err_sub_z_fn(z_shifting, tile_2_ind, tile_1_ind, shifting_key_temp);
%     xy_shifting = fminsearch(calculating_error,xy_shifting_0,options);
z_shifting = fminunc(calculating_error,z_shifting_0,options);

z_shifting = [0 ;z_shifting];
z_shifting = z_shifting - z_shifting(sub2ind(tiling_info_xy,cnetertile_x,cnetertile_y),:);


center_points.zzz_shifting = z_shifting;



























%{
center_points.distance = rssq([center_points.xxx,center_points.yyy],2);
[~,tile_sorted_ind] = sort(center_points.distance);


center_points.check_mark = false(size(center_points.distance));
center_points.check_mark(tile_sorted_ind(1)) = 1;


for kk = tile_sorted_ind(2:end)'
    
    [xxx, yyy] = ind2sub(tiling_info_xy,kk);
    count_tile_stitched_to = 0;
    if xxx - 1 >= 1 & (center_points.check_mark(sub2ind(tiling_info_xy,(xxx-1),yyy)) == 1)
        queue_id_temp = find_stitching_queue([xxx-1,yyy],[xxx,yyy],stitching_queue);
        center_points.zzz_shifting(kk) = center_points.zzz_shifting(kk) + center_points.zzz_shifting(sub2ind(tiling_info_xy,(xxx-1),yyy)) + trform{queue_id_temp}(2);
        count_tile_stitched_to = count_tile_stitched_to +1;
        
    end
    if yyy - 1 >= 1 & (center_points.check_mark(sub2ind(tiling_info_xy,(xxx),(yyy-1))) == 1)
        queue_id_temp = find_stitching_queue([xxx,yyy-1],[xxx,yyy],stitching_queue);
        center_points.zzz_shifting(kk) = center_points.zzz_shifting(kk) + center_points.zzz_shifting(sub2ind(tiling_info_xy,(xxx),(yyy-1))) + trform{queue_id_temp}(2);
        count_tile_stitched_to = count_tile_stitched_to +1;
        
        
    end
    if xxx + 1 <= tiling_info.x_tiles & (center_points.check_mark(sub2ind(tiling_info_xy,(xxx+1),yyy)) == 1)
        queue_id_temp = find_stitching_queue([xxx,yyy],[xxx+1,yyy],stitching_queue);
        center_points.zzz_shifting(kk) = center_points.zzz_shifting(kk) + center_points.zzz_shifting(sub2ind(tiling_info_xy,(xxx+1),(yyy))) - trform{queue_id_temp}(2);
        count_tile_stitched_to = count_tile_stitched_to +1;
        
        
    end
    if yyy + 1 <= tiling_info.y_tiles & (center_points.check_mark(sub2ind(tiling_info_xy,(xxx),(yyy+1))) == 1)
        queue_id_temp = find_stitching_queue([xxx,yyy],[xxx,yyy+1],stitching_queue);
        center_points.zzz_shifting(kk) = center_points.zzz_shifting(kk) + center_points.zzz_shifting(sub2ind(tiling_info_xy,(xxx),(yyy+1))) - trform{queue_id_temp}(2);
        count_tile_stitched_to = count_tile_stitched_to +1;
        
    end
    
    center_points.zzz_shifting(kk) = center_points.zzz_shifting(kk)./ count_tile_stitched_to;
    center_points.check_mark(kk) = 1;
    
end

%}
%{
center_points.check_mark = false(size(center_points.distance));
center_points.check_mark(tile_sorted_ind(1)) = 1;
center_points.xxx_shift = zeros([length(center_points.check_mark), tiling_info.z_pixel]);
center_points.yyy_shift = zeros([length(center_points.check_mark), tiling_info.z_pixel]);


for kk = tile_sorted_ind(2:end)'
    
    [xxx, yyy] = ind2sub(tiling_info_xy,kk);
    count_tile_stitched_to = 0;
    if xxx - 1 >= 1 & (center_points.check_mark(sub2ind(tiling_info_xy,(xxx-1),yyy)) == 1)
        queue_id_temp = find_stitching_queue([xxx-1,yyy],[xxx,yyy],stitching_queue);
        center_points.xxx_shift(kk,:) = center_points.xxx_shift(kk,:) + center_points.xxx_shift(sub2ind(tiling_info_xy,(xxx-1),(yyy))) - shifting_key_full{queue_id_temp}{1};
        center_points.yyy_shift(kk,:) = center_points.yyy_shift(kk,:) + center_points.yyy_shift(sub2ind(tiling_info_xy,(xxx-1),(yyy))) - shifting_key_full{queue_id_temp}{2};
        count_tile_stitched_to = count_tile_stitched_to +1;
    end
    if yyy - 1 >= 1 & (center_points.check_mark(sub2ind(tiling_info_xy,(xxx),(yyy-1))) == 1)
        queue_id_temp = find_stitching_queue([xxx,yyy-1],[xxx,yyy],stitching_queue);
        center_points.xxx_shift(kk,:) = center_points.xxx_shift(kk,:) + center_points.xxx_shift(sub2ind(tiling_info_xy,(xxx),(yyy-1))) - shifting_key_full{queue_id_temp}{1};
        center_points.yyy_shift(kk,:) = center_points.yyy_shift(kk,:) + center_points.yyy_shift(sub2ind(tiling_info_xy,(xxx),(yyy-1))) - shifting_key_full{queue_id_temp}{2};
        count_tile_stitched_to = count_tile_stitched_to +1;
    end
    if xxx + 1 <= tiling_info.x_tiles & (center_points.check_mark(sub2ind(tiling_info_xy,(xxx+1),yyy)) == 1)
        queue_id_temp = find_stitching_queue([xxx,yyy],[xxx+1,yyy],stitching_queue);
        center_points.xxx_shift(kk,:) = center_points.xxx_shift(kk,:) + center_points.xxx_shift(sub2ind(tiling_info_xy,(xxx+1),(yyy))) + shifting_key_full{queue_id_temp}{1};
        center_points.yyy_shift(kk,:) = center_points.yyy_shift(kk,:) + center_points.yyy_shift(sub2ind(tiling_info_xy,(xxx+1),(yyy))) + shifting_key_full{queue_id_temp}{2};
        count_tile_stitched_to = count_tile_stitched_to +1;
    end
    if yyy + 1 <= tiling_info.y_tiles & (center_points.check_mark(sub2ind(tiling_info_xy,(xxx),(yyy+1))) == 1)
        queue_id_temp = find_stitching_queue([xxx,yyy],[xxx,yyy+1],stitching_queue);
        center_points.xxx_shift(kk,:) = center_points.xxx_shift(kk,:) + center_points.xxx_shift(sub2ind(tiling_info_xy,(xxx),(yyy+1))) + shifting_key_full{queue_id_temp}{1};
        center_points.yyy_shift(kk,:) = center_points.yyy_shift(kk,:) + center_points.yyy_shift(sub2ind(tiling_info_xy,(xxx),(yyy+1))) + shifting_key_full{queue_id_temp}{2};
        count_tile_stitched_to = count_tile_stitched_to +1;
    end
    
    center_points.xxx_shift(kk,:) = center_points.xxx_shift(kk,:)./ count_tile_stitched_to;
    d.xxx_shift(kk,:) = center_points.xxx_shift(kk,:)./ count_tile_stitched_to;
    center_points.check_mark(kk) = 1;
    
end
%}
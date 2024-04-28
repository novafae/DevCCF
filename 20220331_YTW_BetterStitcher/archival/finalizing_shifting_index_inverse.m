
%%% shifting_key shifting_key_n z_truncate
%%% trform
%%% tiling_info.z_pixel tiling_info.x_pixel tiling_info.y_pixel
%%% tiling_info.x_overlap tiling_info.y_overlap
%%% tiling_info.x_tiles, tiling_info.y_tiles, ~, tiling_info.ch_num

tiling_info_xy = [tiling_info.x_tiles, tiling_info.y_tiles];
clear center_points
cnetertile_x = round(tiling_info.x_tiles./2);
cnetertile_y = round(tiling_info.y_tiles./2);

[center_points.xxx, center_points.yyy] = ind2sub(tiling_info_xy,find(ones(tiling_info.x_tiles, tiling_info.y_tiles)));

center_points.xxx = (center_points.xxx - cnetertile_x).*double(tiling_info.x_pixel - tiling_info.x_overlap);
center_points.yyy = (center_points.yyy - cnetertile_y).*double(tiling_info.y_pixel - tiling_info.y_overlap);

center_points.zzz_shifting = zeros(size(center_points.xxx));

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
%     center_points.zzz_shifting(kk) = 0;
    center_points.check_mark(kk) = 1;
    
end



center_points.check_mark = false(size(center_points.distance));
center_points.check_mark(tile_sorted_ind(1)) = 1;
center_points.xxx_shift = zeros([length(center_points.check_mark), tiling_info.z_pixel]);
center_points.yyy_shift = zeros([length(center_points.check_mark), tiling_info.z_pixel]);
shifting_key_full = {};

z_temp = 1:shifting_key_n;
z_temp = (z_temp-0.5).*z_truncate;
zz_temp = 1:tiling_info.z_pixel;


switch curvitting_algrithm
    case 'smooth_spline'
        fititing_profile = 1/(1 + (length(zz_temp)./smooth_index).^3./6);
        for ii = 1:length(stitching_queue)
            
            shifting_key_full{ii}{1} = csaps(z_temp,shifting_key{ii}{1},fititing_profile,zz_temp);
            shifting_key_full{ii}{2} = csaps(z_temp,shifting_key{ii}{2},fititing_profile,zz_temp);
            
        end
    case 'linear_interp'
        for ii = 1:length(stitching_queue)
            
            shifting_key_full{ii}{1} = interp1(z_temp',shifting_key{ii}{1}',zz_temp','linear', 'extrap')';
            shifting_key_full{ii}{2} = interp1(z_temp',shifting_key{ii}{2}',zz_temp','linear', 'extrap')';
            
        end
        
    otherwise
        error('curvitting_algrithm not set')
end



for kk = tile_sorted_ind(2:end)'
    
    [xxx, yyy] = ind2sub(tiling_info_xy,kk);
    count_tile_stitched_to = 0;
    if xxx - 1 >= 1 & (center_points.check_mark(sub2ind(tiling_info_xy,(xxx-1),yyy)) == 1)
        queue_id_temp = find_stitching_queue([xxx-1,yyy],[xxx,yyy],stitching_queue);
        center_points.xxx_shift(kk,:) = center_points.xxx_shift(kk,:) + center_points.xxx_shift(sub2ind(tiling_info_xy,(xxx-1),(yyy))) + shifting_key_full{queue_id_temp}{1};
        center_points.yyy_shift(kk,:) = center_points.yyy_shift(kk,:) + center_points.yyy_shift(sub2ind(tiling_info_xy,(xxx-1),(yyy))) + shifting_key_full{queue_id_temp}{2};
        count_tile_stitched_to = count_tile_stitched_to +1;
    end
    if yyy - 1 >= 1 & (center_points.check_mark(sub2ind(tiling_info_xy,(xxx),(yyy-1))) == 1)
        queue_id_temp = find_stitching_queue([xxx,yyy-1],[xxx,yyy],stitching_queue);
        center_points.xxx_shift(kk,:) = center_points.xxx_shift(kk,:) + center_points.xxx_shift(sub2ind(tiling_info_xy,(xxx),(yyy-1))) + shifting_key_full{queue_id_temp}{1};
        center_points.yyy_shift(kk,:) = center_points.yyy_shift(kk,:) + center_points.yyy_shift(sub2ind(tiling_info_xy,(xxx),(yyy-1))) + shifting_key_full{queue_id_temp}{2};
        count_tile_stitched_to = count_tile_stitched_to +1;
    end
    if xxx + 1 <= tiling_info.x_tiles & (center_points.check_mark(sub2ind(tiling_info_xy,(xxx+1),yyy)) == 1)
        queue_id_temp = find_stitching_queue([xxx,yyy],[xxx+1,yyy],stitching_queue);
        center_points.xxx_shift(kk,:) = center_points.xxx_shift(kk,:) + center_points.xxx_shift(sub2ind(tiling_info_xy,(xxx+1),(yyy))) - shifting_key_full{queue_id_temp}{1};
        center_points.yyy_shift(kk,:) = center_points.yyy_shift(kk,:) + center_points.yyy_shift(sub2ind(tiling_info_xy,(xxx+1),(yyy))) - shifting_key_full{queue_id_temp}{2};
        count_tile_stitched_to = count_tile_stitched_to +1;
    end
    if yyy + 1 <= tiling_info.y_tiles & (center_points.check_mark(sub2ind(tiling_info_xy,(xxx),(yyy+1))) == 1)
        queue_id_temp = find_stitching_queue([xxx,yyy],[xxx,yyy+1],stitching_queue);
        center_points.xxx_shift(kk,:) = center_points.xxx_shift(kk,:) + center_points.xxx_shift(sub2ind(tiling_info_xy,(xxx),(yyy+1))) - shifting_key_full{queue_id_temp}{1};
        center_points.yyy_shift(kk,:) = center_points.yyy_shift(kk,:) + center_points.yyy_shift(sub2ind(tiling_info_xy,(xxx),(yyy+1))) - shifting_key_full{queue_id_temp}{2};
        count_tile_stitched_to = count_tile_stitched_to +1;
    end
    
    center_points.xxx_shift(kk,:) = center_points.xxx_shift(kk,:)./ count_tile_stitched_to;
    d.xxx_shift(kk,:) = center_points.xxx_shift(kk,:)./ count_tile_stitched_to;
    center_points.check_mark(kk) = 1;
    
end

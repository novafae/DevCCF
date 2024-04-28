function error_out = cal_err_sub_fn(xy_shifting, tile_2_ind, tile_1_ind, shifting_key_temp)

xy_shifting = [0 0 ; xy_shifting];
error_out = sum(sqrt((xy_shifting(tile_2_ind,1) - xy_shifting(tile_1_ind,1) + shifting_key_temp(:,1)).^2 + (xy_shifting(tile_2_ind,2) - xy_shifting(tile_1_ind,2) + shifting_key_temp(:,2)).^2));
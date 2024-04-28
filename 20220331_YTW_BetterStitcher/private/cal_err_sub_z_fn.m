function error_out = cal_err_sub_z_fn(z_shifting, tile_2_ind, tile_1_ind, shifting_key_temp)

z_shifting = [0  ; z_shifting];
error_out = rssq(z_shifting(tile_2_ind) - z_shifting(tile_1_ind) - shifting_key_temp);
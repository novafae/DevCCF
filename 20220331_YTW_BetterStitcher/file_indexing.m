
lc_channel_list = dir([images_folder, '/*']);
lc_channel_list = lc_channel_list(~startsWith({lc_channel_list.name}, '.'));
lc_channel_list = lc_channel_list(cell2mat({lc_channel_list.isdir})==1);

lc_x_list = dir([lc_channel_list(1).folder, '/', lc_channel_list(1).name, '/*']); lc_x_list = lc_x_list(~startsWith({lc_x_list.name}, '.'));
lc_y_list = dir([lc_x_list(1).folder, '/', lc_x_list(1).name, '/*']); lc_y_list = lc_y_list(~startsWith({lc_y_list.name}, '.'));

lc_z_list = dir([lc_y_list(1).folder, '/', lc_y_list(1).name, '/asdasdasdasd']);
ll = 0;
while length(lc_z_list) <= 1
    ll = ll + 1;
    [ii, jj] = ind2sub([length(lc_x_list), length(lc_y_list)], ll);
    lc_z_list = dir([lc_x_list(ii).folder, '/', lc_x_list(ii).name, '/', lc_y_list(jj).name, '/*.tif*']);
end
tiling_info.z_pixel = length(lc_z_list);
read_file_name = {};
read_file_name_par = {};

lc_x_list_temp = dir([lc_channel_list(1).folder, '/', lc_channel_list(1).name, '/*']); lc_x_list_temp = lc_x_list_temp(~startsWith({lc_x_list_temp.name}, '.'));
lc_y_list_temp = dir([lc_x_list_temp(1).folder, '/', lc_x_list_temp(1).name, '/*']); lc_y_list_temp = lc_y_list_temp(~startsWith({lc_y_list_temp.name}, '.'));
tile_zero = [lc_y_list_temp(1).folder, '/', lc_y_list_temp(1).name, '/', lc_z_list(1).name];
for kk = 1:length(lc_channel_list)
    lc_x_list_temp = dir([lc_channel_list(kk).folder, '/', lc_channel_list(kk).name, '/*']); lc_x_list_temp = lc_x_list_temp(~startsWith({lc_x_list_temp.name}, '.'));
    for ii = 1:length(lc_x_list)
        lc_y_list_temp = dir([lc_x_list_temp(ii).folder, '/', lc_x_list_temp(ii).name, '/*']); lc_y_list_temp = lc_y_list_temp(~startsWith({lc_y_list_temp.name}, '.'));
        for jj = 1:length(lc_y_list)
            lc_z_list_temp = dir([lc_y_list_temp(jj).folder, '/', lc_y_list_temp(jj).name, '/*.tif*']);
            if length(lc_z_list_temp) == length(lc_z_list)
                for ll = 1:length(lc_z_list)
                    read_file_name{ii,jj,ll,kk} = [lc_y_list_temp(jj).folder, '/', lc_y_list_temp(jj).name, '/', lc_z_list(ll).name];
                end
            else
                [logi, loca] = ismember({lc_z_list(:).name} , {lc_z_list_temp(:).name});
                warning(['Repalacing', num2str(nnz(~logi)), ' missing tiles in ', lc_z_list_temp(1).folder, 'with empty tile']);
                               
                for ll = find(logi)
                    read_file_name{ii,jj,ll,kk} = [lc_y_list_temp(jj).folder, '/', lc_y_list_temp(jj).name, '/', lc_z_list(ll).name];
                end
                for ll = find(~logi)
                    read_file_name{ii,jj,ll,kk} = tile_zero;
                end
                
            end
        end
    end
end


channel_for_stitching = channel_for_stitching+1;
[ tiling_info.x_tiles, tiling_info.y_tiles, ~, tiling_info.ch_num ] = size(read_file_name);
% size(read_file_name)
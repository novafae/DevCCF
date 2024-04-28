function [xyc_min, num_channels, tiling_info] = get_xyc_lc(images_folder, x_res)


    
    lc_channel_list = dir([images_folder, '/*']);
    lc_channel_list = lc_channel_list(~startsWith({lc_channel_list.name}, '.'));
    lc_channel_list = lc_channel_list([lc_channel_list.isdir] == 1);
    lc_x_list = dir([lc_channel_list(1).folder, '/', lc_channel_list(1).name, '/*']);
    lc_x_list = lc_x_list(~startsWith({lc_x_list.name}, '.'));
    lc_x_list = lc_x_list([lc_x_list.isdir] == 1);
    lc_y_list = dir([lc_x_list(1).folder, '/', lc_x_list(1).name, '/*']);
    lc_y_list = lc_y_list(~startsWith({lc_y_list.name}, '.'));
    lc_y_list = lc_y_list([lc_y_list.isdir] == 1);
    lc_z_list = dir([lc_y_list(1).folder, '/', lc_y_list(1).name, '/*.tif*']);
    


infooo = imfinfo( [lc_z_list(1).folder, '/', lc_z_list(1).name] );

x_pixel = infooo.Width;
y_pixel = infooo.Height;
num_channels = length(lc_channel_list);


lc_x_list_num = [];
for ii = 1:length(lc_x_list)
    lc_x_list_num(ii,:) = str2num(string({lc_x_list(ii).name}));
end
lc_y_list_num = [];
for ii = 1:length(lc_y_list)
    lc_y_list_num(ii,:) = str2num(strrep(string({lc_y_list(ii).name}),'_', ' '));
end
lc_y_list_num = lc_y_list_num(:,2);

lc_z_list_num = [];
for ii = 1:length(lc_z_list)
    lc_z_list_num(ii,:) = str2num(strrep(strrep(string({lc_z_list(ii).name}),'.tif', ''),'f',''));
end


tiling_info.x_overlap = uint32(x_pixel-abs(lc_x_list_num(2)-lc_x_list_num(1))./10./x_res);
tiling_info.y_overlap = uint32(y_pixel-abs(lc_y_list_num(2)-lc_y_list_num(1))./10./x_res);

tiling_info.x_pixel = x_pixel;
tiling_info.y_pixel = y_pixel;
% tiling_info.z_pixel = length(lc_z_list);

if tiling_info.x_overlap<0 | tiling_info.y_overlap<0
    error('overlaping<0')
end
xyc_min = 0;
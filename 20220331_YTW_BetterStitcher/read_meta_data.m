temp_string = readmatrix(meta_data_file_name,'OutputType','string');
temp_number = readmatrix(meta_data_file_name,'OutputType','double');


iamge_set_folder_detail = temp_number(8:end,:);

x_pix = 2000;
y_pix = temp_number(1,2);

x_res = temp_number(1,3);
z_res = temp_number(1,4);

%clear temp_string temp_number

[~, num_channels, tiling_info]  = get_xyc_lc(images_folder, x_res);
tiling_info.x_res = x_res;
tiling_info.z_res = z_res;


zz_odd_things = unique(iamge_set_folder_detail(:,3));

iamge_set_folder_detail = iamge_set_folder_detail(ismember(iamge_set_folder_detail(:,3),zz_odd_things(1)),[1:2 4:end]);

[~,~,IC] = unique(iamge_set_folder_detail(:,1));
iamge_set_folder_detail(:,1) = IC;
[~,~,IC] = unique(iamge_set_folder_detail(:,2));
iamge_set_folder_detail(:,2) = IC;
[~,~,IC] = unique(iamge_set_folder_detail(:,3));
iamge_set_folder_detail(:,3) = IC;
% [~,~,IC] = unique(iamge_set_folder_detail(:,4));
% iamge_set_folder_detail(:,4) = IC;

iamge_set_folder_detail(:,4) = iamge_set_folder_detail(:,4) + 1;

iamge_set_folder_detail = accumarray(iamge_set_folder_detail(:,1:3), iamge_set_folder_detail(:,4));
function making_npy_files_for_w_st_lc(folder_tif, folder_npy, inverting_x_y,num_of_cores_npy)

mkdir(folder_npy);


lc_channel_list = dir([folder_tif, '/*']);
lc_channel_list = lc_channel_list(~startsWith({lc_channel_list.name}, '.'));
lc_channel_list = lc_channel_list(cell2mat({lc_channel_list.isdir})==1);

lc_x_list = dir([lc_channel_list(1).folder, '/', lc_channel_list(1).name, '/*']); lc_x_list = lc_x_list(~startsWith({lc_x_list.name}, '.'));
lc_y_list = dir([lc_x_list(1).folder, '/', lc_x_list(1).name, '/*']); lc_y_list = lc_y_list(~startsWith({lc_y_list.name}, '.'));
lc_z_list = dir([lc_y_list(1).folder, '/', lc_y_list(1).name, '/*.tif*']);
for kk = 1:length(lc_channel_list)
    lc_x_list_temp = dir([lc_channel_list(kk).folder, '/', lc_channel_list(kk).name, '/*']); lc_x_list_temp = lc_x_list_temp(~startsWith({lc_x_list_temp.name}, '.'));
    for ii = 1:length(lc_x_list)
        lc_y_list_temp = dir([lc_x_list_temp(ii).folder, '/', lc_x_list_temp(ii).name, '/*']); lc_y_list_temp = lc_y_list_temp(~startsWith({lc_y_list_temp.name}, '.'));
        parfor (jj = 1:length(lc_y_list),num_of_cores_npy)
            for ll = 1:length(lc_z_list)
                
                if ll == 1
                    read_file_name = [[lc_y_list_temp(jj).folder, '/', lc_y_list_temp(jj).name, '/', lc_z_list(ll).name]];
                    try
                        A = imread(read_file_name) ;
                    catch
                        warning([read_file_name, ' is corropted, replacing it with empty tiles, let me know if the image is not 2048'])
                        read_file_name = [[lc_y_list(1).folder, '/', lc_y_list(1).name, '/', lc_z_list(1).name]];
                        A = imread(read_file_name) ;
                    end
                    AA = zeros(size(A,1),size(A,2),length(lc_z_list),'uint16');
                    AA(:,:,1) = A;
                else
                    read_file_name = [[lc_y_list_temp(jj).folder, '/', lc_y_list_temp(jj).name, '/', lc_z_list(ll).name]];
                    try
                        AA(:,:,ll) = imread(read_file_name) ;
                    catch
                        warning([read_file_name, ' is corropted, replacing it with empty tiles'])
                    end
                end
            end
            if inverting_x_y
            else
                AA = permute(AA,[2,1,3]);
            end
            write_file_name = [folder_npy, '/',  '[', num2str(jj-1,'%02d'), ' x ',  num2str(ii-1,'%02d'), ']_C', num2str(kk-1,'%02d'), '_Zstack.npy'];
            
            writeNPY(AA,write_file_name);
            
        end
        
    end
end
end
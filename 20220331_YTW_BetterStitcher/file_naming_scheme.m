meta_data_file_name = [Sorce_folder, '/metadata.txt'];

mkdir(Working_folder)

if copy_data_to_working_drive
    disp('Copying files to working directory')
    copyfile([Sorce_folder, '/*'],[Working_folder, '/'] );
    images_folder = Working_folder;
else 
    images_folder = Sorce_folder;
end


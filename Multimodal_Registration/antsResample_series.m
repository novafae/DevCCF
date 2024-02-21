function antsResample_series(file_string, fName_contains, new_size, smoothing_sigma, convert2u16, fName_doesnotcontain)

%% User Input
% subIDs = {
%     'P14_JN0013';
%     'P14_JN0014';
%     'P14_JN0016';
%     'P14_JN0017';
%     'P14_JN0125';
%     'P14_XL1402';
%     };
% file_string = '/hpc/home/cuk476/1_DevBrain/P*/LSFM/*/2_N4BiasCorrection/nP*_OXT.nii.gz';
% % file_string='Z:\Labmembers\Corey\1_DevelopingBrain\P*\LSFM\*\2_N4BiasCorrection\*n*P*_Bg.nii.gz'
% new_size=0.05;
% smoothing_sigma=0.5;

%% Run Series Resample
files = dir(file_string);
files = files(contains({files.name}, fName_contains));
files = files(~contains({files.name}, fName_doesnotcontain));

disp({files.name})

if length(files) > 1
    ncores = Inf;
else
    ncores = 0;
end


parfor (i = 1:length(files), ncores)
    file = [files(i).folder, filesep, files(i).name];
    out_fName_exist_test = [files(i).folder, filesep, '*', extractBefore(files(i).name, '.nii'), num2str(smoothing_sigma*1000), 'um.nii*' ];
    if isempty(dir(out_fName_exist_test))
        disp(['Resampling ', file])
        antsResample(file, new_size, smoothing_sigma, convert2u16)
    else
        warning(['Skipping ', file, '. (Output already exists)' ])
    end
end
end 
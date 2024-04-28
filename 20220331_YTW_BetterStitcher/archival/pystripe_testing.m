% function [im_post_pystripe] = pystripe(input_img,sigma_background,sigma_foreground,threshold)
%
% p = inputParser;
% addOptional(p,'sigma_background',1024);
% addOptional(p,'sigma_foreground',128);
% addOptional(p,'threshold',-1);
% addOptional(p,'crossover',10);
% addOptional(p,'wavelet','db5');
% addOptional(p,'max_level',0);
% parse(p)


close all
clear
% input_img = imread('E:/20201219_KN_KN454_p14_F_GOF6_CreNeg_fos561_bg488_4x_reimage/stitched_00/Z00672_ch01.tif');
% input_img = imread('Y:\Labmembers\Jordan\JN_0175/MAX_stitched_Neurotrace_slice644.tif');
% input_img = imread('E:\KN387_stitched\stitched_00/Z01500_ch00.tif');
% input_img = imread('Y:\Yongsoo_Kim_Lab_2021\LifeCanvas_stitcheed\20201221_HB_BB50_F_24mo_C57_lectin488_artery594_pericyte647_4x_2umstp_LRsht\stitched_00/Z01424_ch01.tif');
input_img = imread('Y:\Labmembers\Yuan-Ting/neuro_trace_sample.tif');
% input_img = input_img(1:round(end./2),1:round(end./2));
input_img = single(input_img);
sigma_background = 256;
sigma_foreground = 128;
threshold = -1;
wavelet = 'db3';
crossover = 10;
max_level = 7;




if max_level == 0 
    max_level = wmaxlev(size(input_img),wavelet);
end

if threshold == -1
    threshold = multithresh(input_img,1);
    threshold = threshold(end);
end


background = input_img;
background(background>threshold) = threshold;
foreground = input_img;
foreground(foreground<threshold) = threshold;

mask = input_img >= threshold;

background_log = log(1 + background);
foreground_log = log(1 + foreground);



[background_c,background_s]  = wavedec2(background_log, max_level, wavelet);
background_approx = appcoef2(background_c,background_s,wavelet);


[foreground_c,foreground_s]  = wavedec2(foreground_log, max_level, wavelet);
foreground_approx = appcoef2(foreground_c,foreground_s,wavelet);

background_frac = sigma_background ./ size(input_img,1);
foreground_frac = sigma_foreground ./ size(input_img,1);

for ii = 1:max_level
    
    [bch,bcv,bcd] = detcoef2('all',background_c,background_s,ii);
    [fch,fcv,fcd] = detcoef2('all',foreground_c,foreground_s,ii);
    
    bch_fft = rfft(bch,[],2);
    fch_fft = rfft(fch,[],2);
    
    bs = size(bch,1) * background_frac;
    fs = size(fch,1) * foreground_frac;
    
    bg = gaussian_notch(size(bch_fft), bs);
    fg = gaussian_notch(size(fch_fft), fs);
    
    bch_filtered = irfft(bch_fft .* bg, size(bch,2),2);
    fch_filtered = irfft(fch_fft .* fg, size(fch,2),2);
    
    [crap_location_b, ~,~] = finding_crap(background_s,ii);
    [crap_location_f, ~,~] = finding_crap(foreground_s,ii);
    
    background_c(crap_location_b(1):crap_location_b(2)) = bch_filtered(:);
    foreground_c(crap_location_f(1):crap_location_f(2)) = fch_filtered(:);

end



background_log_filtered = waverec2(background_c, background_s, wavelet);
foreground_log_filtered = waverec2(foreground_c, foreground_s, wavelet);

background_filtered = exp(background_log_filtered)-1;
foreground_filtered = exp(foreground_log_filtered)-1;


z = (input_img-threshold)/crossover;
f = 1 ./ (1 + exp(-z));

img_filtered = foreground_filtered .* f + background_filtered .* (1-f);




plotting_upper = 3000;

figure; imshow(input_img, [0 plotting_upper]);
figure; imshow(img_filtered, [0 plotting_upper]);
figure; imshow(cat(3,input_img,img_filtered,input_img)./plotting_upper);

figure; imshow(img_filtered-input_img, [-plotting_upper./2 plotting_upper./2]);

% figure; imshow(background_filtered, [0 1000]);
% figure; imshow(foreground_filtered, [0 1000]);

% 
% imwrite(uint16(input_img), 'in_img.tiff');
imwrite(uint16(img_filtered), 'E:\pystripe_testing_out/mat_out_img.tiff');



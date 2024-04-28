function [img_filtered] = pystripe(input_img,varargin)

% This is adapted from pystripe / Kwanghun Chung Lab @ MIT
% and pystripe is adapted from ClearMap2 / Christoph Kirst 
%
% Trying my best to do a faithful port. 
% 'quick-lightsheet-correct' and 'nD-smooth' are not included
% Yuan-Ting Wu @ Yongsoo Kim Lab @ PSU

p = inputParser;
addParameter(p,'sigma_background',256);
addParameter(p,'sigma_foreground',128);
addParameter(p,'threshold',-1);
addParameter(p,'crossover',10);
addParameter(p,'wavelet','db3');
addParameter(p,'max_level',0);
parse(p,varargin{:})

sigma_background = p.Results.sigma_background;
sigma_foreground = p.Results.sigma_foreground;
threshold = p.Results.threshold;
crossover = p.Results.crossover; 
wavelet = p.Results.wavelet; 
max_level = p.Results.max_level; 






input_img = single(input_img);


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

background = log(1 + background);
foreground = log(1 + foreground);



[background_c,background_s]  = wavedec2(background, max_level, wavelet);
[foreground_c,foreground_s]  = wavedec2(foreground, max_level, wavelet);

background_frac = sigma_background ./ size(input_img,1);
foreground_frac = sigma_foreground ./ size(input_img,1);


for ii = 1:max_level
    
    [bch,~,~] = detcoef2('all',background_c,background_s,ii);
    [fch,~,~] = detcoef2('all',foreground_c,foreground_s,ii);
    
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



background = waverec2(background_c, background_s, wavelet);
foreground = waverec2(foreground_c, foreground_s, wavelet);

background = exp(background)-1;
foreground = exp(foreground)-1;


input_img = (input_img-threshold)/crossover;
input_img = 1 ./ (1 + exp(-input_img));

img_filtered = foreground .* input_img + background .* (1-input_img);


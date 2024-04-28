function [g_mask] = gaussian_notch(shape, sigmaa)
    n = shape(2);
    x = 0:1:(n-1);
    g = 1 - exp(-x .^ 2 / (2 .* sigmaa .^ 2));
    g_mask = repmat(g, shape(1), 1);

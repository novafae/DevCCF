import pystripe
import tifffile
import matplotlib.pyplot as plt

# input_path = 'E:/20201219_KN_KN454_p14_F_GOF6_CreNeg_fos561_bg488_4x_reimage/stitched_00/Z00672_ch01.tif'

input_path = 'E:\pystripe_testing/vess.tif'

input_img = tifffile.imread(input_path)

# filter a single image
fimg = pystripe.filter_streaks(input_img, sigma=[128, 256], level=7, wavelet='db3')



#plt.imshow(input_img, clim=[0, 1200])
#plt.imshow(fimg, clim=[0, 1200])


tifffile.imwrite('E:\pystripe_testing_out/py_temp_vess.tif', fimg)

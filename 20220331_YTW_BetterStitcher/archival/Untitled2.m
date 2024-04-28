
for  total_wab_queue = 1:(shifting_key_n.*length(stitching_queue))
    [kk, mm] = ind2sub([length(stitching_queue), shifting_key_n], total_wab_queue);
    
    asdasdasd = trform_2_pfor{total_wab_queue};
    asdasdasd = flip(asdasdasd);
    if rssq(asdasdasd)>5
    img_temp_1_max = image_observatory{total_wab_queue}{1};
    img_temp_2_max = image_observatory{total_wab_queue}{2};

    imge_show_temp{total_wab_queue} = zeros([(size(img_temp_1_max)+[100 100]), 3]);

    imge_show_temp{total_wab_queue}(round(asdasdasd(1))+50+1:round(asdasdasd(1))+50+size(img_temp_1_max,1),round(asdasdasd(2))+50+1:round(asdasdasd(2))+50+size(img_temp_1_max,2),1) = img_temp_1_max;
    imge_show_temp{total_wab_queue}(50+1:50+size(img_temp_2_max,1),50+1:50+size(img_temp_2_max,2),2) = img_temp_2_max;
    
    figure;imshow(imge_show_temp{total_wab_queue}./2000);
    
    end
    
end

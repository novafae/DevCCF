for  total_wab_queue = 1:(shifting_key_n.*length(stitching_queue))
    if mod(total_wab_queue,20) == 0
         img_temp_1_max = image_observatory{total_wab_queue}{1};
        img_temp_2_max = image_observatory{total_wab_queue}{2};
        if all(~isnan(trform_2_pfor{total_wab_queue}))
        img_temp_1_max = imtranslate(img_temp_1_max,trform_2_pfor{total_wab_queue});
        figure;imshowpair(img_temp_1_max, img_temp_2_max,'Scaling','joint');
        else
%         figure;imshowpair(img_temp_1_max, img_temp_2_max,'Scaling','joint');
        end
    end
       
end

thresh_hold_percent_0 =0.15;
fititing_profile = 0.8;

intensity_profile_max = 0;
for kk = find([stitching_queue(:).max_direction] == 1)
    intensity_profile_max = max([intensity_profile_max,intensity_profile{kk}]) ;
end


shifting_key = {};

for kk = find([stitching_queue(:).max_direction] == 1)
    temp = [];
    for ll = 1:length( trform_2{kk} )
        temp(ll) = trform_2{kk}{ll}(1);
    end
    temp( intensity_profile{kk} < intensity_profile_max.*thresh_hold_percent_0) = nan;
    shifting_key{kk}{1} = temp;
end

for kk = find([stitching_queue(:).max_direction] == 1)
    temp = [];
    for ll = 1:length( trform_2{kk} )
        temp(ll) = trform_2{kk}{ll}(2);
    end
    temp( intensity_profile{kk} < intensity_profile_max.*thresh_hold_percent_0) = nan;
    shifting_key{kk}{2} = temp;
end


intensity_profile_max = 0;

for kk = find([stitching_queue(:).max_direction] == 2)
    intensity_profile_max = max([intensity_profile_max,intensity_profile{kk}]) ;
end


for kk = find([stitching_queue(:).max_direction] == 2)
    temp = [];
    for ll = 1:length( trform_2{kk} )
        temp(ll) = trform_2{kk}{ll}(1);
    end
    temp( intensity_profile{kk} < intensity_profile_max.*thresh_hold_percent_0) = nan;
    shifting_key{kk}{1} = temp;
end


for kk = find([stitching_queue(:).max_direction] == 2)
    temp = [];
    for ll = 1:length( trform_2{kk} )
        temp(ll) = trform_2{kk}{ll}(2);
    end
    temp( intensity_profile{kk} < intensity_profile_max.*thresh_hold_percent_0) = nan;
    shifting_key{kk}{2} = temp;
end

for kk = 1:length(stitching_queue)
    while  ~(nnz(isnan(shifting_key{kk}{1})) == 0)
        for jj = 1:shifting_key_n-1
            if (isnan(shifting_key{kk}{1}(jj))) & (~isnan(shifting_key{kk}{1}(jj+1)))
                shifting_key{kk}{1}(jj) = shifting_key{kk}{1}(jj+1);
            end
            if (isnan(shifting_key{kk}{1}(jj+1))) & (~isnan(shifting_key{kk}{1}(jj)))
                shifting_key{kk}{1}(jj+1) = shifting_key{kk}{1}(jj);
            end
        end
    end
    while  ~(nnz(isnan(shifting_key{kk}{2})) == 0)
        for jj = 1:shifting_key_n-1
            if (isnan(shifting_key{kk}{2}(jj))) & (~isnan(shifting_key{kk}{2}(jj+1)))
                shifting_key{kk}{2}(jj) = shifting_key{kk}{1}(jj+1);
            end
            if (isnan(shifting_key{kk}{2}(jj+1))) & (~isnan(shifting_key{kk}{2}(jj)))
                shifting_key{kk}{2}(jj+1) = shifting_key{kk}{2}(jj);
            end
        end
    end
end




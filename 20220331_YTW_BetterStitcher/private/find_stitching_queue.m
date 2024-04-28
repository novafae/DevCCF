function   queue_id = find_stitching_queue(pair_1,pair_2,stitching_queue)

queue_id = nan;
for ii = find(logical([stitching_queue(:).max_direction]))
    if isequal(pair_1,stitching_queue(ii).tile_1) & isequal(pair_2,stitching_queue(ii).tile_2)
        queue_id = ii;
    end
end
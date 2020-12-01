%function to organize and filter icesat-2 water level data
%inputs:
%water_data = structure of outputs from get_IS2_water_data_nov20 function,
%contains all ICESat-2 heights
%merit_heights = water levels from MERIT dataset
%extent = area of water body divided by area of bounding box
%goodd_res = reservoir/not-reservoir (as defined by GOODD)
%lake_area = lake area
%outputs:
%complete_output = structure of all results

function [complete_output] = organize_IS2_data_nov20(water_data,merit_heights,extent,goodd_res,lake_area)

    mask_ids = [water_data.mask_id];
    unique_mask_ids = unique(mask_ids);
    
    %STEP 1: loop through unique water bodies
    for i = 1:length(unique_mask_ids)
        ind = find(mask_ids == unique_mask_ids(i));
        complete_output(i).mask_id = unique_mask_ids(i);
        complete_output(i).area = lake_area(unique_mask_ids(i));
        complete_output(i).extent = extent(unique_mask_ids(i));
        complete_output(i).goodd_res = goodd_res(unique_mask_ids(i));
        complete_output(i).flag = 0;
        c1 = 1;
        clear heights stds xpts ypts dates years months
    %STEP 2: loop through observations for each water body and filter
        for j = 1:length(ind)
            jj = ind(j);
            if water_data(jj).std < 0.25 && water_data(jj).num_points >= 3 && water_data(jj).height < 8000 && water_data(jj).height > -15
                complete_output(i).flag = 1;
                heights(c1,1) = water_data(jj).height;
                stds(c1,1) = water_data(jj).std;
                raw_x = water_data(jj).raw_x_pts;
                raw_y = water_data(jj).raw_y_pts;
                D = pdist([raw_x,raw_y]);
                D = squareform(D);
                D = mean(D,2);
                [~,aa] = min(D);
                xpts(c1,1) = water_data(jj).raw_x_pts(aa(1));
                ypts(c1,1) = water_data(jj).raw_y_pts(aa(1));
                dates(c1,1) = water_data(jj).doy;
                months(c1,1) = water_data(jj).month;
                years(c1,1) = water_data(jj).year;
                c1 = c1+1;
            end
        end
        
        if complete_output(i).flag == 1
            ht = std(heights);
            IP = heights <= 3*ht + heights & heights >= heights - 3*ht;
            complete_output(i).med_height = median(heights(IP));
            complete_output(i).mean_height = mean(heights(IP));
            complete_output(i).height_range = max(heights(IP)) - min(heights(IP));
            complete_output(i).std = mean(stds(IP));
            xp = xpts(IP);
            yp = ypts(IP);
            if length(xp) > 1
                D = pdist([xp,yp]);
                D = squareform(D);
                D = mean(D,2);
                [~,aa] = min(D);
                complete_output(i).lon = median(xp(aa(1)));
                complete_output(i).lat = median(yp(aa(1)));
            else
                complete_output(i).lon = xp;
                complete_output(i).lat = yp;
            end
            complete_output(i).heights = heights(IP);
            complete_output(i).stds = stds(IP);
            complete_output(i).doys = dates(IP);
            complete_output(i).months = months(IP);
            complete_output(i).years = years(IP);
            complete_output(i).num_obs = length(heights(IP));
        end
    end
    
      %STEP 3: remove empty lakes
        flag = [complete_output.flag];
        I = flag == 0;
        complete_output(I) = [];
        
       %STEP 4: add merit height
       if isempty(complete_output) == 0
       mask_ids = [complete_output.mask_id];
       lat = [complete_output.lat];
       lon = [complete_output.lon];
       for i = 1:length(lon)
           if lon(i) < 0; lon(i) = lon(i) + 360; end
       end
       geoidoffset = geoidheight(lat,lon,'EGM96');
       for i = 1:length(complete_output)
            complete_output(i).merit_height = merit_heights(mask_ids(i)).height + geoidoffset(i);
            complete_output(i).merit_std = merit_heights(mask_ids(i)).std;
            complete_output(i).geoid_offset = geoidoffset(i);
       end
       end
end
    
%function to read in ICESat-2 ATL08 data and intersect with water mask
%inputs:
%mask = water mask
%metadata = ICESat-2 metadata, used to enable quick filtering through
%ICESat-2 data
%R = GeographicCellsReference of water mask
%outputs:
%water_data = structure with all resulting ICESat-2 heights
%count = number of water bodies identified

function [water_data,count] = get_IS2_water_data_nov20(mask,metadata,R)
    LonLimits = R.LongitudeLimits;
    LatLimits = R.LatitudeLimits;    
    water_data(1).id = 1;
    cd('/Volumes/Extreme SSD/0_IS2_testing/icesat2_data_version3');
	count = 1;

 %STEP 1: loop through ICESat-2 metadata
    for n = 1:length(metadata)
        if metadata(n).lon_min < LonLimits(2) && metadata(n).lon_max > LonLimits(1) && metadata(n).lat_min < LatLimits(2) && metadata(n).lat_max > LatLimits(1)
            lasers = metadata(n).lasers;
            filename = metadata(n).filename;
            for k = 1:length(lasers)
                lon = h5read(filename,[lasers(k).Name '/land_segments/longitude']);
                lat = h5read(filename,[lasers(k).Name '/land_segments/latitude']);
  
  %STEP 2: Read in height data, get coordinates
                [I,J] = geographicToDiscrete(R,lat,lon);
                if sum(isnan(I)) < length(I)
                     elev = h5read(filename,[lasers(k).Name '/land_segments/terrain/h_te_mean']);
                     terrain_flag = h5read(filename,[lasers(k).Name '/land_segments/terrain_flg']);
                     uncertainty = h5read(filename,[lasers(k).Name '/land_segments/terrain/h_te_uncertainty']);
                     
                     elev(isnan(I)) = [];
                     lat(isnan(I)) = [];
                     lon(isnan(I)) = [];
                     terrain_flag(isnan(I)) = [];
                     uncertainty(isnan(I)) = [];
                     
                     I(isnan(I) == 1) = [];
                     J(isnan(J) == 1) = [];
                     
                     lat = double(lat);
                     lon = double(lon);
                     elev = double(elev);
                     
   %STEP 3: Get mask values
                    mask_val = zeros(length(I),1);
                        for i = 1:length(I)
                            mask_val(i,1) = mask(I(i),J(i));
                        end
                    year = metadata(n).year;
                    month = metadata(n).month;
                    day = metadata(n).day;
                    doy = calendar_to_doy(month,day,year);
                    
                    
    %STEP 4: process heights
                    unique_bodies = unique(mask_val);
                    if length(unique_bodies) > 1
                        unique_bodies = double(unique_bodies);
                        for i = 2:length(unique_bodies)
                            ind = find(mask_val == unique_bodies(i));
                            if length(ind) > 2
                            water_data(count).id = count;
                            water_data(count).mask_id = unique_bodies(i);
                            water_data(count).raw_num_points = length(ind);
                            water_data(count).raw_x_pts  = lon(ind);
                            water_data(count).raw_y_pts = lat(ind);
                            water_data(count).raw_heights = elev(ind);
                            water_data(count).terrain_flag = terrain_flag(ind);
                            water_data(count).uncertainty = uncertainty(ind);
                            heights = elev(ind);
                            p90 = prctile(heights,90);
                            p10 = prctile(heights,10);
                            all_X = lon(ind);
                            all_Y = lat(ind);
                            I = heights > p90 | heights < p10;
                            all_X(I) = [];
                            all_Y(I) = [];
                            heights(I) = [];
                            water_data(count).height = median(heights);
                            water_data(count).std = std(heights);
                            water_data(count).num_points = length(heights);
                            water_data(count).med_x = median(all_X);
                            water_data(count).med_y = median(all_Y);
                            water_data(count).laser = lasers(k).Name;
                            water_data(count).doy = doy;
                            water_data(count).month = month;
                            water_data(count).year = year;
                            water_data(count).filename = filename;
                            count = count + 1;
                            end
                        end
                    end
                end
            end
        end
    end
end
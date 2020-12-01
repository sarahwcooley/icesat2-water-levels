%function to process GSWO water mask and identify goodd reservoirs
%inputs: 
%mask = GSWO water mask
%R = GeographicCellsReference for GSWO water mask
%glon = longitude of goodd dams
%glat = latitude of goodd dams
%coast = coast shapefile (for removing coastal areas)
%edit = set to 1 for tile containing great lakes (to ensure great lakes are
%separate water bodies)
%outputs:
%mask_l = labeled water mask
%lake_area = vector containing lake areas corresponding to mask_l
%goodd_res = vector indicating which water bodies in mask_l are reservoirs
%lat = latitude of centroid of lakes in mask_l
%lon = longitude of centroid of lakes in mask_l
%extent = extent (i.e. area divided by area of bounding box) of lakes in
%mask_l


function [mask_l,lake_area,goodd_res,lat,lon,extent] = label_mask_and_identify_goodd_nov20(mask,R,glon,glat,coast,edit)
    
%STEP 1: only get mask water where > 75% occurrence
    LonLimits = R.LongitudeLimits;
    LatLimits = R.LatitudeLimits;  
    ind_coast = zeros(length(coast),1);
    for p = 1:length(coast)
        bb = coast(p).BoundingBox;
        if bb(1,1) < LonLimits(2) && bb(1,2) < LatLimits(2) && bb(2,1) > LonLimits(1)&& bb(2,2) > LatLimits(1) 
            ind_coast(p,1) = 1;
        end
    end
    coast(ind_coast == 0) = [];
    mask(mask < 75) = 0;
    mask(mask == 255) = 0;
    mask(mask > 1) = 1;
    mask = uint8(mask);
   if edit == 1
        %manual correction for separating great lakes into different water bodies
        mask(13924:14008, 22545:22635) = 0;
        mask(30698:30883, 27495:27911) = 0;
        mask(28528:29102, 29695:30535) = 0;
   end
    

%STEP 2: identify reservoirs by dilating GOODD dam points and intersecting
%with water mask
    disp('identifying reservoirs...');   
    se = strel('disk',6,4);
    res_mask = imdilate(mask,se); %dilate water mask by 6 pixels for intersection
    ind = find(glon <= LonLimits(2) & glon >= LonLimits(1) & glat <= LatLimits(2) & glat >= LatLimits(1));
    glon = glon(ind);
    glat = glat(ind);
    
    %convert lat/lon points of dams to grid, create dam mask
    [I,J] = geographicToDiscrete(R,glat,glon);
    r_mask = zeros(size(mask));
    for p = 1:length(I)
        r_mask(I(p),J(p)) = 1;
    end
    
    %dilate dam mask
    disp('dilating dam mask...');
    se = strel('disk',6,4);
    r_mask = imdilate(r_mask,se);
    r_mask = imdilate(r_mask,se);
    r_mask = imdilate(r_mask,se);
    r_mask = imdilate(r_mask,se);
    r_mask = imdilate(r_mask,se);
    r_mask = imdilate(r_mask,se);
    res_mask = bwlabel(res_mask);
    
    %create reservoir mask for intersection with data
    disp('finding reservoirs...');
    stats = regionprops(res_mask,r_mask,'MaxIntensity');
    idx = find([stats.MaxIntensity] == 1);
    res_mask_out = ismember(res_mask,idx);
    res_mask_out = double(res_mask_out);
    
    
 
%STEP 3: erode mask, remove coastline
    disp('eroding and labeling mask...');
    se = strel('disk',1,4);
    mask = imerode(mask,se);
    mask_l = bwlabel(mask);
    stats = regionprops(mask_l,'Extent','Area');
    idx = find([stats.Extent] > 0.05 & [stats.Area] > 20); %remove water bodies with an extent less than 0.05 and area less than 20 pixels (prior to erosion)
    mask = ismember(mask_l,idx);
    mask_l = bwlabel(mask);
    
    %remove coastline
    disp('removing coastline...');
    stats = regionprops(mask_l,'PixelList');
    test_ocean = zeros(length(stats),1);
    for p = 1:length(stats)
       vert = stats(p).PixelList;
       if length(vert) > 5000
           vert = vert(1:6:end,:);
       else
           vert = vert(1:3:end,:);
       end
       [latt,lonn] = pix2latlon(R,vert(:,2),vert(:,1));
       vert = [lonn,latt];
         for i = 1:length(coast)
            edge = [coast(i).X',coast(i).Y'];
            inp_all = inpoly2(vert,edge);
            if sum(inp_all) == 0
                inp_all = zeros(length(vert),1);
            end
    
            if i == 1
                basins = inp_all;
            else
                basins = basins + inp_all;
            end
         end
         basins(basins > 1) = 1;
         if sum(basins) < .9*length(basins)
             test_ocean(p,1) = 0;
         else
             test_ocean(p,1) = 1;
         end     
    end
    idx = find(test_ocean == 1);
    mask = ismember(mask_l,idx);
    
    
    %erode water mask
    mask_l = bwlabel(mask);
    se = strel('disk',1,4);
    mask = imerode(mask,se);
    mask_l(mask == 0) = 0;
    clear mask
    
    
    
%STEP 3: reduce size
    m = max(max(mask_l));
    if m < 256
       mask_l = uint8(mask_l);
    end

    if m >= 256 && m < 65536
       mask_l = uint16(mask_l);
    end

    if m >= 65536
       mask_l = uint32(mask_l);
    end
    
    
%STEP 4: identify goodd reservoirs

    stats = regionprops(mask_l,res_mask_out,'MaxIntensity','Area','Centroid','Extent');
    X = 0;
    Y = 0;
    lake_area = 0;
    extent = 0;
    goodd_res = 0;
    for j = 1:length(stats)
        X(j,1) = stats(j).Centroid(1);
        Y(j,1) = stats(j).Centroid(2);
        lake_area(j,1) = 10^-6*30*30*stats(j).Area;
        extent(j,1) = stats(j).Extent;
        if isempty(stats(j).MaxIntensity) == 0
            goodd_res(j,1) = stats(j).MaxIntensity;
        else
            goodd_res(j,1) = NaN;
        end
    end
    if X(1) ~= 0 && Y(1) ~= 0 && length(X) > 1
        [lat,lon] = pix2latlon(R,Y,X);
    else
        lat = 0;
        lon = 0;
    end

end
    
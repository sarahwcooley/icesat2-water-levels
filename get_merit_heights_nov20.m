%function to get heights from the MERIT hydrography dataset
%inputs:
%mask_metadata = used to identify filenames
%labeled = water mask

function merit_heights = get_merit_heights_nov20(mask_metadata,labeled)
        
    lonnum = mask_metadata.lon;
    latnum = mask_metadata.lat;
    
    if latnum == 0; mask_metadata.ns = 'S'; end
    
    %get folderlon
    if mask_metadata.ew == 'W'
        if lonnum <= 30; folderlon = 'w030'; end
        if lonnum > 30 && lonnum <= 60; folderlon = 'w060'; end
        if lonnum > 60 && lonnum <= 90; folderlon = 'w090'; end
        if lonnum > 90 && lonnum <= 120; folderlon = 'w120'; end
        if lonnum > 120 && lonnum <= 150; folderlon = 'w150'; end
        if lonnum > 150; folderlon = 'w180'; end
    else
        if lonnum < 30; folderlon = 'e000'; end
        if lonnum >= 30 && lonnum < 60; folderlon = 'e030'; end
        if lonnum >= 60 && lonnum < 90; folderlon = 'e060'; end
        if lonnum >= 90 && lonnum < 120; folderlon = 'e090'; end
        if lonnum >= 120 && lonnum < 150; folderlon = 'e120'; end
        if lonnum >= 150; folderlon = 'e150'; end
    end
    
    %get folderlat
    if mask_metadata.ns == 'N'
        if latnum > 60; folderlat = 'n60'; end
        if latnum <= 60 && latnum > 30; folderlat = 'n30'; end
        if latnum <= 30; folderlat = 'n00'; end
    else
        if latnum < 30; folderlat = 's30'; end
        if latnum >= 30; folderlat = 's60'; end
    end

    %cd to merit folder
     merit_folder = ['/Volumes/Extreme SSD/MERIT_Hydro/elv_' folderlat folderlon ];
     cd(merit_folder);
        
        %read in elev1
        if mask_metadata.ew == 'W';  l = lonnum-5; ew = 'w'; end
        if mask_metadata.ew == 'E';  l = lonnum+5; ew ='e'; end
        if l < 10; lonstr = ['00' num2str(l)]; end
        if l >= 10 && l < 100; lonstr = ['0' num2str(l)]; end
        if l >= 100; lonstr = num2str(l); end
        
        if mask_metadata.ns == 'N'; la = latnum-10; ns = 'n'; end
        if mask_metadata.ns == 'S'; la = latnum+10; ns = 's'; end
        if la < 10; latstr = ['0' num2str(la)]; end
        if la >= 10; latstr = num2str(la); end
        
        e1 = dir([ns latstr ew lonstr '_elv.tif']);
        if isempty(e1) == 0
            [elev1,R1] = geotiffread(e1(1).name);
        else
            elev1 = -9999*zeros(6000,6000);
        end
        
        %read in elev2
        if mask_metadata.ew == 'W';  l = lonnum; ew = 'w'; end
        if mask_metadata.ew == 'E';  l = lonnum; ew ='e'; end
        if l < 10; lonstr = ['00' num2str(l)]; end
        if l >= 10 && l < 100; lonstr = ['0' num2str(l)]; end
        if l >= 100; lonstr = num2str(l); end
        
        if mask_metadata.ns == 'N'; la = latnum-10; ns = 'n'; end
        if mask_metadata.ns == 'S'; la = latnum+10; ns = 's'; end
        if la < 10; latstr = ['0' num2str(la)]; end
        if la >= 10; latstr = num2str(la); end
        
        e2 = dir([ns latstr ew lonstr '_elv.tif']);
        if isempty(e2) == 0
            [elev2,R1] = geotiffread(e2(1).name);
        else
            elev2 = -9999*zeros(6000,6000);
        end
        
        %read in elev3
        if mask_metadata.ew == 'W';  l = lonnum-5; ew = 'w'; end
        if mask_metadata.ew == 'E';  l = lonnum+5; ew ='e'; end
        if l < 10; lonstr = ['00' num2str(l)]; end
        if l >= 10 && l < 100; lonstr = ['0' num2str(l)]; end
        if l >= 100; lonstr = num2str(l); end
        
        if mask_metadata.ns == 'N'; la = latnum-5; ns = 'n'; end
        if mask_metadata.ns == 'S'; la = latnum+5; ns = 's'; end
        if la < 10; latstr = ['0' num2str(la)]; end
        if la >= 10; latstr = num2str(la); end
        
        e3 = dir([ns latstr ew lonstr '_elv.tif']);
        if isempty(e3) == 0
            [elev3,R1] = geotiffread(e3(1).name);
        else
            elev3 = -9999*zeros(6000,6000);
        end
        
        %read in elev4
        if mask_metadata.ew == 'W';  l = lonnum; ew = 'w'; end
        if mask_metadata.ew == 'E';  l = lonnum; ew ='e'; end
        if l < 10; lonstr = ['00' num2str(l)]; end
        if l >= 10 && l < 100; lonstr = ['0' num2str(l)]; end
        if l >= 100; lonstr = num2str(l); end
        
        if mask_metadata.ns == 'N'; la = latnum-5; ns = 'n'; end
        if mask_metadata.ns == 'S'; la = latnum+5; ns = 's'; end
        if la < 10; latstr = ['0' num2str(la)]; end
        if la >= 10; latstr = num2str(la); end
        
        e4 = dir([ns latstr ew lonstr '_elv.tif']);
        if isempty(e4) == 0
            [elev4,R1] = geotiffread(e4(1).name);
        else
            elev4 = -9999*zeros(6000,6000);
        end
        
   

        elev12 = cat(2,elev2,elev1);
        elev34 = cat(2,elev4,elev3);
        elev = cat(1,elev34,elev12);
        %imshow(elev,[0 1000]);
        %pause

        clear elev1 elev2 elev3 elev4  elev12 elev34
        elev_r = imresize(elev,[40000 40000],'nearest');
        stats = regionprops(labeled,elev_r,'PixelValues');
        for j = 1:length(stats)
            px = stats(j).PixelValues;
            p90 = prctile(px,90);
            p10 = prctile(px,10);
            px(px > p90) = [];
            px(px < p10) = [];
            merit_heights(j).height = median(px);
            merit_heights(j).std = std(px);
            merit_heights(j).mean = mean(px);
        end
            
        
end
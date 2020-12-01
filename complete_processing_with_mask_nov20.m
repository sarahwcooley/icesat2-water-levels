%script to process masks and ICESat-2 data
%requires ICESat-2 metadata to be processed and GSWO water masks and MERIT
%hydrography datasets to be downloaded

%load in ATL08 metadata
cd('/Volumes/Extreme SSD/0_IS2_testing');
load('atl_metadata_v2_Oct21.mat');   

%get list of GSWO water masks
cd('/Volumes/Extreme SSD/PermaLakes/water_masks');
filenames = dir('*1.tif');
bytes = [filenames.bytes];
filenames(bytes < 10000) = [];

%read in GOODD dam dataset
cd('/Volumes/Extreme SSD/GOODD/Data');
good = shaperead('GOOD2_dams_flat.shp');
glat = [good.Latitud]';
glon = [good.Longitud]';

%read in coastline
cd('/Volumes/Extreme SSD/GOODD/gshhg-shp-2.3.7/GSHHS_shp/i');
coast = shaperead('GSHHS_i_L1.shp');

%loop through GSWO water masks
for n = 1:length(filenames)

    %STEP 1: CREATE WATER MASK
    cd('/Volumes/Extreme SSD/PermaLakes/water_masks');    
    disp('reading in mask...');
    [mask,~,R] = geotiffread(filenames(n).name);
    info = geotiffinfo(filenames(n).name);
    edit = 0;
    [mask_l,lake_area,goodd_res,lat,lon,extent] = label_mask_and_identify_goodd_nov20(mask,R,glon,glat,coast,edit); %creates water mask, identifies goodd reservoirs
    if lat(1) ~= 0 || length(lat) > 1
    output_name1 = [filenames(n).name(1:end-5) 'labeled.tif'];
    output_name2 = [filenames(n).name(1:end-5) 'stats.mat'];
    
    disp('writing mask...');
    cd('/Volumes/Extreme SSD/global_masks_labeled_Oct23/');
    geotiffwrite(output_name1,mask_l,R,'GeoKeyDirectoryTag',info.GeoTIFFTags.GeoKeyDirectoryTag);
    save(output_name2,'lake_area','goodd_res','lat','lon','extent');
    disp([filenames(n).name]);

    %STEP 2: GET HEIGHT FROM MERIT HYDROGRAPHY DATASET
    disp('getting merit heights...');
    mask_metadata = get_mask_metadata_func_nov20(filenames(n).name); %gets filename characteristics
    merit_heights = get_merit_heights_nov20(mask_metadata,mask_l); %reads in MERIT heights
    cd('/Volumes/Extreme SSD/global_masks_labeled_Oct23/');
    output_name = ['merit_heights_' mask_metadata.lonstr mask_metadata.ew '_' mask_metadata.latstr mask_metadata.ns '_v1.mat'];
    save(output_name,'merit_heights');

    %STEP 3: READ IN ICESAT-2 DATA
    disp('reading in IS2...');   
    [water_data,count] = get_IS2_water_data_nov20(mask_l,metadata,R); %intersects ICESat-2 data with water mask
    
    %STEP 4: ORGANIZE ICESAT-2 DATA BY WATER BODY
    disp('organizing IS2...');
    if count > 1
        [complete_output] = organize_IS2_data_nov20(water_data,merit_heights,extent,goodd_res,lake_area); %organizes ICESat-2 data to individual water bodies
        if isempty(complete_output) == 0
        cd('/Volumes/Extreme SSD/0_IS2_testing/results_v4_Oct25/');
        output_name = ['results_' mask_metadata.lonstr mask_metadata.ew '_' mask_metadata.latstr mask_metadata.ns '_v1.mat'];
        save(output_name,'complete_output','water_data'); %save ICESat-2 data
        end
    end
    end
    disp(['Finished ' output_name ' ' num2str(n) ' of ' num2str(length(filenames))]);
    clear mask_l complete_output water_data merit_heights
end



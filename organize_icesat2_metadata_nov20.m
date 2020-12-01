%create metadata file with information on spatial boundaries of ICESat-2
%enables much faster processing of ICESat-2 data

%STEP 1: loop through all ICESat-2 height data (.h5 files)
cd('/Volumes/Extreme SSD/0_IS2_testing/icesat2_data_version3');
filenames = dir('*h5');
bytes = [filenames.bytes];
filenames(bytes < 10000) = [];
clear bytes
count = 1;
cd('/Volumes/Extreme SSD/');
for n = 1:length(filenames) %length(filenames)
    
%STEP 2: loop through lasers, read in data
    info = h5info(['/Volumes/Extreme SSD/0_IS2_testing/icesat2_data_version3/' filenames(n).name]);
    metadata(count).filename = filenames(n).name;
    metadata(count).lon_min = info.Attributes(48).Value; %note these numbers change based on data version, check!!
    metadata(count).lon_max = info.Attributes(29).Value;
    metadata(count).lat_min = info.Attributes(43).Value;
    metadata(count).lat_max = info.Attributes(20).Value;    
    metadata(count).year = str2num(filenames(n).name(17:20));
    metadata(count).month = str2num(filenames(n).name(21:22));
    metadata(count).day = str2num(filenames(n).name(23:24));
    lasers = info.Groups;
    lasers(1) = [];
    for k = 1:length(lasers)
        laser_out(k).Name = lasers(k).Name;
    end
    metadata(count).lasers = laser_out;
    clear laser_out info lasers
    count = count + 1;
    disp(['Finished ' num2str(n) ' of ' num2str(length(filenames))]);
    close all
 
end
cd('/Volumes/Extreme SSD/0_IS2_testing');
save('atl_metadata_v2_Oct21.mat','metadata');


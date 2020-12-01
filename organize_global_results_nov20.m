%organize and filter all output to combine into one dataset

year_mat = [2018 2018 2018 2019 2019 2019 2019 2019 2019 2019 2019 2019 2019 2019 2019 2020 2020 2020 2020 2020 2020 2020];
month_mat = [10 11 12 1 2 3 4 5 6 7 8 9 10 11 12 1 2 3 4 5 6 7];
cd('//Volumes/Extreme SSD/0_IS2_testing/results_v4_Oct25');

%STEP 1: loop through all results
files = dir('results*v1.mat');
for i = 1:length(files)
    load(files(i).name);
    c = complete_output;
    extent1 = [c.extent]';
    std_height1 = [c.std]';
    merit_height1 = [c.merit_height]';
    med_height1 = [c.med_height]';
    num_obs1 = [c.num_obs]';
    
    test_number(i,1) = length(num_obs1);
    %STEP 2: filter based on extent, standard deviation and height (to
    %remove outliers)
    I = extent1 > 0.05 & std_height1 < 0.25 & ...
        merit_height1 > -100 & med_height1 > -100 & med_height1 < 8000;
    
        
    test_number(i,2) = sum(I == 0);
    c = c(I);
    mask_id1 = [c.mask_id]';
    grid_no1 = i*ones(size(mask_id1));
    area1 = 10^6*[c.area]';
    extent1 = [c.extent]';
    std_height1 = [c.std]';
    merit_std1 = [c.merit_std]';
    merit_height1 = [c.merit_height]';
    med_height1 = [c.med_height]';
    num_obs1 = [c.num_obs]';  
    mean_height1 = [c.mean_height]';
    height_range1 = [c.height_range]';
    lat1 = [c.lat]';
    lon1 = [c.lon]';
    goodd_res1 = [c.goodd_res]';
    
    ip = 1;
    for pp = 1:length(c)
    c_out(pp).height = c(pp).heights;
    c_out(pp).date = c(pp).doys;
    c_out(pp).std = c(pp).std;
    c_out(pp).year = c(pp).years;
    ip = 0;
    end
    
   %STEP 3: organize monthly data
    monthly_heights1 = zeros(length(lat1),22);
    monthly_stds1 = zeros(length(lat1),22);
    %get monthly data
    for n= 1:length(c)
        heights = c(n).heights;
        stds = c(n).stds;
        months = c(n).months;
        years = c(n).years;
        for j = 1:length(month_mat)
            I = months == month_mat(j) & years == year_mat(j);
            if sum(I) >= 1
            monthly_heights1(n,j) = mean(heights(I));
            monthly_stds1(n,j) = mean(stds(I));
            end
        end
    end
    
    
    %STEP 4: organize complete results
    if i == 1
        area = area1;
        extent = extent1;
        std_height = std_height1;
        merit_std = merit_std1;
        merit_height = merit_height1;
        med_height  = med_height1 ;
        num_obs = num_obs1;  
        mean_height = mean_height1;
        height_range = height_range1;
        lat = lat1;
        lon = lon1;
        monthly_heights = monthly_heights1;
        monthly_stds = monthly_stds1;
        heights_dates = c_out;
        mask_id = mask_id1;
        grid_no = grid_no1;
        goodd_res = goodd_res1;
    else
        area = cat(1,area,area1);
        extent = cat(1,extent,extent1);
        std_height = cat(1,std_height,std_height1);
        merit_std = cat(1,merit_std,merit_std1);
        merit_height = cat(1,merit_height,merit_height1);
        med_height  = cat(1,med_height,med_height1);
        num_obs = cat(1,num_obs,num_obs1);  
        mean_height = cat(1,mean_height,mean_height1);
        height_range = cat(1,height_range,height_range1);
        lat = cat(1,lat,lat1);
        lon = cat(1,lon,lon1);
        monthly_heights = cat(1,monthly_heights,monthly_heights1);
        monthly_stds = cat(1,monthly_stds,monthly_stds1);
        goodd_res = cat(1,goodd_res,goodd_res1);
        mask_id = cat(1,mask_id,mask_id1);
        grid_no = cat(1,grid_no,grid_no1);
        if ip == 0
        heights_dates = cat(2,heights_dates,c_out);
        end
    end
    clear c_out
end
save('complete_results_Nov10.mat','area','extent','std_height','merit_std','merit_height','med_height','num_obs','mean_height',...
    'height_range','lat','lon','monthly_heights','monthly_stds','heights_dates','mask_id','grid_no','goodd_res');

    
    
        
    
    
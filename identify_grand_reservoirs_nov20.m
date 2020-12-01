%script to read in the GRanD reservoir dataset and intersect with existing
%water bodies

cd('/Volumes/Extreme SSD/0_IS2_testing/results_v4_Oct25');
load('complete_results_nov16.mat');

cd('/Volumes/Extreme SSD/GRaND');
grand = shaperead('GRanD_reservoirs_v1_3.shp');
type = cell(length(lat),1);
for i = 1:length(grand)
    in = inpolygon(lon,lat,grand(i).X,grand(i).Y);
    if i == 1
        in_out = in;
    else
        in_out = in_out + in;
    end
    if sum(in) >= 1
        ind1 = find(in == 1);
        for j = 1:length(ind1)
        type{ind1(j)} = grand(i).MAIN_USE;
        end
    end
    grand_test(i,1) = sum(in);
end

grand_lakes = in_out;
grand_lakes(grand_lakes > 1) = 1;
all_res = goodd_res + grand_lakes;
all_res(all_res > 1) = 1;

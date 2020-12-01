%script to read in river basins from GRDC dataset and create figures of
%water level variability and reservoir storage variability percent
cd('/Volumes/Extreme SSD/0_IS2_testing/results_v4_Oct25');
load('complete_results_nov16.mat');

%STEP 1: read in basins data
cd('/Volumes/Extreme SSD/GRDC_basins/grdc_major_river_basins_shp');
wld = shaperead('mrb_basins.shp');

for i = 1:length(wld)
    vert = [lonc, latc];
    edge = [wld(i).X', wld(i).Y'];
    inp_all = inpoly2(vert,edge);
    if sum(inp_all) == 0
        inp_all = zeros(length(vert),1);
    end
    
    if i == 1
        basins = i*inp_all;
    else
        basins = basins + i*inp_all;
    end
    disp(['Finished ' wld(i).RIVER_BASI ' ' num2str(i) ' of ' num2str(length(wld))]);
end

%STEP 2: organize icesat-2 data into basins
clear output
for i = 1:length(wld)
    output(i).id = i;
    output(i).X = wld(i).X;
    output(i).Y = wld(i).Y;
    output(i).name = wld(i).RIVER_BASI;
    output(i).area = wld(i).AREA_CALC;
    ind_all = (basins == i);
    if sum(ind_all) >= 1
        output(i).num_lakes = sum(ind_all);
        output(i).num_lakes_r = sum(ind_all);
        output(i).num_reservoir = sum(all_r(ind_all));
        output(i).num_res_r = sum(all_r(ind_all));
        ind_range = ind_all;
        if sum(ind_range) >= 1
            output(i).med_range = median(range_new(ind_range));
            r = range_new(ind_range);
            g = all_r(ind_range);
            a = areac(ind_range);
            
            output(i).med_range_no_r = median(r(g == 0));
            if sum(g) >= 1
                output(i).med_range_r = median(r(g == 1));
            else
                output(i).med_range_r = 0;
            end
            output(i).total_change = sum(r.*a)*10^-9;
            output(i).total_change_r = sum(r(g == 1).*a(g == 1))*10^-9;
            output(i).total_change_n = sum(r(g == 0).*a(g == 0))*10^-9;
            output(i).per_reservoir = 100*sum(r(g == 1).*a(g ==1))./sum(r.*a);
        else
            output(i).med_range = 0;
            output(i).med_range_no_r = 0;
            output(i).med_range_r = 0;
            output(i).total_change = 0;
            output(i).total_change_r = 0;
            output(i).total_change_n = 0;
            output(i).per_reservoir = 0;
        end
    else
        output(i).num_lakes = -1;
        output(i).num_lakes_r = -1;
        output(i).num_reservoir = -1;
        output(i).num_res_r = -1;
        output(i).med_range = -1;
        output(i).med_range_no_r = -1;
        output(i).med_range_r = -1;
        output(i).total_change = -1;
        output(i).total_change_r = -1;
        output(i).total_change_n = -1;        
        output(i).per_reservoir = -1;
    end
    output(i).Geometry = 'Polygon';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%STEP 3: create figures
cd('/Volumes/Extreme SSD/0_IS2_testing/figures_May21');
figure(1) %storage variability figure
op = output;
op([op.num_lakes] < 10) = [];
output_large = op(end-39:end);
output_large(9).name = 'RIO GRANDE';
output_large(10).name = 'OKAVANGO';
output_large(7).name = 'COLORADO';
output_large(21).name = 'SAINT LAWRENCE';
output_large(26).name = 'TARIM HE';
output_large(40).name = 'AMAZON';
[~,B] = sort([output_large.area],'descend');
output_large = output_large(B);


per_r = [output_large.per_reservoir]';
[per_r_s,B] = sort(per_r);
cmap = brewermap(10,'YlOrRd');
per_error_s = per_error(B,:);
errlow = abs(per_r_s - per_error_s(:,1));
errhigh = abs(per_r_s - per_error_s(:,2));


thresh = [-0.1 10 25 40 50 60 70 80 90 100];
count = 1;
for i = 1:9
    if i == 1
        hold off
    else
        hold on
    end
    III = per_r_s > thresh(i) & per_r_s <= thresh(i+1);
    h = bar(count:count+sum(III)-1,per_r_s(III));
    hold on
    set(h,'FaceColor',cmap(i,:));
    h = errorbar(count:count+sum(III)-1,per_r_s(III),errlow(III),errhigh(III));
    set(h,'Color',[0 0 0]);
    set(h,'LineStyle','none');
    count = count + sum(III);
end


for i = 1:length(output_large)
    per_r_names{i,1} = [output_large(B(i)).name(1) lower(output_large(B(i)).name(2:end))];
end
per_r_names{21} = 'Saint Lawrence';
per_r_names{3} = 'Tarim He';
per_r_names{14} = 'Yellow River';
per_r_names{40} = 'Sao Francisco';
per_r_names{11} = 'Aral Sea';
per_r_names{25} = 'Shatt Al Arab';
per_r_names{36} = 'Rio Grande';

xticks([1:40]);
xticklabels(per_r_names);
xtickangle(90);
    
ylabel('Storage Change due to Reservoirs (%)');
set(gca,'FontSize',12);
set(gca,'TickLength',[0, 0])  
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 10 5]);
print('reservoir_percent_bar_grdc_Nov19','-dpng');

figure(2) % water level variability bar figure
clear mr
med_range = [output_large.med_range]';
%mr(:,1) = [output_large.med_range_no_r];
med_range_r = [output_large.med_range_r];
[med_range_s,B] = sort(med_range);
cmap = brewermap(10,'YlGnBu');
range_error_s = range_error(B,:);
errlow = abs(med_range_s - range_error_s(:,1));
errhigh = abs(med_range_s - range_error_s(:,2));

thresh = [-0.1 0.1 0.2 0.3 0.4 0.5 0.75 1.0 1.25 1.5 50];
count = 1;
for i = 1:10
    if i == 1
        hold off
    else
        hold on
    end
    III = med_range_s > thresh(i) & med_range_s <= thresh(i+1);
    h = bar(count:count+sum(III)-1,med_range_s(III));
    set(h,'FaceColor',cmap(i,:));
    hold on
    h = errorbar(count:count+sum(III)-1,med_range_s(III),errlow(III),errhigh(III));
    set(h,'Color',[0 0 0]);
        set(h,'LineStyle','none');

    count = count + sum(III);
end


for i = 1:length(output_large)
    per_r_names{i,1} = [output_large(B(i)).name(1) lower(output_large(B(i)).name(2:end))];
end
per_r_names{3} = 'Saint Lawrence';
per_r_names{18} = 'Tarim He';
per_r_names{19} = 'Yellow River';
per_r_names{32} = 'Sao Francisco';
per_r_names{33} = 'Aral Sea';
per_r_names{35} = 'Shatt Al Arab';
per_r_names{35} = 'Rio Grande';

xticks([1:40]);
xticklabels(per_r_names);
xtickangle(90);
    
ylabel('Range in Water Level (m)');
set(gca,'FontSize',12);
set(gca,'TickLength',[0, 0])    
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 10 5]);
print('med_water_level_bar_grdc_Nov19','-dpng');
    
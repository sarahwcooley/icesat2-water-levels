%script to read in hydrobasins dataset and create maps of
%water level variability and reservoir storage variability percent

cd('/Volumes/Extreme SSD/0_IS2_testing/results_v4_Oct25');
load('complete_results_nov16.mat');
load('coastlines');

%STEP 1: Read in hydrobasins
cd('/Volumes/Extreme SSD/HydroBASINS');
folders = dir;
folders([folders.bytes] > 0) = [];
count = 1;
clear output
c = 1;
for pp = 3:length(folders)
    cd('/Volumes/Extreme SSD/HydroBASINS');
    cd(folders(pp).name);
    shapename = dir('*lev03*.shp');
    wld = shaperead(shapename(1).name);

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
        count = count + 1;
    end

    
    for i = 1:length(wld)
        output(c).id = i;
        output(c).X = wld(i).X;
        output(c).Y = wld(i).Y;
        ind_all = (basins == i);
        if sum(ind_all) >= 1
            output(c).num_lakes_r = sum(ind_all);
            output(c).num_reservoir = sum(all_r(ind_all));
            ind_range = ind_all;
            if sum(ind_range) >= 1
                output(c).med_range = median(range_new(ind_range));
                r = range_new(ind_range);
                g = all_r(ind_range);
                a = areac(ind_range);
            
                output(c).med_range_no_r = median(r(g == 0));
                if sum(g) >= 1
                    output(c).med_range_r = median(r(g == 1));
                else
                    output(c).med_range_r = 0;
                end
                output(c).total_change = 0.001*sum(r.*a);
                output(c).total_change_r = 0.001*sum(r(g == 1).*a(g == 1));
                output(c).per_reservoir = 100*sum(r(g == 1).*a(g ==1))./sum(r.*a);
            else
                output(c).med_range = 0;
                output(c).med_range_no_r = 0;
                output(c).med_range_r = 0;
                output(c).total_change = 0;
                output(c).total_change_r = 0;
                output(c).per_reservoir = 0;
            end
        else
            output(c).num_lakes_r = -1;
            output(c).num_reservoir = -1;
            output(c).med_range = -1;
            output(c).med_range_no_r = -1;
            output(c).med_range_r = -1;
            output(c).total_change = -1;
            output(c).total_change_r = -1;
            output(c).per_reservoir = -1;
        end
            output(c).Geometry = 'Polygon';
            c = c+1;
    end
end

%STEP 2: create maps of water level and storage variability


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%reservoir storage percent map

clear shapeplot
for i = 1:length(output)
    shapeplot(i).Lat = output(i).Y;
    shapeplot(i).Lon = output(i).X;
    d_val = output(i).per_reservoir;
    n_val = output(i).num_lakes_r;
     if d_val > 90; shapeplot(i).per_res = 12; end
        if d_val > 80 && d_val <= 90; shapeplot(i).per_res = 11; end
        if d_val > 70 && d_val <= 80; shapeplot(i).per_res = 10; end
        if d_val > 60 && d_val <= 70; shapeplot(i).per_res = 9; end
        if d_val > 50 && d_val <= 60; shapeplot(i).per_res = 8; end
        if d_val > 40 && d_val <= 50; shapeplot(i).per_res = 7; end
        if d_val > 25 && d_val <= 40; shapeplot(i).per_res = 6; end
        if d_val > 10 && d_val <= 25; shapeplot(i).per_res = 5; end
        if d_val > 0 && d_val <= 10; shapeplot(i).per_res = 4; end
        if d_val == 0; shapeplot(i).per_res = 3.5; end
        if d_val == -1; shapeplot(i).per_res = 2; end
        if n_val < 5; shapeplot(i).per_res = 2; end
        shapeplot(i).Geometry = 'Polygon';
        shapeplot(i).id = i;
end
cmap = brewermap(10,'YlOrRd');
cmap = [1 1 1; 0.8 0.8 0.8; cmap];
colorrange = makesymbolspec('Polygon',{'per_res',[1 12],'facecolor',cmap});
[lonp,latp] = meshgrid(linspace(-179, 179, 540),...
     linspace(-89.5,89.5, 540));
 za = zeros(size(lonp));
 pza = zeros(size(lonp));
ocean = landmask(latp,lonp); 
za(ocean) = NaN; 
pza(ocean == 0) = NaN;



figure(1) %storage change due to reservoirs map
worldmap('World');
h=pcolorm(latp,lonp,pza+1);
geoshow(shapeplot,'SymbolSpec',colorrange);
colormap(cmap)
cb = colorbar('Ticks',[ 0.5 1.5 3 5 7 9 11],'TickLabels',{'No Data','Too Few Obs','0%','20%','40%','60%','90%'});
caxis([0 12])
cb.Label.String = 'Storage Change due to Reservoirs (%)';
set(gca,'FontSize',12);
hold on
mlabel('off');
plabel('off');
%h=pcolorm(latp,lonp,za); 
geoshow(coastlat,coastlon,'Color','k');
title('Storage Change due to Reservoirs (%)');
cd('/Volumes/Extreme SSD/0_IS2_testing/figures_May21');
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 12 9]);
print('reservoir_percent_hydrobasins_nov19','-dpng');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Water level variability figure

clear shapeplot
for i = 1:length(output)
    shapeplot(i).Lat = output(i).Y;
    shapeplot(i).Lon = output(i).X;
    d_val = output(i).med_range;
    n_val = output(i).num_lakes_r;
    if d_val > 1.5; shapeplot(i).per_res = 12; end
        if d_val > 1.25 && d_val <= 1.5; shapeplot(i).per_res = 11; end
        if d_val > 1 && d_val <= 1.25; shapeplot(i).per_res = 10; end
        if d_val > 0.75 && d_val <= 1; shapeplot(i).per_res = 9; end
        if d_val > 0.5 && d_val <= 0.75; shapeplot(i).per_res = 8; end
        if d_val > 0.4 && d_val <= 0.5; shapeplot(i).per_res = 7; end
        if d_val > 0.3 && d_val <= 0.4; shapeplot(i).per_res = 6; end
        if d_val > 0.2 && d_val <= 0.3; shapeplot(i).per_res = 5; end
        if d_val > 0.1 && d_val <= 0.2; shapeplot(i).per_res = 4; end
        if d_val > 0 && d_val <= 0.1; shapeplot(i).per_res = 3; end
        if d_val == -1; shapeplot(i).per_res = 2; end
        if n_val < 5; shapeplot(i).per_res = 2; end

        shapeplot(i).Geometry = 'Polygon';
        shapeplot(i).id = i;
end
cmap = brewermap(10,'YlGnBu');
cmap = [1 1 1; 0.8 0.8 0.8; cmap];
colorrange = makesymbolspec('Polygon',{'per_res',[1 12],'facecolor',cmap});

figure(2) %water level variability map
worldmap('World');
h=pcolorm(latp,lonp,pza+1);
geoshow(shapeplot,'SymbolSpec',colorrange);
colormap(cmap)
cb = colorbar('Ticks',[ 0.5 1.5 3 5 7 9 11],'TickLabels',{'No Data','Too Few Obs','0.1','0.3','0.5','1.0','1.5'});
caxis([0 12])
cb.Label.String = 'Range in Water Level (m)';
set(gca,'FontSize',12);
hold on
mlabel('off');
plabel('off'); 
%h=pcolorm(latp,lonp,za); 
geoshow(coastlat,coastlon,'Color','k');
title('Range in Water Level (m)');
gcf = figure(8);
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 12 9]);
cd('/Volumes/Extreme SSD/0_IS2_testing/figures_May21');
print('med_range_water_level_hydrobasins_nov19','-dpng');

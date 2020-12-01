function [range,time_range,monthly_heights_ed,num_obs2] = calculate_range_nov6(monthly_heights, merit_height)

for i = 1:length(monthly_heights)
      r_h = monthly_heights(i,:);
      ab = find(r_h ~= 0);
      r_h = r_h(ab);
      stdrh = std(r_h);
      clear ij
      if length(r_h) > 1
      for j = 1:length(r_h)
          if abs(r_h(j) - merit_height(i)) > 40 || abs((r_h(j) - median(r_h))/stdrh) > 2.5  
              ij(j) = 0;
          else
              rhj = r_h;
              rhj(j) = [];
              if (abs(r_h(j) - median(r_h)) > 5*abs(max(rhj - median(r_h)))) && abs(r_h(j) - median(r_h)) > 5
                  ij(j) = 0;
              else
              ij(j) = 1;
              end
          end
      end
      r_h(ij == 0) = [];
      ab(ij == 0) = [];
      r_h2 = monthly_heights(i,:);
      rb = zeros(size(r_h2));
      rb(ab) = r_h;
      monthly_heights_ed(i,:) = rb;
      if length(r_h) > 1
          range(i,1) = max(r_h) - min(r_h);
          ind1 = find(r_h2 == max(r_h));
          ind2 = find(r_h2 == min(r_h));
          time_range(i,1) = abs(ind1(1) - ind2(1));
          
      else
          range(i,1) = -1;
          time_range(i,1) = -1;
      end
      else
          rb = zeros(size(monthly_heights(i,:)));
          rb(ab) = r_h;
          range(i,1) = -1;
          time_range(i,1) = -1;
          monthly_heights_ed(i,:) = monthly_heights(i,:);
      end
      num_obs2(i,1) = length(r_h);
end
end
function [xxx1 xxx2] = aggregate_demand_sgn(pa,actual_wages)

load parameter_vector

demand_n = (theta./(1+theta)).*(actual_wages - abar.*pa);

xxx1 = mean(demand_n);

tm = demand_n <  0;
demand_n(tm) = 0;

if nargout > 1
xxx1 = mean(demand_n);  
xxx2 = demand_n./actual_wages;
end
function [xxx1 xxx2 xxx3] = aggregate_demand_sgn(pa,actual_wages)
load parameter_vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computes demand of the non-agriculture good for each agent and then
% aggregates, i.e. averages over this to compute aggregate demand.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
demand_n = (theta./(1+theta)).*(actual_wages - abar.*pa);

xxx1 = mean(demand_n);

tm = demand_n <  0;
demand_n(tm) = 0;

if nargout > 1
xxx1 = mean(demand_n);  
xxx2 = demand_n./actual_wages;
xxx3 = demand_n;
end
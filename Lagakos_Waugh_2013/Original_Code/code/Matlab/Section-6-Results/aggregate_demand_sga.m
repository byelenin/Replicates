function [xxx1 xxx2 xxx3] = aggregate_demand_sga(pa,actual_wages)

load parameter_vector

demand_ag = (1./(pa.*(1+theta))).*(actual_wages + abar.*pa.*theta);

tm = pa.*demand_ag > actual_wages;
demand_ag(tm) = actual_wages(tm)./pa;

xxx1 = mean(demand_ag);

xxx2 = (pa.*demand_ag);

xxx3 = actual_wages;
    

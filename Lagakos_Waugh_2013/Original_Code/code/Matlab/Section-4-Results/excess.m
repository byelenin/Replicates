function yyy = excess(zzz)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to compute the excess demand function used to find a price
% that clears markets.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pa = exp(zzz);

[labor_n labor_a workin_n] = compute_talent_alloc(pa);

[actual_wages] = compute_wages(pa, workin_n);
 
yyy =  (aggregate_demand_sga(pa, actual_wages) ) - aggregate_supply_a(labor_a);
 
yyy = norm(yyy);

end

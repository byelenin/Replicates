function yyy = excess(zzz)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program to compute excess supply functions given prices pa, r, pl. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load parameter_vector

pa = exp(zzz(1));
r = exp(zzz(2));
pl = exp(zzz(3));

[labor_n labor_a workin_n] = compute_talent_alloc(pa,r,pl);

Y_a = aggregate_supply_a(labor_a,pa,r,pl);

Y_n = aggregate_supply_n(labor_n,r);

% factor_payments = alpha_a.*pa.*Y_a + alpha_n.*Y_n + alpha_b.*(pa).*Y_a;

factor_payments = r.*capital_endowment + pl.*land_endowment;

[actual_wages] = compute_income(pa,r,pl,factor_payments,workin_n);

yyy = zeros(3,1);

yyy(1) =  log(aggregate_demand_sga(pa, actual_wages) ) - log(aggregate_supply_a(labor_a,pa,r,pl));

yyy(2) =  log(aggregate_demand_sgn(pa, actual_wages) ) - log(aggregate_supply_n(labor_n,r));

yyy(3) =  log((1./r).*(alpha_a.*pa.*Y_a + alpha_k.*Y_n)) - log(capital_endowment);

% yyy(4) = (log((alpha_b.*(pa./pl).*Y_a)) - log(land_endowment));
% Obviously if land is taken out comment this line out. 


yyy = (norm(yyy));

end

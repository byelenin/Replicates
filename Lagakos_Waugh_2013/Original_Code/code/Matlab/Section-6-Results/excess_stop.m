function [Y_a,Y_n,pa,Y_al,Y_nl] = excess_stop(zzz)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program to compute excess supply functions given prices pa, r, pl. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load parameter_vector
global talent

pa = exp(zzz(1));
r = exp(zzz(2));
pl = exp(zzz(3));


[labor_n labor_a workin_n] = compute_talent_alloc(pa,r,pl);

[Y_a, constant_ag] = aggregate_supply_a(labor_a,pa,r,pl);

[Y_n, constant_nag] = aggregate_supply_n(labor_n,r);

%
total_income = pa.*Y_a + Y_n;

factor_payments = alpha_a.*pa.*Y_a + alpha_k.*Y_n + alpha_b.*(pa).*Y_a;

[actual_wages, prob_n, ag_wages, nag_wages] = compute_income(pa,r,pl,factor_payments,workin_n);

% [Da, expshare_a, income] = aggregate_demand_sga(pa, actual_wages);

Y_al = Y_a./(1-prob_n);
Y_nl  = Y_n./prob_n;

% disp('Agriculture, Non-Agriculture, Labor Shares')
% disp([1-prob_n, prob_n])
% 
disp('Agriculture, Non-Agriculture, Average Talent')
disp([labor_a./(1-prob_n), labor_n./prob_n])

disp('Agriculture, Non-Agriculture,``A'' Term')
disp([constant_ag./(Aa.^(1/(1-alpha_c))), constant_nag])

disp('Agriculture, Non-Agriculture,``A_a'' Term')
disp([Aa.^(1/(1-alpha_c)), 1])

% disp('Agriculture, Non-Agriculture, Output Shares')
% disp([pa.*Y_a./total_income, Y_n./total_income])

ability_a = mean(talent(~workin_n,2))./mean(talent(:,2));
ability_n = mean(talent(workin_n,1))./mean(talent(:,1));

disp('Average Talent in Agriculture/Non-Agriculture')
disp([ability_a, ability_n])

disp('Productivity')
disp([Y_a./(1-prob_n), Y_n./prob_n])
% 
% disp('Capital to Output Ratio')
% disp([capital_endowment./total_income])

disp('Capital to Output Ratio')
disp([capital_endowment./total_income])

frac_capital_ag = (1./r).*(alpha_a.*pa.*Y_a)./capital_endowment;
frac_capital_nag = (1./r).*(alpha_k.*Y_n)./capital_endowment;

capital_ag = capital_endowment.*frac_capital_ag./(1-prob_n);
capital_nag = capital_endowment.*frac_capital_nag./(prob_n);

disp('Capital per worker in sector')
disp([capital_ag, capital_nag ])
% 
disp('Fraction of Captial in Agriculture')
disp([frac_capital_ag,frac_capital_nag])


disp('Land to Employment Ratio, Land Power Term, Land to Output Ratio')
disp([land_endowment./(1-prob_n), (alpha_b.*(pa./pl)).^(alpha_b/(1-alpha_c)), land_endowment./Y_a])

disp('Capital Power Term: Agriculture, Non-Agriculture)')
disp([(alpha_a.*(pa./r)).^(alpha_a/(1-alpha_c)), (alpha_k./r).^(alpha_k/(1-alpha_k))])

disp('Ratio of Agriculture Wage to Non-Agriculture')
disp([mean(ag_wages)./mean(nag_wages)])
% 
% disp('Standard Deviation of Log Wages, Agriculture, Non-Agriculture')
% disp([std(log(ag_wages)), std(log(nag_wages))])
% 
% data = (log(94244)-log(21611))-(log(10780)-log(3501));
% 
% disp('Expenditure Share Change w/Income')
% disp([change_exp_share, change_inc_share, diff_change, data ])

disp('Agriculture, Non-Agriculture, Labor Shares')
disp([1-prob_n, prob_n])


yyy = zeros(4,1);

yyy(1) =  log(aggregate_demand_sga(pa, actual_wages) ) - log(aggregate_supply_a(labor_a,pa,r,pl));

yyy(2) =  log(aggregate_demand_sgn(pa, actual_wages) ) - log(aggregate_supply_n(labor_n,r));

yyy(3) =  log((1./r).*(alpha_a.*pa.*Y_a + alpha_k.*Y_n)) - log(capital_endowment);

yyy(4) = (alpha_b.*(pa./pl).*Y_a - land_endowment)./land_endowment;
 
test = norm(yyy) > .01;

[land_size] = compute_land_size(pa,r,pl,workin_n);

% figure;
% ksdensity(log(land_size))

if sum(test) > 1
    disp('It appears a market is not clearing')
end

end

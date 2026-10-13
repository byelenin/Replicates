function [xxx1 xxx2 ] = aggregate_supply_a(labor_a,pa,r,pl)

load parameter_vector

constant_ag = (A.*Aa).^(1/(1-alpha_c)).*(alpha_a.*(pa./r)).^(alpha_a/(1-alpha_c)).*(alpha_b.*(pa./pl)).^(alpha_b/(1-alpha_c));

agcult_y = constant_ag.*labor_a;

xxx1 = agcult_y;

if nargout == 2
    xxx2 = constant_ag;

end
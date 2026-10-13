function [land_size] = compute_land_size(pa,r,pl,workin_n)
global talent
load parameter_vector

constant_ag = A.^(1/(1-alpha_c)).*(alpha_a.*(pa./r)).^(alpha_a/(1-alpha_c)).*(alpha_b.*(pa./pl)).^(alpha_b/(1-alpha_c));

land_size = (alpha_b.*pa.*constant_ag.*talent(~workin_n,2))./pl;
function [xxx1 xxx2] = aggregate_supply_n(labor_n,r)

load parameter_vector

constant_n = A.^(1/(1-alpha_k)).*(alpha_k./r).^(alpha_k/(1-alpha_k));

nonagcult_y = constant_n.*labor_n;

xxx1 = nonagcult_y;

if nargout == 2
    xxx2 = constant_n;
end
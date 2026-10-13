function xxx1 = aggregate_supply_a(labor_a )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Computes aggregate supply of agriculture good.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load parameter_vector

agcult_y = A.*Aa.*labor_a;

xxx1 = agcult_y;
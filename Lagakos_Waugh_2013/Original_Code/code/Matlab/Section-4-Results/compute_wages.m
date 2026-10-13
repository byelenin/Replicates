function [actual_wages, prob_n] = compute_wages(pa,workin_n)
global talent
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to compute wages, given the price and the allocation. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load parameter_vector

wage_a = pa.*A.*Aa.*talent(~workin_n,2);

wage_n = A.*An.*talent(workin_n,1);

actual_wages = [wage_a; wage_n];

if nargout > 1
    prob_n = sum(workin_n)./length(talent);
end


    


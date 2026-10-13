function [actual_wages, prob_n, ag_wages, nag_wages] = compute_income(pa,r,pl,factor_payments,workin_n)
global talent
load parameter_vector

nshares = length(talent);

constant_n = A.^(1/(1-alpha_k)).*(alpha_k./r).^(alpha_k/(1-alpha_k));

constant_ag = (A.*Aa).^(1/(1-alpha_c)).*(alpha_a.*(pa./r)).^(alpha_a/(1-alpha_c)).*(alpha_b.*(pa./pl)).^(alpha_b/(1-alpha_c));

wage_n = (1-alpha_k).*constant_n.*talent(workin_n,1);

wage_a = (1-alpha_c).*pa.*constant_ag.*talent(~workin_n,2);

% actual_wages = [wage_a; wage_n]+ factor_payments;

total_wages = sum([wage_a;wage_n]);
share = [wage_a;wage_n]./total_wages;
actual_wages = [wage_a; wage_n] + share.*(factor_payments.*nshares);

if nargout == 2
    prob_n = sum(workin_n)./length(talent);  
end

if nargout == 4
    prob_n = sum(workin_n)./length(talent); 
    ag_wages = wage_a;
    nag_wages = wage_n;
end

% 
% wages = [wage_A ,wage_S];
% 
% [actual_wages, occupation] = max(wages');
% 
% 
% if nargout > 1
%     prob_S = sum(occupation==2)./length(occupation);
% end
    


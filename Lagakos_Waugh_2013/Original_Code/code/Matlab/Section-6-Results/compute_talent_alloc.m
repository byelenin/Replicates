function [labor_n labor_a xxx3] = compute_talent_alloc(pa,r,pl)
global talent
load parameter_vector


zn_za = (talent(:,1))./(talent(:,2));

power1 = ( (1/(1-alpha_c)) - (1/(1-alpha_k)));
power2 = ( (alpha_k/(1-alpha_k))-(alpha_a/(1-alpha_c)) );
power3 = (1/(1-alpha_c));

z_bar_const = ((1-alpha_c)./(1-alpha_k)).*pa.^(1./(1-alpha_c)).*A.^(power1).*Aa.^(power3).*r.^(power2).*pl.^((-alpha_b)./(1-alpha_c));

gamma = alpha_a.^((alpha_a)/(1-alpha_c)).*alpha_b.^((alpha_b)/(1-alpha_c)).*alpha_k.^(-(alpha_k)/(1-alpha_k));

z_bar = (gamma.*z_bar_const).*(ones(ndraws,1));

workin_n = (zn_za >= z_bar);

prob_n = sum(workin_n)./ndraws;

labor_a = (1-prob_n).*mean(talent(~workin_n,2));
labor_n = (prob_n).*mean(talent(workin_n,1));

% Just to do this to get the algorithim started if the price is s.t. no one
% works in the agriculture sector.
if sum(workin_n) == length(talent)
    st = randi(length(talent),.001.*length(talent),1);
    workin_n(st) = 0;
     
    prob_n = sum(workin_n)./ndraws;

    labor_a = (1-prob_n).*mean(talent(~workin_n,2));
    labor_n = (prob_n).*mean(talent(workin_n,1));
end
     

if nargout == 3
    xxx3 = workin_n;
end

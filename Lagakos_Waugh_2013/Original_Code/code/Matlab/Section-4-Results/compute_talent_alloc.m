function [labor_n labor_a xxx3 xxx4 xxx5] = compute_talent_alloc(pa)
global talent
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to compute the allocation of workers into the sector. It uses
% the global function talent which is the vector of abilities and then it
% decides who is working where.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load parameter_vector

zn_za = (talent(:,1))./(talent(:,2));

z_bar = (pa).*(Aa./An).*(ones(ndraws,1));

workin_n = (zn_za >= z_bar);

prob_n = sum(workin_n)./ndraws;

labor_a = (1-prob_n).*mean(talent(~workin_n,2));
labor_n = (prob_n).*mean(talent(workin_n,1));

if nargout == 3
    xxx3 = workin_n;
end

if nargout == 5
    xxx3 = workin_n;
    xxx4 = talent;
    xxx5 = prob_n;
end
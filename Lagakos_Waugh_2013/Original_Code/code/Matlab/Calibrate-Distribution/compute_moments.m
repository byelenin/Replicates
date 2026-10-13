function [moments] = compute_moments(Theta_a, Theta_n, Rho,code)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Function to compute the implided moments of an economy with a specified
% percent in agriculture. Inputs are theta_a (1/theta_a in paper), theta_n
% (ditto) and Rho (the correlation coeffcient, not the dependence parameter.
% 
% Output are the specified moments
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ndraws = 100000; 
%Number of workers in the economy, same as in full simmulation of the g.e. economy

prcent_in_ag = 0.02; 
% Percent in agriculture

% Just to make sure the correlation coeffcient is between 0 and 1, the only
% allowabel case with a gumbel copula
Rho = min(Rho,.99);
Rho = max(Rho,-.25);
Mu = 1;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Paramaterize the copula, draw dependent uniform random variables, use
% inverse cdf to generate dependent frechet random variables.

rho_hat = copulaparam('frank',Rho);
randn('state',032878+code)
rand('twister',032878+code)
u = copularnd('frank',rho_hat,ndraws);

delta_n = exp(Mu).*gamma(1-Theta_n).^-1;
delta_a = exp(Mu).*gamma(1-Theta_a).^-1;

rn = (-log(u(:,2))./delta_n.^(1./Theta_n)).^(-Theta_n);
ra = (-log(u(:,1))./delta_a.^(1./Theta_a)).^(-Theta_a);

talent_rn = (rn);
talent_ra = (ra);

% mean(rn)
% disp(corr(log(rn),log(ra)))

if isfinite(mean(talent_rn))~=1 || isfinite(mean(talent_ra))~=1;
    moments(1) = 10^5;
    moments(2) = 10^5;
    moments(3) = 10^5;
    return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now find a price such that only specified percent of workers remain in
% agriculture, this is the stuff below

zn_za = talent_rn./talent_ra;

guess = mean([talent_rn;talent_ra]);

if isfinite(guess) ~= 1
    moments(1) = 10^5;
    moments(2) = 10^5;
    moments(3) = 10^5;
    return
end

if isreal(guess) ~= 1
    moments(1) = 10^5;
    moments(2) = 10^5;
    moments(3) = 10^5;
    return
end

options = optimset('TolFun',10^-5,'TolX',10^-5,'MaxFunEvals',1000,'MaxIter',1000,'Display','off');
pa = fzero(@(xxx) pick_fraction(xxx,zn_za,prcent_in_ag),guess ,options);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Given the price that delivers the specified percent of workers, now
% compute the implied moments


z_bar = pa.*(ones(ndraws,1));
workin_n = (zn_za >= z_bar);
prob_n = sum(workin_n)./ndraws;
% 1-prob_n

if .01.*round(100.*(1-prob_n)) ~= prcent_in_ag;
    moments(1) = 10^5;
    moments(2) = 10^5;
    moments(3) = 10^5;
%     moments(4) = 10^5;
    return
end


wage_a = pa.*talent_ra(~workin_n);
wage_n = talent_rn(workin_n);

moments(1) = std(log(wage_n));
moments(2) = std(log(wage_a));
moments(3) = mean(wage_a)./mean(wage_n);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function zzz = pick_fraction(pa,zn_za,frac)
    z_bar = pa.*(ones(ndraws,1));
    workin_n = (zn_za >= z_bar);
    prob_n = sum(workin_n)./ndraws;
    zzz = (1-prob_n) - (frac);

end

end


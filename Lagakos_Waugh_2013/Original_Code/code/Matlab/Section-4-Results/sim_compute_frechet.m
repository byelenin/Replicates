function [www zzz]= sim_compute_frechet(technology,preferences,distribution,flag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Program computes equillibrium for Specilization paper by David Lagakos
%% and Michale Waugh. New version 05/16/2011
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
global talent

A = technology(1);
Aa = technology(2);
An = technology(3);

phi = preferences(1); % Expenditure share of Ag in the limit as income grows.
theta = (1-phi)./phi; % The ``theta'' or nu in the paper corresponds with the
                      % relative taste of the non-agriculture good.
abar = preferences(2); % Preference parameter for stone-geary type.

theta_dist = [distribution(1), distribution(2)]; % (1) is non-ag, (2) is ag
tau = distribution(3); % This is the correlation parameter

if Aa == 1;
    guess = log(1);
else
    guess = log(4);
end

ndraws = 1000000;

save parameter_vector A Aa An theta abar ndraws

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Draw the talent distribution and plot the properties

talent = draw_talent(theta_dist,tau,ndraws);

% hist3(log(talent),[50,50])
% figure
% hist(log(talent(:,2)),100)
% 
% if nargout < 1
% [f1 x1]=ksdensity(log(talent(:,2)));
% [f2 x2]=ksdensity(log(talent(:,1)));
% figure
% plot(x1,f1,'r-',x2,f2,'b-')
% title('Talent Distributions')
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Commands to programs to compute equillibrium
% options = optimset('TolFun',10^-5,'MaxFunEvals',10000,'MaxIter',50000,'Display','Iter');
options = optimset('TolFun',10^-5,'TolX',10^-5,'MaxFunEvals',10000,'MaxIter',50000);

[x,fval] = fminsearch('excess',guess,options);

if fval > 10^-2
    disp('A market may not be clearing')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Record properties of equillibrium

pa_eq = exp(x(1));

[labor_n labor_a workin_n] = compute_talent_alloc(pa_eq);

[income] = compute_wages(pa_eq, workin_n);

prob_n = sum(workin_n)./ndraws;

Ys = aggregate_supply_n(labor_n);

[Ds, expshare_n] = aggregate_demand_sgn(pa_eq, income);

Ya = aggregate_supply_a(labor_a);

[Da, expshare_a, income] = aggregate_demand_sga(pa_eq,income);

wage_a = pa_eq.*A.*Aa.*talent(~workin_n,2);

wage_n = A.*An.*talent(workin_n,1);

actual_wages = [wage_a; wage_n];

change_exp_share = log(prctile(expshare_a,80)./prctile(expshare_a,20));

diff_change = change_exp_share;

% [b,bint,r,rint,stats]=regress(log(expshare_a),[ones(length(log(income)),1), log(income)]);

agshr = (pa_eq.*Ya)./(Ys + pa_eq.*Ya);

cr = corr(log(talent(:,1)),log(talent(:,2)));

if flag == 1
    www = [Ya, Ys, pa_eq, prob_n, diff_change];
    return
end

if flag == 2
    www = [std(log(actual_wages)),mean(wage_n), mean(wage_a),cr,std((log(wage_n))),std((log(wage_a)))];
    return
end


disp('Cost of Minnimum Consumption Relative to Mean Income')
disp((pa_eq.*abar)./mean(actual_wages))

GDP = Ys + pa_eq.*Ya;
disp('GDP')
disp(GDP)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Display properties of equillibrium 

disp('Probability of Working in Agriculture')
disp(1-prob_n)

disp('Agricultures Share of GDP')
disp((pa_eq.*Ya)./(Ys + pa_eq.*Ya))

disp('Price of Agriculture')
disp([pa_eq])

disp('Standard Deviation of Wages, Service and Agricult')
disp([(std((log(wage_n)))), (std(log(wage_a)))])

disp('Relative Average Wages')
disp([mean(wage_a)./mean(wage_n)])

ability_a = mean(talent(~workin_n,2))./mean(talent(:,2));
ability_n = mean(talent(workin_n,1))./mean(talent(:,1));

disp('Average Talent in Agriculture/Non-Agriculture')
disp([ability_a, ability_n])

ability_an = mean(talent(workin_n,2))./mean(talent(:,2));

% disp('Average Talent in Agriculture, Talent in Ag of Non-Ag Workers')
% disp([ability_a, ability_an])

disp('Correlation of talent')
disp(corr(log(talent(:,1)),log(talent(:,2))))

nine_ten = prctile(log(actual_wages),90)-prctile(log(actual_wages),10);

www = [Ya, Ys, pa_eq, prob_n, agshr, A, 1 ,mean(wage_n), mean(wage_a),cr,std((log(wage_n))),std((log(wage_a))),nine_ten];
zzz = [talent workin_n];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 

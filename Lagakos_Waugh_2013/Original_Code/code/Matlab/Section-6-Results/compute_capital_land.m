function [www zzz]= compute_capital_land(technology,preferences,distribution,endowment,flag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Program computes equillibrium for economy with stone-geary preferences,
%% and with capital and land
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
global talent

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Specify the technology, preference, and distribution parameters. 

A = technology(1);
Aa = technology(5);

alpha_a = technology(2);
alpha_b = technology(3);
alpha_k = technology(4);

alpha_c = alpha_a + alpha_b;

phi = preferences(1); % Expenditure share of Ag in the limit as income grows.
theta = (1-phi)./phi;
abar = preferences(2); % Preference parameter for stone-geary type.

theta_dist = [distribution(1), distribution(2)]; % (1) is non-ag, (2) is ag
tau = distribution(3); % This is the correlation parameter

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In this model, the price guess is particularly important.

guess = [log(1.5),log(.1),(1.7)]; 
%This is good for baseline, here make sure the number of agents is large,
%like one million. Reset excess function so only three conditions are met 


% guess = [log(.4),log(.12),3]; 
% this is good for taking selection out, 

% guess = [log(.5),log(.4),30];
% This guess is good for taking selection and land out, fourht line in the
% table

capital_endowment = endowment(1);
land_endowment = endowment(2);

ndraws = 1000000;

save parameter_vector A Aa alpha_a alpha_b alpha_c alpha_k theta abar capital_endowment land_endowment ndraws


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Draw the talent distribution and plot the properties

talent = draw_talent(theta_dist,tau,ndraws);
% save talent talent

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Commands to programs to compute equillibrium
options = optimset('TolFun',10^-5,'MaxFunEvals',1000,'MaxIter',5000,'Display','off');
% options = optimset('TolFun',10^-5,'MaxFunEvals',10000,'MaxIter',50000);

[x,fval] = fminsearch('excess',guess,options);

if fval > 10^-2
    options = optimset('TolFun',10^-5,'MaxFunEvals',1000,'MaxIter',5000,'Display','iter');

[x,fval] = fminsearch('excess',x + .1.*rand(1,3),options);

end

disp('Norm of excess demand functions')
disp(fval)

disp('Prices, pa, r, pl')
disp(exp(x))

[Y_a,Y_n,pa,Y_al,Y_nl] = excess_stop(x);

www = [Y_a,Y_n,pa,Y_al,Y_nl];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


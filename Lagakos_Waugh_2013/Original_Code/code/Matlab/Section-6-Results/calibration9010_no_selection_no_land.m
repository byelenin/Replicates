clc
clear 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Code to compute results with capital and land incorperated into the model
% along with the selection chanel
%
% Note that convergence in this model is difficult, change the guess in the
% main run file compute_capital_land.m and make sure markets are clearing,
% note as well if facing issues, lossen the seach step in the fminsearch
% routine.
%
% Also be sure to change the guess as described in the comupte_capital_land
% file, make sure that the land market clearing condition is not being
% used.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

technology(1) = 100; % A parameter

technology(2) = 0.36; % alpha_a, Capital's share parameter
technology(3) = 0.001; % alpha_b, Land's share parameter
technology(4) = 0.33; % Non-Agriculture Capital's Share

technology(5) = 1;

preferences(1) = 0.0051; % Expenditure share of Ag in the limit as income grows.
preferences(2) = 33.5; % Preference parameter for stone-geary type.

distribution = [0.005, 0.005, 0.0]; % (1) is non-ag, (2) is ag (3)This is the correlation parameter

endowment(1) = 3812; %38*.15 Capital
endowment(2) = 3.405; % Land

wwwus = compute_capital_land(technology,preferences,distribution,endowment,flag);

disp('-------------------------------------------------------------------')

technology(1) = 85.5; % A parameter
endowment(1) = .94.*(technology(1)./100).*endowment(1); %38*.15 Capital
wwwr = compute_capital_land(technology,preferences,distribution,endowment,flag);

qr = wwwus(1:2)'; pr = [wwwus(3); 1];
qp = wwwr(1:2)'; pp = [wwwr(3); 1];
yyy = [wwwus(3); 1];
gdp_diff = sum(qr.*yyy)./sum(qp.*yyy);

disp('GDP Per Worker Difference at International Prices')
disp(gdp_diff)

disp('-------------------------------------------------------------------')

technology(1) = 17.5; % A parameter
endowment(1) = 118; % Capital

wwwp = compute_capital_land(technology,preferences,distribution,endowment,flag);

disp('-------------------------------------------------------------------')

qr = wwwr(1:2)'; pr = [wwwr(3); 1];
qp = wwwp(1:2)'; pp = [wwwp(3); 1];
yyy = [wwwus(3); 1];

gdp_diff = sum(qr.*yyy)./sum(qp.*yyy);

disp('GDP Per Worker Difference at International Prices')
disp(gdp_diff)

ag = wwwr(4)./wwwp(4);
nag = wwwr(5)./wwwp(5);

disp('Agriculture, Non-Agriculture Productivity Difference')
disp([ag, nag])


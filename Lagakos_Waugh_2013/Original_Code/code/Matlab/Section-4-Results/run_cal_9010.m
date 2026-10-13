clc
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Code to compute main results, only A differences in Lagakos and Waugh
% (2012). Distribution paramters are calibrated in seperate step. Here the
% A, abar, and nu parameter are calbrated here to target the moments
% specificed in the paper.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

technology(1) = 100;
technology(2) = 1; % Agriculture Productivity
technology(3) = 1; % Non Agriculture Productivity

preferences(1) = 0.0036; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The way to calibrate this paramter is to note that the relative wage must
% equall the expenditure share realative to the labor share. Thus with a 
% long run labor share of 0.05 this pins down the expenditure share.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

preferences(2) = 2.43;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This parameter is then calibrated to hit a 2 percent labor share in 
% agriculture in the baseline economony.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

distribution = [0.3707, 0.1899, 0.3451]; % (1) is non-ag, (2) is ag (3)This is the correlation parameter
wwwus = sim_compute_frechet(technology,preferences,distribution,0);

disp('-------------------------------------------------------------------')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

technology(1) = (1/1.26).*100;

wwwr = sim_compute_frechet(technology,preferences,distribution,0);

qr = wwwus(1:2)'; pr = [wwwus(3); 1];
qp = wwwr(1:2)'; pp = [wwwr(3); 1];
yyy = [wwwus(3); 1];

gdp_diff = sum(qr.*yyy)./sum(qp.*yyy);

disp('GDP Per Worker Difference at International Prices')
disp(gdp_diff)
tech_r = technology(1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('-------------------------------------------------------------------')

technology(1) = (1/23.85).*100;
% technology(1) = (1/15.85).*100; %This is India difference used as
% cross-check on the size of minnimum consumption.
technology(2) = 1; % Agriculture Productivity
technology(3) = 1; % Non Agriculture Productivity

wwwp = sim_compute_frechet(technology,preferences,distribution,0);

qr = wwwr(1:2)'; pr = [wwwr(3); 1];
qp = wwwp(1:2)'; pp = [wwwp(3); 1];
yyy = [wwwus(3); 1];

gdprich = sum(qr.*yyy); gdppoor = sum(qp.*yyy);

yap = wwwp(1)./(1-wwwp(4)); yar = wwwr(1)./(1-wwwr(4));
ynp = wwwp(2)./(wwwp(4)); ynr = wwwr(2)./(wwwr(4));

disp('Difference in GDP')
disp([gdprich./gdppoor])
disp('Difference in A')
disp(tech_r/technology(1))
disp('')
disp('Difference in AG TFP, and NAG TFP')
disp([yar./yap, ynr./ynp])
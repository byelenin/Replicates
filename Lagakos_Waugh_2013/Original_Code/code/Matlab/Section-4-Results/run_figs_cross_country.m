%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 08/04/12 for Lagakos and Waugh (2012)
% This code computes statistics for a sequence of TFP levles. This output
% is then used to compute Figures 1-3 and Figure 5 in the appendix
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc
clear
close all

technology(1) = 100;
technology(2) = 1;
technology(3) = 1;

preferences(1) = 0.0036;  
preferences(2) = 2.43;

distribution = [0.3707, 0.1899, 0.3451]; % (1) is non-ag, (2) is ag (3)This is the correlation parameter


wwwr = sim_compute_frechet(technology,preferences,distribution,0);

factor_sev = logspace(log10(.035),log10(1),20);

for i = 1:length(factor_sev)
    
technology(1) = factor_sev(i).*100;

wwwp = sim_compute_frechet(technology,preferences,distribution,0);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
qr = wwwr(1:2)';
pr = [wwwr(3); 1];

qp = wwwp(1:2)';
pp = [wwwp(3); 1];

yyy = [wwwr(3); 1];

gdprich = sum(qr.*yyy);

gdppoor = sum(qp.*yyy);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

yap = wwwp(1)./(1-wwwp(4));
yar = wwwr(1)./(1-wwwr(4));

ynp = wwwp(2)./(wwwp(4));
ynr = wwwr(2)./(wwwr(4));

disp('Difference in A, and GDP')
disp([1/factor_sev(i), gdprich./gdppoor])
disp('')
disp('Difference in AG TFP, and NAG TFP')
disp([yar./yap, ynr./ynp])

relgdp(i) = gdprich./gdppoor;
empshr(i) = 1-wwwp(4);
agshr(i) = wwwp(5);
price(i) = wwwp(3);
tfpdif_a(i) = yar./yap;
tfpdif_n(i) = ynr./ynp;

reltfp_a(i) = yap./gdppoor;

varwage(i) = wwwp(6);
mwagen(i) = wwwp(8);
mwagea(i) = wwwp(9);

level_gdp(i) = wwwp(1).*wwwp(3) + wwwp(2);
level_ag_gdp(i) = wwwp(3).*yap;
level_nag_gdp(i) = ynp;

end

disp('Sequence of Relative Wages: Agriculture to Non-Agriculture')
disp(mwagea./mwagen)

rel_wage_model = mwagea./mwagen;

cd('./Figures1_5')

save modelnew.mat relgdp empshr agshr price tfpdif_a tfpdif_n reltfp_a rel_wage_model

plot_agshare_final

plot_price_final

wm_plot

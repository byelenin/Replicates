clc
clear

cd('../Section 4 Results')

technology(1) = 100;
technology(2) = 1;
technology(3) = 1;

preferences(1) = 0.0039;
preferences(2) = 3.24;

distribution = [0.3696, 0.2314, 0.20]; % (1) is non-ag, (2) is ag (3)This is the correlation parameter

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('-------------------------------------------------------------------')

technology(1) = (1/21.5).*100;

wwwp = sim_compute_frechet(technology,preferences,distribution,0);

qr = wwwr(1:2)'; pr = [wwwr(3); 1];
qp = wwwp(1:2)'; pp = [wwwp(3); 1];
yyy = [wwwus(3); 1];

gdprich = sum(qr.*yyy); gdppoor = sum(qp.*yyy);

yap = wwwp(1)./(1-wwwp(4)); yar = wwwr(1)./(1-wwwr(4));
ynp = wwwp(2)./(wwwp(4)); ynr = wwwr(2)./(wwwr(4));

disp('Difference in GDP')
disp([gdprich./gdppoor])
disp('')
disp('Difference in AG TFP, and NAG TFP')
disp([yar./yap, ynr./ynp])

cd('..\Section 5 Results')
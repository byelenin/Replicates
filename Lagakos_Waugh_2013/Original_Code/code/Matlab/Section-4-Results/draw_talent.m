function talent = draw_talent(theta_dist,tau,ndraws)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program draws individual productivity draws for Selection paper, most 
% most recent update = 04/03/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load parameter_vector

rho = copulaparam('frank',tau);
randn('state',032878)
rand('twister',032878)
u = copularnd('frank',rho,ndraws);

Theta_n = theta_dist(1);
Theta_a = theta_dist(2);

delta_n = gamma(1-Theta_n).^-1;
delta_a = gamma(1-Theta_a).^-1;

rs = (-log(u(:,2))./delta_n.^(1./Theta_n)).^(-Theta_n);
ra = (-log(u(:,1))./delta_a.^(1./Theta_a)).^(-Theta_a);

talent = zeros(ndraws,2);
talent(:,1) = (rs);
talent(:,2) = (ra);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




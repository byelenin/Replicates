function talent = draw_talent(theta_dist,tau,ndraws)

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rand('twister',03281978)
% randn('seed',03281978)
% 
% Theta_n = theta_dist(1);
% Theta_a = theta_dist(2);
% Rho = tau;
% 
% cvr = Theta_a.^.5.*Theta_n.^.5.*Rho;
% mu = [0 0];
% Sigma = [Theta_n, cvr; cvr, Theta_a];
% [R] = chol(Sigma);
% 
% z = repmat(mu,ndraws,1) + randn(ndraws,2)*R;
% 
% talent = zeros(ndraws,2);
% 
% talent(:,1) = exp(z(:,1));
% talent(:,2) = exp(z(:,2));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




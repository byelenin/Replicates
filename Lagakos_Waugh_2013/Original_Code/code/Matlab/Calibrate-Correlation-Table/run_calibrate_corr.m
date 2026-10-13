function xzxz = run_calibrate_corr(rho)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 04/03/11
% This code calibrates the distribution parameters, for a given correlation
% parameter, rho. 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
options = optimset('TolFun',10^-2,'MaxFunEvals',500,'MaxIter',500,'Display','off','Largescale','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% New calibration 04/03/12 the computation of these moments are described
% in the paper.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% New calibration 04/03/12 the computation of these moments are described
% in the paper.
moments = [0.4733, 0.3795];
% The order is standard deviation of non-agriculture, agriculture. and 
% Average wages in agricultrue relative to non-agriculture are not a moment
% of interest here as it is free.
disp(moments)
W = eye(2);

theta_a_guess = linspace(.1,.65,3);
theta_n_guess = linspace(.15,.65,3);

[Theta_guess_a, Theta_guess_n]= meshgrid(theta_a_guess,theta_n_guess); 

Theta_guess_a = Theta_guess_a(:);
Theta_guess_n = Theta_guess_n(:);


rec_fval = zeros(length(Theta_guess_a),1);
xi_hat = zeros(length(Theta_guess_n),2);
tic
matlabpool open 8

parfor j = 1:length(Theta_guess_n)    
    
    guess = [log(1./Theta_guess_a(j) - 1)  log(1./Theta_guess_n(j) - 1)];    
    [xi_hat(j,:),rec_fval(j)] = fminsearch(@(xxx) loss_moments_data_corr(xxx,moments,W,rho), guess, options);
    disp(j)
    
end

toc
options = optimset('TolFun',10^-5,'MaxFunEvals',500,'MaxIter',500,'Display','iter','Largescale','off');

rrr = rec_fval == 0;
[val mind]=sort(rec_fval(~rrr));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[xi,fval] = fminsearch(@(xxx) loss_moments_data_corr_avg(xxx,moments,W,rho), xi_hat(mind(1),:), options);

theta_a = 1./(exp(xi(1))+1);
theta_n = 1./(exp(xi(2))+1);

disp('Theta_a,   Theta_n,   rho')
disp([theta_a, theta_n, rho])

zxzx = rec_fval(:)>=.01;
sum(zxzx);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Nsims = 1000;
sim_output = zeros(Nsims,3);

parfor sim = 1:Nsims
sim_output(sim,:) = compute_moments(theta_a,theta_n,rho,sim);
end
% 
output = mean(sim_output);

matlabpool close
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Standard Deviation non-ag, Standard Deviation Ag, Relative Wage')
disp([output(1), output(2), output(3)])
xzxz = [theta_a,theta_n,rho];

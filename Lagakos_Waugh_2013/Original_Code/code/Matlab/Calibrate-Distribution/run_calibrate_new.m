%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 04/03/11
% This code calibrates the distribution parameters. It basically, grids
% over the correlation values, finds thetas for each sector, takes the
% lowest value and then uses that as the starting point.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
options = optimset('TolFun',10^-2,'MaxFunEvals',500,'MaxIter',500,'Display','off','Largescale','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% New calibration 04/03/12 the computation of these moments are described
% in the paper.

moments = [0.4733, 0.3795, 0.7014]; 
% The order is standard deviation of non-agriculture, agriculture, and
% average wages in agricultrue relative to non-agriculture.
disp(moments)
W = eye(3);

theta_a_guess = linspace(.1,.65,4);
theta_n_guess = linspace(.15,.65,3);
rho_guess = linspace(.001,.5,5);

[Theta_guess_a, Theta_guess_n, Rho_guess]= meshgrid(theta_a_guess,theta_n_guess,rho_guess); 

Theta_guess_a = Theta_guess_a(:);
Theta_guess_n = Theta_guess_n(:);
Rho_guess = Rho_guess(:);

rec_fval = zeros(length(Rho_guess),1);
xi_hat = zeros(length(Rho_guess),3);
tic
matlabpool open 8
parfor j = 1:length(Rho_guess)    
    
    guess = [log(1./Theta_guess_a(j) - 1)  log(1./Theta_guess_n(j) - 1) log(1./Rho_guess(j) - 1)]; 
    % This right here is just a transformation to keep the coeffecients
    % within the parameter space %
    [xi_hat(j,:),rec_fval(j)] = fminsearch(@(xxx) loss_moments_data_simple(xxx,moments,W), guess, options);
    disp(j)
    
end

toc
options = optimset('TolFun',10^-5,'MaxFunEvals',500,'MaxIter',500,'Display','iter','Largescale','off');

rrr = rec_fval == 0;
[val mind]=sort(rec_fval(~rrr));

[xi,fval] = fminsearch(@(xxx) loss_moments_data_simple_avg(xxx,moments), xi_hat(mind(1),:), options);

matlabpool close

theta_a = 1./(exp(xi(1))+1)
theta_n = 1./(exp(xi(2))+1)
rho = 1./(exp(xi(3))+1)

zxzx = rec_fval(:)>=.01;
sum(zxzx)

plot(1./(exp(xi_hat(:,3))+1),log(rec_fval(:)),'b*')

compute_moments(theta_a, theta_n, rho,0)
copulaparam('frank',rho)


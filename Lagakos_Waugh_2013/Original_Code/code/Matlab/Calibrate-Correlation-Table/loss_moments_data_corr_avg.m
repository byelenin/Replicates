function zxzx = loss_moments_data_corr_avg(param, moments_data,W,rho)
theta_a = 1./(exp(param(1))+1);
theta_n = 1./(exp(param(2))+1);

Nsims = 100;
moments = zeros(Nsims,3);

parfor sim = 1:Nsims
moments(sim,:) = compute_moments(theta_a,theta_n,rho,sim);
end
% 
moments_model = mean(moments);
moments_model(3) = [];
loss = norm(log(moments_model(:))-log(moments_data(:)));

if isfinite(loss) ~= 1
    loss = 10^5;
end

if isreal(loss) ~= 1
    loss = 10^5;
end

zxzx = (loss);


function zxzx = loss_moments_data_corr(param, moments_data,W,rho)
theta_a = 1./(exp(param(1))+1);
theta_n = 1./(exp(param(2))+1);


moments_model = compute_moments(theta_a,theta_n,rho,0);
moments_model(3) = [];

loss = norm(log(moments_model(:))-log(moments_data(:)));

if isfinite(loss) ~= 1
    loss = 10^5;
end

if isreal(loss) ~= 1
    loss = 10^5;
end

zxzx = (loss);


%% Perform log-likelihood of macro-finance model (R&W)
Bm = zeros(8,3);
%measurement_errors = zeros(3,1);

gammaZ = [rho(1,:,i); rho(3,:,i); B(:,:,i)*rho(:,:,i)];
omegaZ1 = [sigma(1,:,i); sigma(3,:,i); B(:,:,i)*sigma(:,:,i)];
omegaZ2 = [zeros(2,3); Bm];
omegaZ = [omegaZ1 omegaZ2];
clear omegaZ1 omegaZ2


%% Initialize variables
coefficients_shortRate = [];
coefficients_Lt = [];
coefficients_St = [];
coefficients_residuals = [];
coefficients_inflation = [];
coefficients_outputGap = [];
res_it = [];
res_Lt = [];
res_St = [];
res_res = [];
res_pi = [];
res_y = [];
rho = zeros(7,7,u);
sigma = zeros(7,4,u);
ML_parameters = zeros(u,q);
ML_LogL = zeros(1,u);
F = zeros(7,w-1,u);
B = zeros(8,7,u);
A = zeros(8,1,u);
lastXi = zeros(u,2);
forecastErrors = zeros(3,16,u);
stateSpaceForecastMAE = zeros(3,16);
stateSpaceForecastRMSE = zeros(3,16);
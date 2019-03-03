%% Initialize variables
coefficients_shortRate = [];
coefficients_Lt = [];
coefficients_St = [];
coefficients_residuals = [];
coefficients_inflation = [];
coefficients_outputGap = [];
coefficients_unemployment = [];
coefficients_nairu = [];
res_it = [];
res_Lt = [];
res_St = [];
res_res = [];
res_pi = [];
res_y = [];
res_nu = [];
res_nustar = [];
rho = zeros(10,10,u);
sigma = zeros(10,6,u);
ML_parameters = zeros(u,q);
ML_LogL = zeros(1,u);
F = zeros(7,w-1,u);
B = zeros(8,7,u);
A = zeros(8,1,u);
lastXi = zeros(u,2);
forecastsX = zeros(u,3,16);
forecastsXi = zeros(u,2,16);
forecastErrors = zeros(3,16,u);
stateSpaceForecastMAE = zeros(3,16);
stateSpaceForecastRMSE = zeros(3,16);
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
rho = zeros(7,7,93);
sigma = zeros(7,4,93);
ML_parameters = zeros(93,15);
ML_LogL = zeros(1,93);
F = zeros(7,39,93);
B = zeros(8,7,93);
A = zeros(8,1,93);
lastXi = zeros(93,2);
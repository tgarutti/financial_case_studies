%% Initialize variables
coefficients_shortRate = [];
coefficients_Lt = [];
coefficients_St = [];
coefficients_residuals = [];
coefficients_inflation = [];
coefficients_outputGap = [];
coefficients_Ft1  = [];
coefficients_Ft2  = [];
coefficients_Ft3  = [];
coefficients_Ft4  = [];
coefficients_Ft5  = [];
coefficients_Ft6  = [];
coefficients_Ft7  = [];
coefficients_Ft8  = [];
coefficients_Ft9  = [];
coefficients_Ft10 = [];
res_it = [];
res_Lt = [];
res_St = [];
res_res = [];
res_pi = [];
res_y = [];
res_Ft1  = [];
res_Ft2  = [];
res_Ft3  = [];
res_Ft4  = [];
res_Ft5  = [];
res_Ft6  = [];
res_Ft7  = [];
res_Ft8  = [];
res_Ft9  = [];
res_Ft10 = [];
rho = zeros(7,7,u);
sigma = zeros(7,4,u);
ML_parameters = zeros(u,q);
ML_LogL = zeros(1,u);
F = zeros(7,w-1,u);
B = zeros(8,7,u);
A = zeros(8,1,u);
lastXi = zeros(u,2);
%% Load data
load_data

%% Normalize the principle components of the yield curve data
normPCs = normalize(PCs);

%% Define regression window and variables
w = 40; % widnow length of 10 years
n = length(inflation);
Lt = normPCs(:,1);
St = normPCs(:,2);

%% Plots
 %plots

%% Moving window regressions -> coefficient matrix
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

for i = 1:(n-w+1)
    window = i:(i+w-1);
    run_regressions % Runs regressions from a separate file "run_regressions.m"
    
     
end
%clear w n i window
coefficients = table(coefficients_shortRate, coefficients_Lt,...
    coefficients_St, coefficients_residuals, coefficients_inflation,...
    coefficients_outputGap);

clear res_it res_Lt res_pi res_res res_St res_y
clear coefficients_inflation coefficients_Lt coefficients_outputGap...
    coefficients_residuals coefficients_shortRate coefficients_St

%% Run the Sims algorithm

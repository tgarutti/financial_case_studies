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

%% Moving window regressions and Sims algorithm
initialize_variables

for i = 1:(n-w+1)
    window = i:(i+w-1);
    run_regressions % Runs regressions from a separate file "run_regressions.m"
    
    macroStateSpace
    
    clear X_it X_lt X_pi X_res X_st X_y
    clear Y_it Y_lt Y_pi Y_res Y_st Y_y
    clear coefit coefLt coefpi coefres coefSt coefy
    clear residualit residualLt residualpi residualres residualSt residualy
    clear Gamma Omega eu
end
%clear w n i window
coefficients = table(coefficients_shortRate, coefficients_Lt,...
    coefficients_St, coefficients_residuals, coefficients_inflation,...
    coefficients_outputGap);

clear res_it res_Lt res_pi res_res res_St res_y
clear coefficients_inflation coefficients_Lt coefficients_outputGap...
    coefficients_residuals coefficients_shortRate coefficients_St

%% Run the Sims algorithm

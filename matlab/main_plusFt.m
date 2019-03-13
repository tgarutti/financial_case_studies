%% Load data
load_data

%% Normalize the principle components of the yield curve data
normPCs = normalize(PCs);

%% Define regression window and variables
w = 80; % Window length of 10 years
n = length(inflation);
u = n-w+1; % Number of filters
q = 50; % Number of parameters for Kalman ML estimation
%m = 0; % Counter for Kalman filter
Lt = normPCs(:,1);
St = normPCs(:,2);

%% Plots
%plots

%% Moving window regressions and Sims algorithm
initialize_variables_plusFt
global predictedxi

for i = 1:u
    %m = m+1;
    window = i:(i+w-1);
    run_regressions_plusFt % Runs regressions
    %coefficientsB   % Obtains the B coefficients for the yield curve
    macroStateSpace_plusFt % Runs the Kalman filter and performs MLE
    lastXi(i,:) = predictedxi(:,end)'; % Sets end values of filtered variables
end

coefficients = table(coefficients_shortRate, coefficients_Lt,...
    coefficients_St, coefficients_residuals, coefficients_inflation,...
    coefficients_outputGap, coefficients_Ft1, coefficients_Ft2,...
    coefficients_Ft3, coefficients_Ft4, coefficients_Ft5,...
    coefficients_Ft6, coefficients_Ft7, coefficients_Ft8,...
    coefficients_Ft9, coefficients_Ft10);

clear_variables
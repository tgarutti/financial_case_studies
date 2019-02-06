%% Load data
load_data

%% Normalize the principle components of the yield curve data
normPCs = normalize(PCs);

%% Define regression window and variables
w = 40; % Window length of 10 years
n = length(inflation);
Lt = normPCs(:,1);
St = normPCs(:,2);

%% Plots
%plots

%% Moving window regressions and Sims algorithm
initialize_variables
global xi

for i = 1:(n-w+1)
    window = i:(i+w-1);
    run_regressions % Runs regressions from a separate file "run_regressions.m"
    coefficientsB % Obtains the B coefficients for the yield curve
    %macroStateSpace % Runs the Kalman filter and performs MLE
    lastXi(i,:) = xi(:,end)'; % Sets end values of filtered variables
end

coefficients = table(coefficients_shortRate, coefficients_Lt,...
    coefficients_St, coefficients_residuals, coefficients_inflation,...
    coefficients_outputGap);

clear_variables
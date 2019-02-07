%% Load data
load_data

%% Normalize the principle components of the yield curve data
normPCs = normalize(PCs);

%% Define regression window and variables
w = 132; % Window length of 10 years
n = length(inflation);
u = n-w+1; % Number of filters
Lt = normPCs(:,1);
St = normPCs(:,2);

%% Plots
%plots

%% Moving window regressions and Sims algorithm
initialize_variables
global predictedxi

for i = 1:u
    window = i:(i+w-1);
    run_regressions % Runs regressions
    coefficientsB   % Obtains the B coefficients for the yield curve
    macroStateSpace % Runs the Kalman filter and performs MLE
    lastXi(i,:) = predictedxi(:,end)'; % Sets end values of filtered variables
end

coefficients = table(coefficients_shortRate, coefficients_Lt,...
    coefficients_St, coefficients_residuals, coefficients_inflation,...
    coefficients_outputGap);

clear_variables
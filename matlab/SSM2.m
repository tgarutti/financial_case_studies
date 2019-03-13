%% Load data
load_data

%% Normalize the principle components of the yield curve data
normPCs = normalize(PCs);

%% Define regression window and variables
k = 16;
w = 80; % Window length of 20 years
n = length(inflation);
u = n-w+1; % Number of filters
q = 56; % Number of parameters for Kalman ML estimation
Lt = normPCs(:,1);
St = normPCs(:,2);

%% Moving window regressions and Sims algorithm
initialize_variables_unemp

for i = 1:u
    window = i:(i+w-1);
    run_regressions_plusFt_unemployment % Runs regressions with PCs
    %coefficientsB   % Obtains the B coefficients for the yield curve
    macroStateSpace_plusFt_unemployment % Runs the Kalman filter and performs MLE
end

for s=1:16
    stateSpaceForecastMAE(:,s) = mean(abs(forecastErrors(:,s,1:end-s-1)),3);
    stateSpaceForecastRMSE(:,s) = sqrt(mean(forecastErrors(:,s,1:end-s-1).^2,3));
end

SSM_MAE = zeros(3,16);
SSM_RMSE = zeros(3,16);
SSM_errors = zeros(u,3,16);
AR_errors = zeros(u,3,16);
AR_MAE = zeros(3,16);
AR_RMSE = zeros(3,16);

for j = 1:16
    f_w = (w+j):length(inflation);
    f = forecastsX(1:(end-j),:,j);
    actuals = [shortRate(f_w) inflation(f_w) outputGap(f_w)];
    [SSM_RMSE(:,j), SSM_MAE(:,j), SSM_errors(1:(end-j),:,j)] = evaluate_forecasts(f, actuals);
    [AR_RMSE(:,j), AR_MAE(:,j)] = evaluate_forecasts(forecastsAR(1:(end-j),:,j), actuals);
end

coefficients = table(coefficients_shortRate, coefficients_Lt,...
    coefficients_St, coefficients_residuals, coefficients_inflation,...
    coefficients_outputGap);

clear_variables
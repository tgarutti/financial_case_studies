%% Load data
load_data

%% Normalize the principle components of the yield curve data
normPCs = normalize(PCs);

%% Define regression window and variables
k = 16;
w = 80; % Window length of 20 years
n = length(inflation);
u = n-w+1; % Number of filters
q = 33; % Number of parameters for Kalman ML estimation
Lt = normPCs(:,1);
St = normPCs(:,2);

%% Moving window regressions and Sims algorithm
initialize_variables

for i = 1:u
    window = i:(i+w-1);
    run_regressions % Runs regressions with PCs
    %coefficientsB   % Obtains the B coefficients for the yield curve
    macroStateSpace % Runs the Kalman filter and performs MLE
end

for s=1:16
    stateSpaceForecastMAE(:,s) = mean(abs(forecastErrors(:,s,1:end-s-1)),3);
    stateSpaceForecastRMSE(:,s) = sqrt(mean(forecastErrors(:,s,1:end-s-1).^2,3));
end

SSM_MAE = zeros(3,16);
SSM_RMSE = zeros(3,16);
AR_MAE = zeros(3,16);
AR_RMSE = zeros(3,16);

for k = 1:16
    f_w = (w+k):length(inflation);
    f = forecastsX(1:(end-k),:,k);
    actuals = [shortRate(f_w) inflation(f_w) outputGap(f_w)];
    [SSM_RMSE(:,k), SSM_MAE(:,k)] = evaluate_forecasts(f, actuals);
    [AR_RMSE(:,k), AR_MAE(:,k)] = evaluate_forecasts(forecastsAR(1:(end-k),:,k), actuals);
end

coefficients = table(coefficients_shortRate, coefficients_Lt,...
    coefficients_St, coefficients_residuals, coefficients_inflation,...
    coefficients_outputGap);

clear_variables
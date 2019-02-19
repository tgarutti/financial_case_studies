function [ forecastsX, MAE, RMSE ] = forecast_SSM( model, w, l )
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
%% Load data
load_data_temp

%% Normalize the principle components of the yield curve data
normPCs = normalize(PCs);

%% Define regression window and variables
n = length(inflation);
u = n-w+1; % Number of filters
q = 53; % Number of parameters for Kalman ML estimation
Lt = normPCs(:,1);
St = normPCs(:,2);

%% Moving window regressions and Sims algorithm
initialize_variables

for i = 1:u
    window = i:(i+w-1);
    if model == 'PC'
        run_regressions_plusFt % Runs regressions 
        macroStateSpace_plusFt % Runs the Kalman filter and performs MLE
    elseif model == 'unemployment'
        run_regressions_plusFt_unemployment % Runs regressions 
        macroStateSpace_plusFt_unemployment % Runs the Kalman filter and performs MLE
    else
        run_regressions
        macroStateSpace
    end
end

for s=1:16
    stateSpaceForecastMAE(:,s) = mean(abs(forecastErrors(:,s,1:end-s-1)),3);
    stateSpaceForecastRMSE(:,s) = sqrt(mean(forecastErrors(:,s,1:end-s-1).^2,3));
end

MAE = zeros(3,16);
RMSE = zeros(3,16);
for l = 1:16
    f_w = (w+l):length(inflation);
    f = forecastsX(1:(end-l),:,l);
    actuals = [shortRate(f_w) inflation(f_w) outputGap(f_w)];
    [RMSE(:,l), MAE(:,l)] = evaluate_forecasts(f, actuals);
end

coefficients = table(coefficients_shortRate, coefficients_Lt,...
    coefficients_St, coefficients_residuals, coefficients_inflation,...
    coefficients_outputGap);

clear_variables

end


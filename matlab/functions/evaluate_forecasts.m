function [ RMSE, MAE ] = evaluate_forecasts( forecasts, actuals )
%EVALUATE_FORECASTS Evaluates forecasts: RMSE and MAE
%   Evaluates the forecasts versus the actual values and calculates
%   RMSE and MAE for each column of forecasts. Column 1 of forecasts
%   must therefore correspond to column 1 of actuals.

diff = forecasts - actuals;
MAE = mean(abs(diff),1);
RMSE = sqrt(mean(diff.^2,1));
end
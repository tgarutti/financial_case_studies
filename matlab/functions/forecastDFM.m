function [ forecasts, MAE, RMSE, errors ] = forecastDFM( Y, X, favar, var, w, k,...
    SR, shortRate)
%FORECASTDFM Forecasts a dynamic factor model specified by favar and var
%for a given window and forecast horizon.
%   The dynamic factor model is given by
%   (1)    Y(t) = A*Y(t-1) + B*X(t),
%   (2)    X(t) = C*X(t-1),
%   where the relation (1) is specified by favar and (2) by var. The
%   objects favar and var need to be inputted as varm objects
%   This is forecasted over a moving window of length w for forecast 
%   horizons of 1-k.
%   SR is a boolean specifying if the short rate should be estimated by
%   means of the Bernanke equation using the forecasts of Y. 
%% Initialization of variables
if SR == true
    c = size(Y,2)+1;
else
    c = size(Y,2);
end
n = length(Y(:,1)); 
u = n-w+1;

forecasts = zeros(u, c, k);

%% Estimate Forecasts
for i = 1:u
    window = i:(i+w-1);
    
    Yw = Y(window,:);
    Xw = X(window,:);
    
    [XFit,~,~,~] = estimate(var, Xw);
    [Xforecasts,~] = forecast(XFit, k, Xw);
    
    [YFit,~,~,~] = estimate(favar, Yw, 'X', Xw);
    [Yforecasts,~] = forecast(YFit, k, Yw, 'X', Xforecasts);
    
    b = regress(shortRate(window), [ones(length(window),1) Yw]);
    gy  = b(3);
    gPi = b(2)-1;
    r   = b(1)+0.02*gPi;
    
    for j = 1:k
        if SR == true
            forecasts(i,2:end,j) = Yforecasts(j,:);
            forecasts(i,1,j) = 0.02 + 1.0*forecasts(i,3,j) + ...
                1.5*forecasts(i,2,j) - 0.5*0.02;
            
            forecasts(i,1,j) = r + (1+gPi)*forecasts(i,2,j) + ...
                gy*forecasts(i,3,j);
        else
            forecasts(i,:,j) = Yforecasts(j,:);
        end
    end
end
forecasts = forecasts(:,1:3,:);

%% Evaluate forecasts
RMSE = zeros(3,k);
MAE = zeros(3,k);
errors = zeros(u-1, 3, k);
for i = 1:k
    f_w = (w+i):n;
    f = forecasts(1:(end-i),1:3,i);
    actuals = [shortRate(f_w) Y(f_w,1:2)];
    [RMSE(:,i), MAE(:,i), errors(i:end,:,i)] = evaluate_forecasts(f, actuals);
end
end
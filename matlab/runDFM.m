%% Forecast the dynamic factor model
forecasts = zeros(u,size(X,2)+2, k);
for i = 1:u
    window = i:(i+w-1);
    
    Xw = X(window,:);
    PCw = PCOrtec(window,:);
    
    var = varm(size(PCw,2),lags);
    var = varm('AR',{diag(nan(size(PCw,2),1))});
    
    [PCFit,~,~,~] = estimate(var, PCw);
    [PCforecasts,~] = forecast(PCFit, k, PCw);
    
    
    favar = varm('AR', {macroSpec1});
    [dfmFit,~,~,~] = estimate(favar, Xw, 'X', PCw);
    [f,~] = forecast(dfmFit, k, Xw, 'X', PCforecasts);
    
    b = regress(shortRate(window), [ones(length(window),1) Xw]);
    gy  = b(3);
    gPi = b(2)-1;
    r   = b(1)+0.02*gPi;
    for j = 1:k
        forecasts(i,3:end,j) = f(j,:);
        forecasts(i,1,j) = 0.02 + 1.0*forecasts(i,4,j) + ...
            1.5*forecasts(i,3,j) - 0.5*0.02;
        forecasts(i,2,j) = r + (1+gPi)*forecasts(i,3,j) + gy*forecasts(i,4,j);
    end
end

clear Xw PCw favar f b gy gPi r i j window

%% Forecast evaluation
for i = 1:k
    f_w = (w+i):length(inflation);
    f = forecasts(1:(end-i),1:4,i);
    actuals = [shortRate(f_w) shortRate(f_w) X(f_w,1:2)];
    [RMSE(:,i,model), MAE(:,i,model)] = evaluate_forecasts(f, actuals);
end
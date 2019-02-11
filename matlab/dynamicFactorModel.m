%% Load data
load_data
%% Normalize the principle components of the yield curve data
normPCs = normalize(PCs);

%% Define regression window and variables
w = 80; % Window length of 10 years
n = length(inflation);
u = n-w+1; % Number of filters
X = 100*[inflation outputGap];
% X = 100*[inflation outputGap unemployment];
k = 4; % k-step ahead forecast

%% Forecast the dynamic factor model
forecasts = zeros(u,size(X,2)+2, k);
for i = 1:u
    window = i:(i+w-1);
    
    Xw = X(window,:);
    PCw = PCOrtec(window,:);
    favar = varm(size(X,2),2);
    [estFit,~,~,~] = estimate(favar, Xw, 'X', PCw);
    [f, fMSE] = forecast(estFit, k, Xw, 'X', PCw);
    b = regress(100*shortRate(window), [ones(length(window),1) Xw]);
    gy  = b(3);
    gPi = b(2)-1;
    r   = b(1)+0.02*gPi;
    for j = 1:k
        forecasts(i,3:end,j) = f(j,:);
        forecasts(i,2,j) = 2 + 1.0*forecasts(i,4,j) + ...
            1.5*forecasts(i,3,j) - 0.5*2;
        forecasts(i,1,j) = r + (1+gPi)*forecasts(i,3,j) + gy*forecasts(i,4,j);
    end
end

clear Xw PCw favar estFit f fMSE b gy gPi r i j 

%% Forecast evaluation
%% Load data
load_data

%% Normalize the principle components of the yield curve data
normPCs = normalize(PCs);

%% Define regression window and variables
w = 80; % Window length of 10 years
n = length(inflation);
u = n-w+1; % Number of filters
X = 100*[inflation outputGap unemployment];

%% Forecast the dynamic factor model
forecasts = zeros(u,size(X,2)+1);
for i = 1:u
    window = i:(i+w-1);
    
    Xw = X(window,:);
    PCw = PCOrtec(window,:);
    favar = varm(3,2);
    [estFit,~,~,~] = estimate(favar, Xw, 'X', PCw);
    [f, fMSE] = forecast(estFit, 1, Xw, 'X', PCw);
    forecasts(i,2:end) = f;
end
%% Load data
load_data
%% Normalize the principle components of the yield curve data
normPCs = normalize(PCs);

%% Initialize variables for model comparison
k = 16; % k-step ahead forecast
w = 80; % Window length
lags = 1;
RMSE = zeros(4, k, 2);
MAE = zeros(4, k, 2);
eval = zeros(4, k, 2);

%% Define variables for model without unemployment
model = 1;
n = length(inflation);
u = n-w+1; % Number of filters
X = [inflation outputGap];
macroSpec1 = [NaN NaN; NaN NaN];
macroSpec2 = diag(nan(2,1));

%% Forecast the dynamic factor model
forecastDFM

%% Define variables for model with unemployment
model = 2;
n = length(inflation);
u = n-w+1; % Number of filters
X = [inflation outputGap unemployment];
macroSpec1 = [NaN NaN 0; NaN NaN NaN; 0 0 NaN];
macroSpec2 = diag(nan(3,1));

%% Forecast the dynamic factor model
forecastDFM
clear PCFit f_w f dfmFit i var
%% Compare models
eval(:,:,1) = MAE(:,:,2)./MAE(:,:,1);
eval(:,:,2) = RMSE(:,:,2)./RMSE(:,:,1);
eval = eval(:,[1,2,3,4,8,12,16],:);
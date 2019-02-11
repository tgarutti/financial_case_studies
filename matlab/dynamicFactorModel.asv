%% Load data
load_data
%% Normalize the principle components of the yield curve data
normPCs = normalize(PCs);

%% Initialize variables for model comparison
k = 16; % k-step ahead forecast
w = 80; % Window length
lags = 2;
RMSE = zeros(4, k, 2);
MAE = zeros(4, k, 2);
eval = zeros(4, k, 2);

%% Define variables for model without unemployment
model = 1;
n = length(inflation);
u = n-w+1; % Number of filters
X = [inflation outputGap];

%% Forecast the dynamic factor model
forecastDFM

%% Define variables for model with unemployment
model = 2;
n = length(inflation);
u = n-w+1; % Number of filters
X = [inflation outputGap unemployment];

%% Forecast the dynamic factor model
forecastDFM

%% Compare models
eval(:,:,1) = MAE(:,:,2)./MAE(:,:,1);
eval(:,:,2) = RMSE(:,:,2)./RMSE(:,:,1);
eval = eval(:,[1,2,3,4,8,12,16],:);
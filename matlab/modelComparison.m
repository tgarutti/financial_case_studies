%% COMPLETE MODEL COMPARISON
%% Load data and setup initial variables
load_data
normPCs = normalize(PCs);
clear dates de_inflation de_outputGap de_shortRate interpYields pad ...
    originalYields
%PCOrtec = PCOrtec/100;

%% Define regression window and variables
w = 80; % Window length of 20 years
n = length(inflation);
u = n-w+1; % Number of forecasts
m = 4; % Number of models
k = 16; % Forecast horizon
forecasts = zeros(u, 3, k, m);
MAE = zeros(3, k, m);
RMSE = zeros(3, k, m);

%% Model specification 1: Strictly statistical (factor) model
Y = [inflation outputGap];
X = PCOrtec;
var = varm(size(X,2),2); % Autoregressive dynamic of X
macroSpec = [0 0; 0 0]; % No autoregressive dynamic of Y
favar = varm('AR', {macroSpec});
[forecasts(:,:,:,1), MAE(:,:,1), RMSE(:,:,1)] = ...
    forecastDFM( Y, X, favar, var, w, k, true, shortRate);
clear Y X var macroSpec favar

%% Model specification 2: FAVAR model without unemployment
Y = [inflation outputGap];
X = PCOrtec;
var = varm('AR',{diag(nan(size(X,2),1))}); % Autoregressive dynamic of X
macroSpec = [NaN NaN; NaN NaN]; % No autoregressive dynamic of Y
favar = varm('AR', {macroSpec});
[forecasts(:,:,:,2), MAE(:,:,2), RMSE(:,:,2)] = ...
    forecastDFM( Y, X, favar, var, w, k, true, shortRate);
clear Y X var macroSpec favar

%% Model specification 3: FAVAR model with unemployment
Y = [inflation outputGap unemployment];
X = PCOrtec;
var = varm('AR',{diag(nan(size(X,2),1))}); % Autoregressive dynamic of X
macroSpec = [NaN NaN NaN; NaN NaN NaN; NaN NaN NaN]; % No autoregressive dynamic of Y
favar = varm('AR', {macroSpec});
[forecasts(:,:,:,3), MAE(:,:,3), RMSE(:,:,3)] = ...
    forecastDFM( Y, X, favar, var, w, k, true, shortRate);
clear Y X var macroSpec favar

%% Model specification 4: FAVAR model with unemployment and restrictions
Y = [inflation outputGap unemployment];
X = PCOrtec;
var = varm('AR',{diag(nan(size(X,2),1))}); % Autoregressive dynamic of X
macroSpec = [NaN NaN 0; NaN NaN NaN; 0 0 NaN]; % No autoregressive dynamic of Y
favar = varm('AR', {macroSpec});
[forecasts(:,:,:,4), MAE(:,:,4), RMSE(:,:,4)] = ...
    forecastDFM( Y, X, favar, var, w, k, true, shortRate);
clear Y X var macroSpec favar

%% Model specification 5: State-space model benchmark
SSM;

%% Model specification 6: State-space model benchmark
SSM1;

%% Model specification 7: State-space model benchmark
SSM2;

%% Setup for State Space Models
q = 33; % Number of parameters for Kalman ML estimation
Lt = normPCs(:,1);
St = normPCs(:,2);

%% Model comparison to benchmark
copmarisonMAE = zeros(3, k, m);
copmarisonRMSE = zeros(3, k, m);
for i=1:m
    copmarisonMAE(:,:,i) = MAE(:,:,i)./MAE(:,:,1);
    copmarisonRMSE(:,:,i) = RMSE(:,:,i)./RMSE(:,:,1);
end
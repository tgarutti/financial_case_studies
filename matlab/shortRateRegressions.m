%% Load data
load_data

%% Regressions of short rate on inflation & output gap and an ARX(1) model
T     = size(inflation,1);
preT  = size(inflation(1:32),1);
postT = size(inflation(33:end),1);

bFull = regress(shortRate, [ones(T,1) inflation outputGap]);
bPre  = regress(shortRate(1:preT), [ones(preT,1) inflation(1:preT) outputGap(1:preT)]);
bPost = regress(shortRate(33:end), [ones(postT,1) inflation(33:end) outputGap(33:end)]);

% ARX(1) model
%arx = arima(1,0,0);
%ARX = estimate(arx,shortRate(1:end-1,:),'X',[inflation outputGap]);

%% Backout the coefficients of the Taylor rule from both models
gy  = bFull(3);
gPi = bFull(2)-1;
r   = bFull(1)+0.02*gPi;

%shortRatePhi = ARX.AR{1};
%gyAR         = ARX.Beta(2);
%gPiAR        = ARX.Beta(1)-1;
%rAR          = ARX.Constant+0.02*gPiAR;

%% CD to working directory
clc;
clear;
pad = '../data/';
cd(pad);
format short

%% Load data
filename = 'data_ortec';
[~,dates,~]      = xlsread(filename,'Global PCA','A5:A180'); % Only from 1993 onward!!!
[inflation,~]    = xlsread(filename,'United States','F5:F180');
[outputGap,~]    = xlsread(filename,'United States','D5:D180');
[unemployment,~] = xlsread(filename,'United States','J5:J180');
[shortRate,~]    = xlsread(filename,'United States','H5:H180');

%% Regressions of short rate on inflation & output gap and an ARX(1) model
T     = size(inflation,1);
preT  = size(inflation(1:73),1);
postT = size(inflation(74:end),1);

bFull = regress(shortRate, [ones(T,1) inflation outputGap]);
bPre  = regress(shortRate(1:preT), [ones(preT,1) inflation(1:preT) outputGap(1:preT)]);
bPost = regress(shortRate(74:end), [ones(postT,1) inflation(74:end) outputGap(74:end)]);

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

%% CD to working directory
clc;
clear;
pad = '../data/';
cd(pad);
format short

%% Load data
filename = 'data_ortec';
[~,dates,~]      = xlsread(filename,'Global PCA','A78:A180'); % Only from 1993 onward!!!
[inflation,~]    = xlsread(filename,'United States','E78:E180');
[outputGap,~]    = xlsread(filename,'United States','D78:D180');
[unemployment,~] = xlsread(filename,'United States','J78:J180');
[shortRate,~]    = xlsread(filename,'United States','H78:H180');

%% Regressions of short rate on inflation & output gap and an ARX(1) model
T = size(inflation,1);
b = regress(shortRate, [ones(T,1) inflation outputGap]);

% ARX(1) model
arx = arima(1,0,0);
ARX = estimate(arx,shortRate(1:end-1,:),'X',[inflation outputGap]);

%% Backout the coefficients of the Taylor rule from both models
gy  = b(3);
gPi = b(2)-1;
r   = b(1)-0.02*gPi;

shortRatePhi = ARX.AR{1};
gyAR         = ARX.Beta(2);
gPiAR        = ARX.Beta(1)-1;
rAR          = ARX.Constant-0.02*gPiAR;
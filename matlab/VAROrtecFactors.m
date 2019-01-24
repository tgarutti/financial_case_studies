%% CD to working directory
clc;
clear;
pad = '../data/';
cd(pad);
format short

%% Load data
filename = 'data_ortec';
[~,dates,~]      = xlsread(filename,'Global PCA','A5:A180');
[PCOrtec,~]      = xlsread(filename,'Global PCA','B5:K180');
[inflation,~]    = xlsread(filename,'United States','E5:E180');
[outputGap,~]    = xlsread(filename,'United States','D5:D180');
[unemployment,~] = xlsread(filename,'United States','J5:J180');

%% Investigate correlations between observed data and PC
fullDataSet  = [PCOrtec inflation outputGap unemployment];
correlations = corrcoef(fullDataSet);

% Use only PCs 1,3,4,6,9 as the remaining 5 do not correlate strongly with
% the data under consideration
reducedPC = [PCOrtec(:,1) PCOrtec(:,3) PCOrtec(:,4) PCOrtec(:,6) PCOrtec(:,9)];

%% Create VAR(1) model for Ortec's (reduced) PC components
Mdl = varm(size(reducedPC,2),1);
[factorVAR,SE] = estimate(Mdl,reducedPC);

%%
tVals = factorVAR.AR{1}./SE.AR{1};
pVals = 2*(1-tcdf(abs(tVals),size(reducedPC,1)-1));

%%%%%%% THIS IS A COMMENT %%%%%%%%%
%% CD to data directory
clc;
clear;
pad = '../data/';
cd(pad);
format short

%% Load data (1985-03 to 2017-12)
filename = 'data_ortec';
[~,dates,~]      = xlsread(filename,'Global PCA','A46:A177');
[inflation,~]    = xlsread(filename,'United States','F46:F177');
[outputGap,~]    = xlsread(filename,'United States','D46:D177');
[unemployment,~] = xlsread(filename,'United States','J46:J177');
[nairu,~] = xlsread(filename,'United States','K46:K177');
[shortRate,~]    = xlsread(filename,'United States','H46:H177');

filename = 'yieldCurveOrtec';
[~,~,~]      = xlsread(filename,'Interpolated Data','A5:A136');
[originalYields,~]    = xlsread(filename,'Original Data','B46:K177');
[interpYields,~]    = xlsread(filename,'Interpolated Data','B5:K136');
[PCs,~]    = xlsread(filename,'Principal Components','B2:i133');

%% CD to working directory
pad = '../matlab/';
cd(pad);
format short
addpath(genpath('./functions'));
addpath(genpath('./sims_algorithm'));

%% Initiate variables 
coefficients_shortRate = [];
coefficients_Lt = [];
coefficients_St = [];
coefficients_residuals = [];
coefficients_inflation = [];
coefficients_outputGap = [];

res_it = [];
res_Lt = [];
res_St = [];
res_res = [];
res_pi = [];
res_y = [];

%% Clear not needed variables
clear filename
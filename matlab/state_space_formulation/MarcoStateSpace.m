clc;
clear;
format short

%% Load data
filename = '../../data/data_ortec';
[~,dates,~]      = xlsread(filename,'Global PCA','A5:A180');
[PCOrtec,~]      = xlsread(filename,'Global PCA','B5:K180');
[inflation,~]    = xlsread(filename,'United States','F5:F180');
[outputGap,~]    = xlsread(filename,'United States','D5:D180');
[unemployment,~] = xlsread(filename,'United States','J5:J180');
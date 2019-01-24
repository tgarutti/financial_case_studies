%% CD to working directory
clc;
clear;
pad = '../data/';
cd(pad);
format short

%% Load data
filename = 'data_ortec';
[~,dates,~]      = xlsread(filename,'Global PCA','A5:A180');
[inflation,~]    = xlsread(filename,'United States','E5:E180');
[outputGap,~]    = xlsread(filename,'United States','D5:D180');
[unemployment,~] = xlsread(filename,'United States','J5:J180');
[shortRate,~]    = xlsread(filename,'United States','H5:H180');

%% Regressions of short rate on inflation & output gap and an ARX(1) model
T = size(inflation,1);
b = regress(shortRate, [ones(T,1) inflation outputGap]);

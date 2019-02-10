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
[inflation,~]    = xlsread(filename,'United States','F5:F180');
[outputGap,~]    = xlsread(filename,'United States','D5:D180');
[unemployment,~] = xlsread(filename,'United States','J5:J180');

%% Investigate correlations between observed data and PC
fullDataSet  = [PCOrtec inflation outputGap unemployment];
correlations = corrcoef(fullDataSet);

% Use only PCs 1,3,4,6,9 as the remaining 5 do not correlate strongly with
% the data under consideration
reducedPC = [PCOrtec(:,1) PCOrtec(:,3) PCOrtec(:,4) PCOrtec(:,6) PCOrtec(:,9)];

%% Create VAR(1) model for Ortec's (reduced) PC components
pcvar = varm(size(PCOrtec,2),1);
[PCVAR,SE] = estimate(pcvar,PCOrtec);

%% p-values for factor VAR(1) model
tVals   = PCVAR.AR{1}./SE.AR{1};
pVals   = 2*(1-tcdf(abs(tVals),size(PCOrtec,1)-1));
statSig = zeros(10,10);

% Check significance of the AR coefficients at the 99% level, 1 means
% significant, 0 means not significant
for i=1:10
    for j=1:10
        if pVals(i,j) >= 0.01
            statSig(i,j) = 0;
        else
            statSig(i,j) = 1;
        end
    end
end

%% Create FAVAR(1) model of the observed data w/ 10 PC (lowest AIC)
favar = varm(3,2);
[FAVAR,EstSE] = estimate(favar,[inflation outputGap unemployment],'X',PCOrtec);
[FAVAR,EstSE] = estimate(favar,[inflation outputGap unemployment]);

%% 
tValsAR1   = FAVAR.AR{1} ./ EstSE.AR{1};
pValsAR1   = 2*(1-tcdf(abs(tValsAR1),size(PCOrtec,1)+3-1));
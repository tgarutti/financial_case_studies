%% Clear
clc;
clear;
pad = 'C:/Users/Themis/OneDrive/Documents/MSC QF/Advanced Time Series Econometrics/Assignment/start/Assignment/matlab';
cd(pad);
format short

%% Load data
load('data')
dates = data(1:end,1)+datenum('31/12/1899','dd/mm/yyyy'); 
y = data(1:end,[2:3])';
mu1 = mean(y(1,:));
mu2 = mean(y(2,:));
for j=1:length(y)
    y(1,j) = y(1,j)-mu1;
    y(2,j) = y(2,j)-mu2;
end

%% ML Estimation
clearvars options
options = optimset('fmincon');
lb = [0;0;0];
ub = [1;inf;inf];
startingvaluesGDP   = [1;1/3*var(y(1,:));2/3*var(y(1,:))];
startingvaluesPrice = [1;1/3*var(y(2,:));2/3*var(y(2,:))];

[ML_parameters_GDP,ML_LogL_GDP]=fmincon('NegativeLogLikelihood',...
    startingvaluesGDP,[],[],[],[],lb,ub,[],options,y(1,:));

[ML_parameters_Price,ML_LogL_Price]=fmincon('NegativeLogLikelihood',...
    startingvaluesPrice,[],[],[],[],lb,ub,[],options,y(2,:));

ML_std_GDP   = sqrt(diag(inv(fdhess6('NegativeLogLikelihood',ML_parameters_GDP,y(1,:)))));
ML_std_Price = sqrt(diag(inv(fdhess6('NegativeLogLikelihood',ML_parameters_Price,y(2,:)))));

%% Use built in State-Space Models
initQ = (1/3)*cov(y(1,:),y(2,:));
initR = (2/3)*cov(y(1,:),y(2,:));

startingvalues = [0,0,0,0,...
    initQ(1,1),initQ(1,2),initQ(2,1),initQ(2,2),...
    initR(1,1),initR(1,2),initR(2,1),initR(2,2)];

A = [NaN NaN;NaN NaN];
B = [NaN NaN;NaN NaN];
C = [1 0;0 1];
D = [NaN NaN;NaN NaN];

Mean0 = zeros(1,2);
Cov0 = cov(y');
lb = [-Inf;-Inf;-Inf;-Inf;
    0;-Inf;-Inf;0;
    0;-Inf;-Inf;0];

StateType = zeros(2,1);

Aeq = [0,0,0,0,0,1,-1,0,0,0,0,0;
        0,0,0,0,0,0,0,0,0,1,-1,0]; 
beq = [0;0];
    
options = optimset('fmincon');
options = optimset(options,'MaxFunEvals',1e+6);
options = optimset(options,'MaxIter',1e+6);
options = optimset(options,'TolFun',1e-6);
options = optimset(options,'TolX',1e-6);

Mdl    = ssm(A,B,C,D,'Mean0',Mean0,'Cov0',Cov0,'StateType',StateType);
Output = refine(Mdl,y',startingvalues);
EstMdl = estimate(Mdl,y',Output(1).Parameters,...
    'lb',lb,'CovMethod','hessian','Aeq',Aeq,'beq',beq,'Options',options);
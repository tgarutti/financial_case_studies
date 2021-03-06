%% Run initial regressions for moving window

window = i:(i+w-1);

% Regression of short rate
X_it = [ones(length(Lt(window(1):window(end))),1) Lt(window(1):window(end)) ...
    St(window(1):window(end))];
Y_it = shortRate(window(1):window(end));

[coefit, ~, residualit] = lsqlin(X_it, Y_it, [], []);
coefit = coefit';
residualit = residualit';

% Regression of Lt
X_lt = [Lt(window(1):window(end-1)) inflation(window(2):window(end))];
Y_lt = Lt(window(2):window(end));

[coefLt, ~, residualLt] = lsqlin(X_lt, Y_lt, [], [], ones(1,size(X_lt,2)), 1);
coefLt = coefLt';
residualLt = residualLt';

% Regression of St
X_st = [St(window(1):window(end-1)) outputGap(window(2):window(end))...
    (inflation(window(2):window(end))-Lt(window(2):window(end)))];
Y_st = St(window(2):window(end));

[coefSt, ~, residualSt] = lsqlin(X_st, Y_st, [], []);
coefSt = [coefSt(1) 1-coefSt(1) coefSt(2)/(1-coefSt(1)) coefSt(3)/(1-coefSt(1))];
residualSt = residualSt';

% Regression of St regression error ut
X_res = residualSt(1:(end-1))';
Y_res = residualSt(2:end)';

[coefres, ~, residualres] = lsqlin(X_res, Y_res, [], []);
coefres = coefres';
residualres = residualres';

% Regression of inflation
X_pi = [Lt(window(3):window(end)) inflation(window(2):window(end-1))...
     inflation(window(1):window(end-2)) outputGap(window(2):window(end-1))];
Y_pi = inflation(window(3):window(end));

[coefpi, ~, residualpi] = lsqlin(X_pi, Y_pi, [], []);
coefpi = [coefpi(1) 1-coefpi(1) coefpi(2)/(1-coefpi(1))...
    coefpi(3)/(1-coefpi(1)) coefpi(4)];
residualpi = residualpi';

% Regression of output gap
Eyt = outputGap + normrnd(0,1,size(outputGap));
X_y = [Eyt(window(4):window(end)) outputGap(window(2):window(end-2)) ...
    outputGap(window(1):window(end-3)) -St(window(2):window(end-2))];
Y_y = outputGap(window(3):window(end-1));

[coefy, ~, residualy] = lsqlin(X_y, Y_y, [], []);
coefy = [coefy(1) 1-coefy(1) coefy(2)/(1-coefy(1))...
    coefy(3)/(1-coefy(1)) coefy(4)];
residualy = residualy';

% Coefficient matrix
coefficients_shortRate = [coefficients_shortRate; coefit];
coefficients_Lt = [coefficients_Lt; coefLt];
coefficients_St = [coefficients_St; coefSt];
coefficients_residuals = [coefficients_residuals; coefres];
coefficients_inflation = [coefficients_inflation; coefpi];
coefficients_outputGap = [coefficients_outputGap; coefy];

% Residual matrix
res_it = [res_it; residualit];
res_Lt = [res_Lt; residualLt];
res_St = [res_St; residualSt];
res_res = [res_res; residualres];
res_pi = [res_pi; residualpi];
res_y = [res_y; residualy]; 

%% Run sims algorithm
runSims
rho(:,:,i) = gammaSims(1:7, 1:7);
sigma(:,:,i) = omegaSims(1:7,:);

F(:,:,i) = [inflation(window(2):window(end))';...
    inflation(window(1):window(end-1))';...
    outputGap(window(2):window(end))';...
    outputGap(window(1):window(end-1))'; Lt(window(2):window(end))';...
    St(window(2):window(end))'; residualSt];
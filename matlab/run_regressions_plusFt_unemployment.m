%% Run initial regressions for moving window

window = i:(i+w-1);

% Regression of short rate
X_it = [ones(length(Lt(window(1):window(end))),1) Lt(window(1):window(end))...
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
     inflation(window(1):window(end-2)) outputGap(window(2):window(end-1))...
     PCOrtec(window(3):window(end),:) unemployment(window(2):window(end-1))];
Y_pi = inflation(window(3):window(end));

[coefpi, ~, residualpi] = lsqlin(X_pi, Y_pi, [], []);
coefpi = [coefpi(1) 1-coefpi(1) coefpi(2)/(1-coefpi(1))...
    coefpi(3)/(1-coefpi(1)) coefpi(4) coefpi(5) coefpi(6)...
    coefpi(7) coefpi(8) coefpi(9) coefpi(10) coefpi(11) coefpi(12)...
    coefpi(13) coefpi(14) coefpi(15)];
residualpi = residualpi';

% Regression of output gap
Eyt = outputGap + normrnd(0,1,size(outputGap));
X_y = [Eyt(window(4):window(end)) outputGap(window(2):window(end-2)) ...
    outputGap(window(1):window(end-3)) -St(window(2):window(end-2))...
    PCOrtec(window(3):window(end-1),:) ...
    -(unemployment(window(2):window(end-2))-nairu(window(2):window(end-2)))];
Y_y = outputGap(window(3):window(end-1));

[coefy, ~, residualy] = lsqlin(X_y, Y_y, [], []);
coefy = [coefy(1) 1-coefy(1) coefy(2)/(1-coefy(1))...
    coefy(3)/(1-coefy(1)) coefy(4) coefy(5) coefy(6) coefy(7) coefy(8)...
    coefy(9) coefy(10) coefy(11) coefy(12) coefy(13) coefy(14) coefy(15)];
residualy = residualy';

% Regression of unemployment
Enut = unemployment + normrnd(0,1,size(unemployment));
X_nu = [Enut(window(4):window(end)) unemployment(window(2):window(end-2))...
    unemployment(window(1):window(end-3))];
Y_nu = unemployment(window(3):window(end-1));

[coefnu, ~, residualnu] = lsqlin(X_nu, Y_nu, [], []);
coefnu = [coefnu(1) 1-coefnu(1) coefnu(2)/(1-coefnu(1)) coefnu(3)/(1-coefnu(1))];
residualnu = residualnu';

% Regression of NAIRU
Enustart = nairu + normrnd(0,1,size(nairu));
X_nustar = [Enustart(window(4):window(end)) nairu(window(2):window(end-2))...
    nairu(window(1):window(end-3))];
Y_nustar = nairu(window(3):window(end-1));

[coefnustar, ~, residualnustar] = lsqlin(X_nustar, Y_nustar, [], []);
coefnustar = [coefnustar(1) 1-coefnustar(1) coefnustar(2)/(1-coefnustar(1))...
    coefnustar(3)/(1-coefnustar(1))];
residualnustar = residualnustar';

% Coefficient matrix
coefficients_shortRate = [coefficients_shortRate; coefit];
coefficients_Lt = [coefficients_Lt; coefLt];
coefficients_St = [coefficients_St; coefSt];
coefficients_residuals = [coefficients_residuals; coefres];
coefficients_inflation = [coefficients_inflation; coefpi];
coefficients_outputGap = [coefficients_outputGap; coefy];
coefficients_unemployment = [coefficients_unemployment; coefnu];
coefficients_nairu = [coefficients_nairu; coefnustar];

% Residual matrix
res_it   = [res_it; residualit];
res_Lt   = [res_Lt; residualLt];
res_St   = [res_St; residualSt];
res_res  = [res_res; residualres];
res_pi   = [res_pi; residualpi];
res_y    = [res_y; residualy]; 
res_nu   = [res_nu; residualnu];
res_nustar = [res_nustar; residualnustar];

%% Run sims algorithm
runSims_unemployment
rho(:,:,i) = gammaSims(1:10,1:10);
sigma(:,:,i) = omegaSims(1:10,:);

F(:,:,i) = [inflation(window(2):window(end))';...
    inflation(window(1):window(end-1))';...
    outputGap(window(2):window(end))';...
    outputGap(window(1):window(end-1))'; Lt(window(2):window(end))';...
    St(window(2):window(end))'; residualSt];
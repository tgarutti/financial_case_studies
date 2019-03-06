function [] = runRegressions(window, shortRate, inflation,...
    outputGap, Lt, St, PCOrtec, unemployment, nairu, restPC, restUnemp)
%RUNREGRESSIONS Runs regressions 
PCS = restPC.*(PCOrtec');
PCS( ~any(PCS,2), : ) = [];
PCS = PCS';

%% Regression of short rate
X_it = [ones(length(Lt(window(1):window(end))),1) Lt(window(1):window(end))...
    St(window(1):window(end))];
Y_it = shortRate(window(1):window(end));

[coefit, ~, residualit] = lsqlin(X_it, Y_it, [], []);
coefit = coefit';
residualit = residualit';

%% Regression of Lt
X_lt = [Lt(window(1):window(end-1)) inflation(window(2):window(end))];
Y_lt = Lt(window(2):window(end));

[coefLt, ~, residualLt] = lsqlin(X_lt, Y_lt, [], [], ones(1,size(X_lt,2)), 1);
coefLt = coefLt';
residualLt = residualLt';

%% Regression of St
X_st = [St(window(1):window(end-1)) outputGap(window(2):window(end))...
    (inflation(window(2):window(end))-Lt(window(2):window(end)))];
Y_st = St(window(2):window(end));

[coefSt, ~, residualSt] = lsqlin(X_st, Y_st, [], []);
coefSt = [coefSt(1) 1-coefSt(1) coefSt(2)/(1-coefSt(1)) coefSt(3)/(1-coefSt(1))];
residualSt = residualSt';

%% Regression of inflation
X_pi = [Lt(window(3):window(end)) inflation(window(2):window(end-1))...
     inflation(window(1):window(end-2)) outputGap(window(2):window(end-1))...
     PCS(window(3):window(end),:)];
Y_pi = inflation(window(3):window(end));

[coefpi, ~, residualpi] = lsqlin(X_pi, Y_pi, [], []);
coefpi = [coefpi(1) coefpi'];
coefpi(2) = 1-coefpi(1);
coefpi(3) = coefpi(3)/(1-coefpi(1));
coefpi(4) = coefpi(4)/(1-coefpi(1));
residualpi = residualpi';

end


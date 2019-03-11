function [coefit, coefLt, coefSt, coefpi, coefy, coefnu, coefnustar] = ...
    runRegressions(window, shortRate, inflation, outputGap, Lt, St,...
    PCOrtec, unemployment, nairu, restPC, restUnemp, restNairu)
%RUNREGRESSIONS Runs regressions with input vectors restPC, restUnemp and
%restNairu, which are restrictions on which variables to include in the 
%regressions.

%% Set up restrictions
PCS = restPC.*(PCOrtec');
PCS( ~any(PCS,2), : ) = [];
PCS = PCS';

unemp = restUnemp.*unemployment;
unemp( :, ~any(unemp,1) ) = [];

Nairu = restNairu.*nairu;
Nairu( :, ~any(Nairu,1) ) = [];

if restUnemp == 0 && restNairu == 0
    diff = -(unemp - Nairu);
elseif restUnemp == 0
    diff = nairu;
elseif restNairu == 0
    diff = unemployment;
else
    diff = -(unemployment - nairu);
end

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

%% Regression of output gap
Eyt = outputGap + normrnd(0,1,size(outputGap));
X_y = [Eyt(window(4):window(end)) outputGap(window(2):window(end-2)) ...
    outputGap(window(1):window(end-3)) -St(window(2):window(end-2))...
    PCS(window(3):window(end-1),:) ...
    diff(window(2):window(end-2),:)];
Y_y = outputGap(window(3):window(end-1));

[coefy, ~, residualy] = lsqlin(X_y, Y_y, [], []);
coefy = [coefy(1) coefy'];
coefy(2) = 1-coefy(1);
coefy(3) = coefy(3)/(1-coefy(1));
coefy(4) = coefy(4)/(1-coefy(1));
residualy = residualy';

%% Regression of unemployment
Enut = unemployment + normrnd(0,1,size(unemployment));
X_nu = [Enut(window(4):window(end)) unemployment(window(2):window(end-2))...
    unemployment(window(1):window(end-3))];
Y_nu = unemployment(window(3):window(end-1));

[coefnu, ~, residualnu] = lsqlin(X_nu, Y_nu, [], []);
coefnu = [coefnu(1) 1-coefnu(1) coefnu(2)/(1-coefnu(1)) coefnu(3)/(1-coefnu(1))];
residualnu = residualnu';

%% Regression of NAIRU
Enustart = nairu + normrnd(0,1,size(nairu));
X_nustar = [Enustart(window(4):window(end)) nairu(window(2):window(end-2))...
    nairu(window(1):window(end-3))];
Y_nustar = nairu(window(3):window(end-1));

[coefnustar, ~, residualnustar] = lsqlin(X_nustar, Y_nustar, [], []);
coefnustar = [coefnustar(1) 1-coefnustar(1) coefnustar(2)/(1-coefnustar(1))...
    coefnustar(3)/(1-coefnustar(1))];
residualnustar = residualnustar';

end


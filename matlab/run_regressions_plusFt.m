%% Run initial regressions for moving window

window = i:(i+w-1);

% Regression of short rate
X_it = [Lt(window(1):window(end)) St(window(1):window(end))];
Y_it = 100*shortRate(window(1):window(end));

[coefit, ~, residualit] = lsqlin(X_it, Y_it, [], []);
coefit = coefit';
residualit = residualit';

% Regression of Lt
X_lt = [Lt(window(1):window(end-1)) 100*inflation(window(2):window(end))];
Y_lt = Lt(window(2):window(end));

[coefLt, ~, residualLt] = lsqlin(X_lt, Y_lt, [], [], ones(1,size(X_lt,2)), 1);
coefLt = coefLt';
residualLt = residualLt';

% Regression of St
X_st = [St(window(1):window(end-1)) 100*outputGap(window(2):window(end))...
    (100*inflation(window(2):window(end))-Lt(window(2):window(end)))];
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
X_pi = [Lt(window(3):window(end)) 100*inflation(window(2):window(end-1))...
     100*inflation(window(1):window(end-2)) 100*outputGap(window(2):window(end-1))...
     PCOrtec(window(3):window(end),1) PCOrtec(window(3):window(end),2)...
     PCOrtec(window(3):window(end),3) PCOrtec(window(3):window(end),4)...
     PCOrtec(window(3):window(end),5) PCOrtec(window(3):window(end),6)...
     PCOrtec(window(3):window(end),7) PCOrtec(window(3):window(end),8)...
     PCOrtec(window(3):window(end),9) PCOrtec(window(3):window(end),10)];
Y_pi = 100*inflation(window(3):window(end));

[coefpi, ~, residualpi] = lsqlin(X_pi, Y_pi, [], []);
coefpi = [coefpi(1) 1-coefpi(1) coefpi(2)/(1-coefpi(1))...
    coefpi(3)/(1-coefpi(1)) coefpi(4) coefpi(5) coefpi(6)...
    coefpi(7) coefpi(8) coefpi(9) coefpi(10) coefpi(11) coefpi(12)...
    coefpi(13) coefpi(14)];
residualpi = residualpi';

% Regression of output gap
Eyt = 100*outputGap + normrnd(0,1,size(outputGap));
X_y = [Eyt(window(4):window(end)) 100*outputGap(window(2):window(end-2)) ...
    100*outputGap(window(1):window(end-3)) -St(window(2):window(end-2))...
    PCOrtec(window(3):window(end-1),1) PCOrtec(window(3):window(end-1),2)...
    PCOrtec(window(3):window(end-1),3) PCOrtec(window(3):window(end-1),4)...
    PCOrtec(window(3):window(end-1),5) PCOrtec(window(3):window(end-1),6)...
    PCOrtec(window(3):window(end-1),7) PCOrtec(window(3):window(end-1),8)...
    PCOrtec(window(3):window(end-1),9) PCOrtec(window(3):window(end-1),10)];
Y_y = 100*outputGap(window(3):window(end-1));

[coefy, ~, residualy] = lsqlin(X_y, Y_y, [], []);
coefy = [coefy(1) 1-coefy(1) coefy(2)/(1-coefy(1))...
    coefy(3)/(1-coefy(1)) coefy(4) coefy(5) coefy(6) coefy(7) coefy(8)...
    coefy(9) coefy(10) coefy(11) coefy(12) coefy(13) coefy(14)];
residualy = residualy';


% Regressions of Ft
%1
X_ft1 = PCOrtec(1:(end-1),1);
Y_ft1 = PCOrtec(2:end,1);

[coefFt1, ~, residualFt1] = lsqlin(X_ft1, Y_ft1, [], []);
coefFt1     = coefFt1';
residualFt1 = residualFt1';
%2
X_ft2 = PCOrtec(1:(end-1),2);
Y_ft2 = PCOrtec(2:end,2);

[coefFt2, ~, residualFt2] = lsqlin(X_ft2, Y_ft2, [], []);
coefFt2     = coefFt2';
residualFt2 = residualFt2';
%3
X_ft3 = PCOrtec(1:(end-1),3);
Y_ft3 = PCOrtec(2:end,3);

[coefFt3, ~, residualFt3] = lsqlin(X_ft3, Y_ft3, [], []);
coefFt3     = coefFt3';
residualFt3 = residualFt3';
%4
X_ft4 = PCOrtec(1:(end-1),4);
Y_ft4 = PCOrtec(2:end,4);

[coefFt4, ~, residualFt4] = lsqlin(X_ft4, Y_ft4, [], []);
coefFt4     = coefFt4';
residualFt4 = residualFt4';
%5
X_ft5 = PCOrtec(1:(end-1),5);
Y_ft5 = PCOrtec(2:end,5);

[coefFt5, ~, residualFt5] = lsqlin(X_ft5, Y_ft5, [], []);
coefFt5     = coefFt5';
residualFt5 = residualFt5';
%6
X_ft6 = PCOrtec(1:(end-1),6);
Y_ft6 = PCOrtec(2:end,6);

[coefFt6, ~, residualFt6] = lsqlin(X_ft6, Y_ft6, [], []);
coefFt6     = coefFt6';
residualFt6 = residualFt6';
%7
X_ft7 = PCOrtec(1:(end-1),7);
Y_ft7 = PCOrtec(2:end,7);

[coefFt7, ~, residualFt7] = lsqlin(X_ft7, Y_ft7, [], []);
coefFt7     = coefFt7';
residualFt7 = residualFt7';
%8
X_ft8 = PCOrtec(1:(end-1),8);
Y_ft8 = PCOrtec(2:end,8);

[coefFt8, ~, residualFt8] = lsqlin(X_ft8, Y_ft8, [], []);
coefFt8     = coefFt8';
residualFt8 = residualFt8';
%9
X_ft9 = PCOrtec(1:(end-1),9);
Y_ft9 = PCOrtec(2:end,9);

[coefFt9, ~, residualFt9] = lsqlin(X_ft9, Y_ft9, [], []);
coefFt9     = coefFt9';
residualFt9 = residualFt9';
%10
X_ft10 = PCOrtec(1:(end-1),10);
Y_ft10 = PCOrtec(2:end,10);

[coefFt10, ~, residualFt10] = lsqlin(X_ft10, Y_ft10, [], []);
coefFt10     = coefFt10';
residualFt10 = residualFt10';

% Coefficient matrix
coefficients_shortRate = [coefficients_shortRate; coefit];
coefficients_Lt = [coefficients_Lt; coefLt];
coefficients_St = [coefficients_St; coefSt];
coefficients_residuals = [coefficients_residuals; coefres];
coefficients_inflation = [coefficients_inflation; coefpi];
coefficients_outputGap = [coefficients_outputGap; coefy];
coefficients_Ft1  = [coefficients_Ft1; coefFt1];
coefficients_Ft2  = [coefficients_Ft2; coefFt2];
coefficients_Ft3  = [coefficients_Ft3; coefFt3];
coefficients_Ft4  = [coefficients_Ft4; coefFt4];
coefficients_Ft5  = [coefficients_Ft5; coefFt5];
coefficients_Ft6  = [coefficients_Ft6; coefFt6];
coefficients_Ft7  = [coefficients_Ft7; coefFt7];
coefficients_Ft8  = [coefficients_Ft8; coefFt8];
coefficients_Ft9  = [coefficients_Ft9; coefFt9];
coefficients_Ft10 = [coefficients_Ft10; coefFt10];


% Residual matrix
res_it   = [res_it; residualit];
res_Lt   = [res_Lt; residualLt];
res_St   = [res_St; residualSt];
res_res  = [res_res; residualres];
res_pi   = [res_pi; residualpi];
res_y    = [res_y; residualy]; 
res_Ft1  = [res_Ft1; residualFt1];
res_Ft2  = [res_Ft2; residualFt2];
res_Ft3  = [res_Ft3; residualFt3];
res_Ft4  = [res_Ft4; residualFt4];
res_Ft5  = [res_Ft5; residualFt5];
res_Ft6  = [res_Ft6; residualFt6];
res_Ft7  = [res_Ft7; residualFt7];
res_Ft8  = [res_Ft8; residualFt8];
res_Ft9  = [res_Ft9; residualFt9];
res_Ft10 = [res_Ft10; residualFt10];

%% Run sims algorithm
runSims_plusFt
rho(:,:,i) = gammaSims(:,:);
sigma(:,:,i) = omegaSims(:,:);

F(:,:,i) = [100*inflation(window(2):window(end))';...
    100*inflation(window(1):window(end-1))';...
    100*outputGap(window(2):window(end))';...
    100*outputGap(window(1):window(end-1))'; Lt(window(2):window(end))';...
    St(window(2):window(end))'; residualSt];
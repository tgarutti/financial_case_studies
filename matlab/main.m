%% Load data
load_data

%% Normalize the principle components of the yield curve data
normPCs = normalize(PCs);

%% Define regression window and variables
w = 40; % widnow length of 10 years
n = length(inflation);
Lt = normPCs(:,1);
St = normPCs(:,2);

%% Plot inflation against the first principal component
de_inflation = inflation - mean(inflation);
figure
plot(1:n, Lt, 1:n, 100*de_inflation)
xTickLabels = cell(1, numel(dates));
xTickLabels(1:20:numel(dates)) = dates(1:20:numel(dates));
set(gca, 'xtick', [1:132], 'xticklabel', xTickLabels);


%% Moving window regressions -> coefficient matrix

for i = 1:(n-w+1)
    window = i:(i+w-1);

    % Regression of short rate
    X_it = [Lt(window(1):window(end)) St(window(1):window(end))];
    Y_it = 100*shortRate(window(1):window(end));
    
    [coefit, ~, residualit] = lsqlin(X_it, Y_it, [], []);
    
    % Regression of Lt
    X_lt = [Lt(window(1):window(end-1)) 100*inflation(window(1):window(end-1))];
    Y_lt = Lt(window(2):window(end));
    
    [coefLt, ~, residualLt] = lsqlin(X_lt, Y_lt, [], [], ones(1,size(X_lt,2)), 1);
    
    % Regression of St
    X_st = [St(window(1):window(end-1)) 100*outputGap(window(2):window(end))...
        (100*inflation(window(2):window(end))-Lt(window(2):window(end)))];
    Y_st = St(window(2):window(end));
    
    [coefSt, ~, residualSt] = lsqlin(X_st, Y_st, [], []);
    coefSt = [coefSt(1), 1-coefSt(1), coefSt(2)/(1-coefSt(1)), coefSt(3)/(1-coefSt(1))];
    
    % Regression of St regression error ut
    X_res = residualSt(1:(end-1));
    Y_res = residualSt(2:end);
    
    [coefres, ~, residualres] = lsqlin(X_res, Y_res, [], []);
    
    % Regression of inflation
    X_pi = [Lt(window(3):window(end)) 100*inflation(window(2):window(end-1))...
         100*inflation(window(1):window(end-2)) 100*outputGap(window(2):window(end-1))];
    Y_pi = 100*inflation(window(3):window(end));
    
    [coefpi, ~, residualpi] = lsqlin(X_pi, Y_pi, [], []);
    coefpi = [coefpi(1), 1-coefpi(1), coefpi(2)/(1-coefpi(1)),...
        coefpi(3)/(1-coefpi(1)), coefpi(4)];
    
    % Regression of output gap
    Eyt = 100*outputGap + normrnd(0,1,size(outputGap));
    X_y = [Eyt(window(4):window(end)) 100*outputGap(window(2):window(end-2)) ...
        100*outputGap(window(1):window(end-3)) -St(window(2):window(end-2))];
    Y_y = 100*outputGap(window(3):window(end-1));
    
    [coefy, ~, residualy] = lsqlin(X_y, Y_y, [], []);
    coefy = [coefy(1), 1-coefy(1), coefy(2)/(1-coefy(1)),...
        coefy(3)/(1-coefy(1)), coefy(4)];    
end
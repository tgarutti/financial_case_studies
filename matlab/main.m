%% Load data
load_data

%% Normalize the principle components of the yield curve data
normPCs = normalize(PCs);

%% Define regression window and variables
w = 40; % widnow length of 10 years
n = length(inflation);
Lt = -normPCs(:,1);
St = normPCs(:,2);

%% Plot inflation against the first principal component
de_inflation = inflation - mean(inflation);
figure
plot(1:n, Lt, 1:n, 100*de_inflation)
xTickLabels = cell(1, numel(dates));
xTickLabels(1:20:numel(dates)) = dates(1:20:numel(dates));
set(gca, 'xtick', [1:132], 'xticklabel', xTickLabels);


%% Moving window regressions
for i = 1:(n-w+1)
    window = i:(i+w-1);
    X_lt = [Lt(window(1):window(end-1)) 100*inflation(window(1):window(end-1))];
end
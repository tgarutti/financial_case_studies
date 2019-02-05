%% Plot inflation against the first principal component
de_inflation = inflation - mean(inflation);
figure
plot(1:n, Lt, 1:n, 100*de_inflation)
xTickLabels = cell(1, numel(dates));
xTickLabels(1:20:numel(dates)) = dates(1:20:numel(dates));
set(gca, 'xtick', [1:132], 'xticklabel', xTickLabels);
clear xTickLabels
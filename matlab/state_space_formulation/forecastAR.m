%% Forecast an AR(1) model for each of the three macro variables
m = varm(3,1);
m = varm('AR',{diag([NaN,NaN,NaN])});

mdl = estimate(m,x');

intermediate = forecast(mdl,forecastHorizon,x');
forecastsAR(i,:,:) = intermediate';
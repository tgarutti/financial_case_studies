function [fX] = forecastX(xi_T,x_T,Pi,Q,H1,H2,c,currentT,step,actualVals)
% Function that forecasts the observed state

% Checks ensure either known data or forecasted data is used
if step==1
    fX = c+Q*(Pi^step)*xi_T+H1*actualVals(2:end,currentT)+H2*actualVals(2:end,currentT-1);
elseif step==2
    fX = c+Q*(Pi^step)*xi_T+H1*x_T(2:end,step-1)+H2*actualVals(2:end,currentT);
else
    fX = c+Q*(Pi^step)*xi_T+H1*x_T(2:end,step-1)+H2*x_T(2:end,step-2);
end

end
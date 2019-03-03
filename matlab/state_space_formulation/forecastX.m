function [fX] = forecastX(xi_T,x_T,Q,H1,H2,H3,H4,H5,forecastedFt,uU,uN,c,currentT,step,actualVals)
% Function that forecasts the observed state

% Checks ensure either known data or forecasted data is used
if step==1
    fX = c+Q*xi_T+H1*actualVals(2:end,currentT)+H2*actualVals(2:end,currentT-1)+H3*forecastedFt(:,step)+H4*uU(step)+H5*uN(step);
elseif step==2
    fX = c+Q*xi_T+H1*x_T(2:end,step-1)+H2*actualVals(2:end,currentT)+H3*forecastedFt(:,step)+H4*uU(step)+H5*uN(step);
else
    fX = c+Q*xi_T+H1*x_T(2:end,step-1)+H2*x_T(2:end,step-2)+H3*forecastedFt(:,step)+H4*uU(step)+H5*uN(step);
end

end
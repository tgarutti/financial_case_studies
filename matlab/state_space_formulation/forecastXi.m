function [fXi] = forecastXi(xi_T,x_T,Pi,Theta1,Theta2,currentT,step,actualVals)
% Function that forecasts the unobserved state

% Extra checks ensure either known data or forecasted data is used
if step==1
    fXi = Pi*xi_T+Theta1*actualVals(2:end,currentT)+Theta2*actualVals(2:end,currentT-1);
elseif step==2
    fXi = Pi*xi_T+Theta1*x_T(2:end,step-1)+Theta2*actualVals(2:end,currentT);
else
    fXi = Pi*xi_T+Theta1*x_T(2:end,step-1)+Theta2*x_T(2:end,step-2);
end

end
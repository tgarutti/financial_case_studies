function [fXi] = forecastXi(xi_T,x_T,parameter_vector,currentT,step,actualVals)
% Function that forecasts the unobserved state

% Extract length of the data, and the dimensionality of the problem
d = 2; % 2 states, xi_t = [L_t S_t]'

% Unpack the ML parameters
Pi = zeros(d,d);
Theta1 = zeros(d,d);
Theta2 = zeros(d,d);

Pi(1,1) = parameter_vector(1);
Pi(1,2) = parameter_vector(2);
Pi(2,1) = parameter_vector(3);
Pi(2,2) = parameter_vector(4);

Theta1(1,1) = parameter_vector(18);
Theta1(1,2) = parameter_vector(19);
Theta1(2,1) = parameter_vector(20);
Theta1(2,2) = parameter_vector(21);

Theta2(1,1) = parameter_vector(22);
Theta2(1,2) = parameter_vector(23);
Theta2(2,1) = parameter_vector(24);
Theta2(2,2) = parameter_vector(25);

% Extra checks ensure either known data or forecasted data is used
if step==1
    fXi = Pi*xi_T+Theta1*actualVals(2:end,currentT)+Theta2*actualVals(2:end,currentT-1);
elseif step==2
    fXi = Pi*xi_T+Theta1*x_T(2:end,step-1)+Theta2*actualVals(2:end,currentT);
else
    fXi = Pi*xi_T+Theta1*x_T(2:end,step-1)+Theta2*x_T(2:end,step-2);
end

end
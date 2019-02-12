function [fX] = forecastX(xi_T,x_T,parameter_vector,currentT,step,actualVals)
% Function that forecasts the observed state

% Extract length of the data, and the dimensionality of the problem
l = 3; % 3 observations, x_t = [i_t pi_t y_t]'
d = 2; % 2 states, xi_t = [L_t S_t]'

% Extract the stuff we need from the input arguments
Q  = zeros(l,d);
H1 = zeros(l,d);
H2 = zeros(l,d);

Q(1,1) = parameter_vector(9);
Q(1,2) = parameter_vector(10);
Q(2,1) = parameter_vector(11);
Q(3,2) = parameter_vector(12);

H1(2,1) = parameter_vector(18);
H1(2,2) = parameter_vector(19);
H1(3,2) = parameter_vector(20);

H2(2,1) = parameter_vector(21);
H2(3,2) = parameter_vector(22);

% Extra checks ensure either known data or forecasted data is used
if step==1
    fX = Q*xi_T+H1*actualVals(2:end,currentT)+H2*actualVals(2:end,currentT-1);
elseif step==2
    fX = Q*xi_T+H1*x_T(2:end,step-1)+H2*actualVals(2:end,currentT);
else
    fX = Q*xi_T+H1*x_T(2:end,step-1)+H2*x_T(2:end,step-2);
end

end
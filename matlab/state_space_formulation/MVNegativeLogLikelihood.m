function [output]=MVNegativeLogLikelihood(parameter_vector,y)

% Extract length of the data, and the dimensionality of the problem
T = size(y,2);
d = size(y,1);

% Extract the stuff we need from the input arguments
F = zeros(d,d);
Q = zeros(d,d);
R = zeros(d,d);

F(1,1) = parameter_vector(1,1);
F(1,2) = parameter_vector(2,1);
F(2,1) = parameter_vector(3,1);
F(2,2) = parameter_vector(4,1);
Q(1,1) = parameter_vector(5,1);
Q(1,2) = parameter_vector(6,1);
Q(2,1) = parameter_vector(6,1);
Q(2,2) = parameter_vector(7,1);
R(1,1) = parameter_vector(8,1);
R(1,2) = parameter_vector(9,1);
R(2,1) = parameter_vector(9,1);
R(2,2) = parameter_vector(10,1);

% Run the Kalman filter
[~,~,predictedxi,predictedP] = MVKalmanFilter(parameter_vector,y);

% Initialize arrays
mu     = zeros(d,T);
Sigma  = zeros(d,d,T);
LL     = zeros(1,T);

% Collect a row vector of log likelihood per observation
for t=1:T
    Sigma(:,:,t) = predictedP(:,:,t)+R;
    mu(:,t)      = predictedxi(:,t);
    LL(t)        = log(1/sqrt(det(2*pi*Sigma(:,:,t)))*...
                exp(-1/2*(y(:,t)-mu(:,t))'*(Sigma(:,:,t)\(y(:,t)-mu(:,t)))));
end

% Sum over all observations
output = -sum(LL(1:end));               

end

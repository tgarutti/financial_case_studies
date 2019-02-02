function [output] = MVNegativeLogLikelihood(parameter_vector,y)

% Extract length of the data, and the dimensionality of the problem
T = size(y,1);
d = size(y,2);

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
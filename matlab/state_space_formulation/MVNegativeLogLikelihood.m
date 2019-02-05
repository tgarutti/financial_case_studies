function [output] = MVNegativeLogLikelihood(parameter_vector,y)

% Set global variable for filtered states
global xi

% Extract length of the data, and the dimensionality of the problem
T = size(y,1);
d = size(y,2);

% Extract what is needed from parameter_vector
H     = zeros(3,1);
H(1)  = parameter_vector(19);
H(2)  = parameter_vector(20);
sigma = parameter_vector(21);

% Run the Kalman filter
[xi,~,predictedxi,predictedP] = MVKalmanFilter(parameter_vector,y);

% Initialize arrays
mu     = zeros(d,T);
Sigma  = zeros(d,d,T);
LL     = zeros(1,T);

% Collect a row vector of log likelihood per observation
for t=3:T
    Sigma(:,:,t) = H'*predictedP(:,:,t)*H+sigma;
    mu(:,t)      = H'*predictedxi(:,t);
    LL(t)        = log(1/sqrt(det(2*pi*Sigma(:,:,t)))*...
                exp(-1/2*(y(t)-mu(:,t))'*(Sigma(:,:,t)\(y(t)-mu(:,t)))));
end

% Sum over all observations
output = -sum(LL(3:end));               

end

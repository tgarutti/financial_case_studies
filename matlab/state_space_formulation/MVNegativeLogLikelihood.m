function [output] = MVNegativeLogLikelihood(parameter_vector,y)

% Call global variables
global predictedxi H1 H2 z

% Extract length of the data, and the dimensionality of the problem
T = size(y,1);
d = 2; % 2 states, xi_t = [L_t S_t]'
l = 3; % 3 observations, x_t = [i_t pi_t y_t]'

% Extract what is needed from parameter_vector
S  = zeros(l,l);
Q  = zeros(l,d);

Q(1,1) = parameter_vector(7);
Q(1,2) = parameter_vector(8);
Q(2,1) = parameter_vector(9);
Q(2,2) = parameter_vector(10);
Q(3,1) = parameter_vector(11);
Q(3,2) = parameter_vector(12);

S(1,1) = parameter_vector(13);
S(2,2) = parameter_vector(14);
S(3,3) = parameter_vector(15);

% Run the Kalman filter
[~,~,predictedxi,predictedP] = MVKalmanFilter(parameter_vector,y);

% Initialize arrays
mu     = zeros(d,T);
Sigma  = zeros(d,d,T);
LL     = zeros(1,T);

% Collect a row vector of log likelihood per observation
for t=3:T
    Sigma(:,:,t) = Q*predictedP(:,:,t)*Q'+S;
    mu(:,t)      = Q*predictedxi(:,t)-H1*z(:,t-1)-H2*z(:,t-2);
    LL(t)        = log(1/sqrt(det(2*pi*Sigma(:,:,t)))*...
                exp(-1/2*(y(:,t)-mu(:,t))'*(Sigma(:,:,t)\(y(:,t)-mu(:,t)))));
end

% Sum over all observations
output = -sum(LL(3:end));               

end

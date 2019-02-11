function [output] = MVNegativeLogLikelihood(parameter_vector,y)

% Call global variables
global H1 H2 predictedxi z

% Extract length of the data, and the dimensionality of the problem
T = size(y,2);
l = size(y,1); % 3 observations, x_t = [i_t pi_t y_t]'
d = 2; % 2 states, xi_t = [L_t S_t]'

% Run the Kalman filter
[~,~,predictedxi,predictedP] = MVKalmanFilter(parameter_vector,y);

% Extract what is needed from parameter_vector
S  = zeros(l,l);
Q  = zeros(l,d);

Q(1,1) = parameter_vector(9);
Q(1,2) = parameter_vector(10);
Q(2,1) = parameter_vector(11);
Q(2,2) = parameter_vector(12);
Q(3,1) = parameter_vector(13);
Q(3,2) = parameter_vector(14);

S(1,1) = parameter_vector(15);
S(2,2) = parameter_vector(16);
S(2,3) = parameter_vector(17);
S(3,2) = parameter_vector(18);
S(3,3) = parameter_vector(19);

% Initialize arrays
mu     = zeros(l,T);
covar  = zeros(l,l,T);
LL     = zeros(1,T);

% Collect a row vector of log likelihood per observation
for t=4:T
    covar(:,:,t) = Q*(predictedP(:,:,t)*Q')+S;
    mu(:,t)      = Q*predictedxi(:,t)+H1*z(:,t-1)+H2*z(:,t-2);
    LL(t)        = log(1/sqrt(det(2*pi*covar(:,:,t)))*...
                exp(-1/2*(y(:,t)-mu(:,t))'*(covar(:,:,t)\(y(:,t)-mu(:,t)))));
end

% Sum over all observations
output = -sum(LL(4:end));               

end

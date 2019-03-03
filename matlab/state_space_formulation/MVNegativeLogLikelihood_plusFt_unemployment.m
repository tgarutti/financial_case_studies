function [output] = MVNegativeLogLikelihood_plusFt_unemployment(parameter_vector,y)

% Call global variables
global xi z Ft unemp nair_u

% Extract length of the data, and the dimensionality of the problem
T = size(y,2);
l = size(y,1); % 3 observations, x_t = [i_t pi_t y_t]'
d = 2; % 2 states, xi_t = [L_t S_t]'

% Run the Kalman filter
[xi,~,predictedxi,predictedP] = MVKalmanFilter_plusFt_unemployment(parameter_vector,y);

% Extract what is needed from parameter_vector
S  = zeros(l,l);
Q  = zeros(l,d);
H1 = zeros(l,d);
H2 = zeros(l,d);
H3 = zeros(l,10);
H4 = zeros(l,1);
H5 = zeros(l,1);
c = zeros(l,1);

Q(1,1) = parameter_vector(9);
Q(1,2) = parameter_vector(10);
Q(2,1) = parameter_vector(11);
Q(3,2) = parameter_vector(12);

S(1,1) = parameter_vector(13);
S(2,2) = parameter_vector(14);
S(2,3) = parameter_vector(15);
S(3,2) = parameter_vector(16);
S(3,3) = parameter_vector(17);

H1(2,1) = parameter_vector(18);
H1(2,2) = parameter_vector(19);
H1(3,2) = parameter_vector(20);

H2(2,1) = parameter_vector(21);
H2(3,2) = parameter_vector(22);

c(1) = parameter_vector(23);
c(2) = parameter_vector(24);
c(3) = parameter_vector(25);

H3(2,1) = parameter_vector(34);
H3(2,2) = parameter_vector(35);
H3(2,3) = parameter_vector(36);
H3(2,4) = parameter_vector(37);
H3(2,5) = parameter_vector(38);
H3(2,6) = parameter_vector(39);
H3(2,7) = parameter_vector(40);
H3(2,8) = parameter_vector(41);
H3(2,9) = parameter_vector(42);
H3(2,10) = parameter_vector(43);
H3(3,1) = parameter_vector(44);
H3(3,2) = parameter_vector(45);
H3(3,3) = parameter_vector(46);
H3(3,4) = parameter_vector(47);
H3(3,5) = parameter_vector(48);
H3(3,6) = parameter_vector(49);
H3(3,7) = parameter_vector(50);
H3(3,8) = parameter_vector(51);
H3(3,9) = parameter_vector(52);
H3(3,10) = parameter_vector(53);

H4(2) = parameter_vector(54);
H4(3) = parameter_vector(55);

H5(3) = parameter_vector(56);

% Initialize arrays
mu     = zeros(l,T);
covar  = zeros(l,l,T);
LL     = zeros(1,T);

% Collect a row vector of log likelihood per observation
for t=3:T
    covar(:,:,t) = Q*(predictedP(:,:,t)*Q')+S;
    mu(:,t)      = c+Q*predictedxi(:,t)+H1*z(:,t)+H2*z(:,t-1)+H3*Ft(:,t)+...
        H4*unemp(t)+H5*nair_u(t);
    LL(t)        = log(1/sqrt(det(2*pi*covar(:,:,t)))*...
                exp(-1/2*(y(:,t)-mu(:,t))'*(covar(:,:,t)\(y(:,t)-mu(:,t)))));
end

% Sum over all observations
output = -sum(LL(3:end));               

end

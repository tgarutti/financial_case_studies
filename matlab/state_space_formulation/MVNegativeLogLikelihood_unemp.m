function [output] = MVNegativeLogLikelihood_unemp(parameter_vector,y)

% Call global variables
global predictedxi z PCOrtec_window unemp nair_u

% Extract length of the data, and the dimensionality of the problem
T = size(y,2);
l = size(y,1); % 3 observations, x_t = [i_t pi_t y_t]'
d = 2; % 2 states, xi_t = [L_t S_t]'

% Run the Kalman filter
[~,~,predictedxi,predictedP] = MVKalmanFilter_unemp(parameter_vector,y);

% Extract what is needed from parameter_vector
S  = zeros(l,l);
Q  = zeros(l,d);
H1 = zeros(l,d);
H2 = zeros(l,d);
H3 = zeros(l,10);
H4 = zeros(3,1);
H5 = zeros(3,1);

Q(1,1) = parameter_vector(9);
Q(1,2) = parameter_vector(10);
Q(2,1) = parameter_vector(11);
Q(3,2) = parameter_vector(12);

S(1,1) = parameter_vector(13);
S(2,2) = parameter_vector(14);
S(2,3) = parameter_vector(15);
S(3,2) = parameter_vector(16);
S(3,3) = parameter_vector(17);

H1(2,1) = parameter_vector(26);
H1(2,2) = parameter_vector(27);
H1(3,2) = parameter_vector(28);

H2(2,1) = parameter_vector(29);
H2(3,2) = parameter_vector(30);

H3(2,1)  = parameter_vector(31);
H3(2,2)  = parameter_vector(32);
H3(2,3)  = parameter_vector(33);
H3(2,4)  = parameter_vector(34);
H3(2,5)  = parameter_vector(35);
H3(2,6)  = parameter_vector(36);
H3(2,7)  = parameter_vector(37);
H3(2,8)  = parameter_vector(38);
H3(2,9)  = parameter_vector(39);
H3(2,10) = parameter_vector(40);

H3(3,1)  = parameter_vector(41);
H3(3,2)  = parameter_vector(42);
H3(3,3)  = parameter_vector(43);
H3(3,4)  = parameter_vector(44);
H3(3,5)  = parameter_vector(45);
H3(3,6)  = parameter_vector(46);
H3(3,7)  = parameter_vector(47);
H3(3,8)  = parameter_vector(48);
H3(3,9)  = parameter_vector(49);
H3(3,10) = parameter_vector(50);

H4(2,1)  = parameter_vector(51);
H4(3,1)  = parameter_vector(52);

H5(3,1)  = parameter_vector(53);

% Initialize arrays
mu     = zeros(l,T);
covar  = zeros(l,l,T);
LL     = zeros(1,T);

% Collect a row vector of log likelihood per observation
for t=3:T
    covar(:,:,t) = Q*(predictedP(:,:,t)*Q')+S;
    mu(:,t)      = Q*predictedxi(:,t)+H1*z(:,t-1)+H2*z(:,t-2)+...
        H3*PCOrtec_window(:,t)+H4*unemp(t)+H5*nair_u(t);
    LL(t)        = log(1/sqrt(det(2*pi*covar(:,:,t)))*...
                exp(-1/2*(y(:,t)-mu(:,t))'*(covar(:,:,t)\(y(:,t)-mu(:,t)))));
end

% Sum over all observations
output = -sum(LL(3:end));               

end

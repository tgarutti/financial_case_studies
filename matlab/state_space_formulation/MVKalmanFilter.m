function [xi,P,predictedxi,predictedP] = MVKalmanFilter(parameter_vector,y)

% Call global variables
global z

% Extract length of the data, and the dimensionality of the problem
T = size(y,2);
l = size(y,1); % 3 observations, x_t = [i_t pi_t y_t]'
d = 2; % 2 states, xi_t = [L_t S_t]'

% Extract the stuff we need from the input arguments
Pi = zeros(d,d);
R  = zeros(d,d);
S  = zeros(l,l);
Q  = zeros(l,d);
Theta1 = zeros(d,d);
Theta2 = zeros(d,d);
H1 = zeros(l,d);
H2 = zeros(l,d);
c = zeros(l,1);

Pi(1,1) = parameter_vector(1);
Pi(1,2) = parameter_vector(2);
Pi(2,1) = parameter_vector(3);
Pi(2,2) = parameter_vector(4);

R(1,1) = parameter_vector(5);
R(1,2) = parameter_vector(6);
R(2,1) = parameter_vector(7);
R(2,2) = parameter_vector(8);

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

Theta1(1,1) = parameter_vector(26);
Theta1(1,2) = parameter_vector(27);
Theta1(2,1) = parameter_vector(28);
Theta1(2,2) = parameter_vector(29);

Theta2(1,1) = parameter_vector(30);
Theta2(1,2) = parameter_vector(31);
Theta2(2,1) = parameter_vector(32);
Theta2(2,2) = parameter_vector(33);

% Diffuse initialisation
mu0    = zeros(d,1);
sigma0 = (10^6)*eye(d);

% Initialize arrays
xi          = zeros(d,T);
P           = zeros(d,d,T);
predictedxi = zeros(d,T);
predictedP  = zeros(d,d,T);
kalmanGain  = zeros(d,l,T);

% The Kalman filter for the multidimensional model
for t=3:T
    if t==3
        % Initialisation
        predictedxi(:,t)  = Pi*mu0+Theta1*z(:,t-1)+Theta2*z(:,t-2);
        predictedP(:,:,t) = Pi*sigma0*Pi'+R;
    else
        % Prediction step
        predictedxi(:,t)  = Pi*xi(:,t-1)+Theta1*z(:,t-1)+Theta2*z(:,t-2);
        predictedP(:,:,t) = Pi*P(:,:,t-1)*Pi'+R;
    end
    % Compute Kalman gain
    kalmanGain(:,:,t) = (predictedP(:,:,t)*Q')/(Q*predictedP(:,:,t)*Q'+S);
    
    % Updating step
    xi(:,t)  = predictedxi(:,t)+kalmanGain(:,:,t)*...
        (y(:,t)-c-Q*predictedxi(:,t)-H1*z(:,t-1)-H2*z(:,t-2));
    P(:,:,t) = (eye(d)-kalmanGain(:,:,t)*Q)*predictedP(:,:,t);
    % Close the loop over time
end
% Close the function
end


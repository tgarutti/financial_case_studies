function [xi,P,predictedxi,predictedP] = MVKalmanFilter(parameter_vector,y)

% Call global variables
global Theta1 Theta2 H1 H2 z

% Extract length of the data, and the dimensionality of the problem
T = size(y,2);
d = 2; % 2 states, xi_t = [L_t S_t]'
l = 3; % 3 observations, x_t = [i_t pi_t y_t]'

% Extract the stuff we need from the input arguments
Pi = zeros(d,d);
R  = zeros(d,d);
S  = zeros(l,l);
Q  = zeros(l,d);

Pi(1,1) = parameter_vector(1);
Pi(1,2) = parameter_vector(2);
Pi(2,1) = parameter_vector(3);
Pi(2,2) = parameter_vector(4);

R(1,1) = parameter_vector(5);
R(2,2) = parameter_vector(6);

Q(1,1) = parameter_vector(7);
Q(1,2) = parameter_vector(8);
Q(2,1) = parameter_vector(9);
Q(2,2) = parameter_vector(10);
Q(3,1) = parameter_vector(11);
Q(3,2) = parameter_vector(12);

S(1,1) = parameter_vector(13);
S(2,2) = parameter_vector(14);
S(3,3) = parameter_vector(15);

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
for t=4:T 
    if t == 4
        % Initialisation
        predictedxi(:,t)  = Pi*mu0+Theta1*z(:,t-2)+Theta2*z(:,t-3);
        predictedP(:,:,t) = Pi*sigma0*Pi'+R;
    else
        % Prediction step
        predictedxi(:,t)  = Pi*predictedxi(:,t-1)+Theta1*z(:,t-2)+Theta2*z(:,t-3);
        predictedP(:,:,t) = Pi*predictedP(:,:,t-1)*Pi'+R;
    end
    % Compute Kalman gain
    kalmanGain(:,:,t) = (predictedP(:,:,t)*Q')/(Q*predictedP(:,:,t)*Q'+S);
    
    % Updating step
    xi(:,t)  = predictedxi(:,t)+kalmanGain(:,:,t)*...
        (y(:,t)-Q*predictedxi(:,t)-H1*z(:,t-2)-H2*z(:,t-3));
    P(:,:,t) = predictedP(:,:,t)-kalmanGain(:,:,t)*Q*predictedP(:,:,t);
    % Close the loop over time
end
% Close the function
end


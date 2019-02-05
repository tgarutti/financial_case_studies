function [xi,P,predictedxi,predictedP] = MVKalmanFilter(parameter_vector,y)
% This function runs the Kalman filter for a three-dimensional AR problem

% Call global variables
global Theta1 Theta2 z

% Extract length of the data, and the dimensionality of the problem
T = size(y,1);
d = 3; % 3 states, xi = [L_t S_t u_{S,t}]'

% Extract the stuff we need from the input arguments
Pi = zeros(d,d);
Q  = zeros(d,d);

Pi(1,1) = parameter_vector(1);
Pi(1,2) = parameter_vector(2);
Pi(1,3) = parameter_vector(3);
Pi(2,1) = parameter_vector(4);
Pi(2,2) = parameter_vector(5);
Pi(2,3) = parameter_vector(6);
Pi(3,1) = parameter_vector(7);
Pi(3,2) = parameter_vector(8);
Pi(3,3) = parameter_vector(9);

Q(1,1) = parameter_vector(10);
Q(1,2) = parameter_vector(11);
Q(1,3) = parameter_vector(12);
Q(2,1) = parameter_vector(13);
Q(2,2) = parameter_vector(14);
Q(2,3) = parameter_vector(15);
Q(3,1) = parameter_vector(16);
Q(3,2) = parameter_vector(17);
Q(3,3) = parameter_vector(18);

H     = zeros(3,1);
H(1)  = parameter_vector(19);
H(2)  = parameter_vector(20);
sigma = parameter_vector(21);

% Diffuse initialisation
mu0    = zeros(d,1);
sigma0 = (10^6)*eye(d);

% Initialize arrays
xi          = zeros(d,T);
P           = zeros(d,d,T);
predictedxi = zeros(d,T);
predictedP  = zeros(d,d,T);

% The Kalman filter for the multidimensional model
for t=3:T 
    if t == 3
        % Initialisation
        predictedxi(:,t)  = Pi*mu0+Theta1*z(:,t-1)+Theta2*z(:,t-2);
        predictedP(:,:,t) = (Pi*(sigma0*Pi'))+Q;
    else
        % Prediction step
        predictedxi(:,t)  = Pi*xi(:,t-1)+Theta1*z(:,t-1)+Theta2*z(:,t-2);
        predictedP(:,:,t) = (Pi*(P(:,:,t-1)*Pi'))+Q;
    end
    % Updating step
    xi(:,t)  = predictedxi(:,t)+(predictedP(:,:,t)*H)*...
                    ((H'*(predictedP(:,:,t)*H)+sigma)\(y(t)-H'*predictedxi(:,t)));
    P(:,:,t) = predictedP(:,:,t)-(predictedP(:,:,t)*H)*...
                    ((H'*(predictedP(:,:,t)*H)+sigma)\(H'*predictedP(:,:,t)));
    % Close the loop over time
end
% Close the function
end


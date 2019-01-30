function [xi,P,predictedxi,predictedP] = MVKalmanFilter(parameter_vector,y)
% This function runs the Kalman filter for a two-dimensional AR problem

% Extract length of the data, and the dimensionality of the problem
T = size(y,1);
d = size(y,2);

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

% Diffuse initialisation
mu0    = zeros(d,1);
sigma0 = (10^6)*eye(d);

% Initialize arrays
xi          = zeros(d,T);
P           = zeros(d,d,T);
predictedxi = zeros(d,T);
predictedP  = zeros(d,d,T);

% The Kalman filter for the multidimensional model
for t=1:T
    if t == 1
        % Initialisation
        predictedxi(:,t)  = F*mu0;
        predictedP(:,:,t) = (F*(sigma0*F'))+Q;
    else
        predictedxi(:,t)  = F*xi(:,t-1);
        predictedP(:,:,t) = F*P(:,:,t-1)*F'+Q;
    end
    % Update
    xi(:,t)  = predictedxi(:,t)+predictedP(:,:,t)*...
                    ((predictedP(:,:,t)+R)\(y(:,t)-predictedxi(:,t)));
    P(:,:,t) = predictedP(:,:,t)-predictedP(:,:,t)*...
                    ((predictedP(:,:,t)+R)\predictedP(:,:,t));
    % Close the loop over time
end
% Close the function
end


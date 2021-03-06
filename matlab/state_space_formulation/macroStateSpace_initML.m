%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The variables below are found using regressions using in-sample data.
% These provide an "initial state" for the Kalman filter to begin ML
% estimation. First, the linear rational expectations system needs to be 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% State-transition equation is given as:
% xi_{t+1} = Pi*xi_t + Theta1*z_t + Theta2*z_{t-1} + Sigma*v_{t+1}
% where z_t = [inflation_t' outputGap_t']', xi_t = [L_t S_t]' and v_t =
% [epsilon_{L,t} epsilon_{S,t}]', which has variance I_2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Observation equation given as:
% x_t = Q*xi_t + H1*z_{t-1} + H2*z_{t-2} + J*w_t, where x_t = [shortRate_t
% inflation_t outputGap_t]' and w_t = [epsilon_{i,t} epsilon_{pi,t}
% epsilon_{y,t}]', which has variance I_3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set global variables to be used in the Kalman filter
global Theta1 Theta2 H1 H2 z

%% Define variables
Gamma = rho(:,:,i);
Omega = sigma(:,:,i);

%% Use Sims output and data to create initial matrices
% First window initialised using the Sims output, subsequent windows
% initialised with the ML parameters from the previous estimation
if m==1
    Pi = [Gamma(5,5),Gamma(5,6);
          Gamma(6,5),Gamma(6,6)];

    % Initialize inflation and output gap dependencies on latent states and
    % lags of inflation/output gap
    deltaL = 0.8;
    deltaS = 0.8;

    % As Sims may yield unwanted zeros for various windows, perform a check
    % that assigns a uniform random number to the initial estimate if it is
    % below a specified tolerance
    e = 1e-4;

    Sigma = zeros(2,2);

    Sigma(1,1) = simsCheck(Omega(5,3),e);
    Sigma(1,2) = simsCheck(Omega(5,4),e);
    Sigma(2,1) = simsCheck(Omega(6,3),e);
    Sigma(2,2) = simsCheck(Omega(6,4),e);

    R = Sigma*Sigma'; % Covariance matrix of the states

    J      = zeros(3,3);
    J(1,1) = std(shortRate(window));
    J(2,2) = simsCheck(Omega(1,1),e);
    J(2,3) = simsCheck(Omega(1,2),e);
    J(3,2) = simsCheck(Omega(3,1),e);
    J(3,3) = simsCheck(Omega(3,2),e);

    S = J*J'; % Covariance matrix of the observations

    Q = zeros(3,2);

    Q(1,1) = deltaL;
    Q(1,2) = deltaS;
    Q(2,1) = simsCheck(Gamma(1,5),e);
    Q(2,2) = simsCheck(Gamma(1,6),e);
    Q(3,1) = simsCheck(Gamma(3,5),e);
    Q(3,2) = simsCheck(Gamma(3,6),e);
    
% Use ML parameters from previous iteration
else
    Pi = [ML_parameters(m-1,1),ML_parameters(m-1,2);
          ML_parameters(m-1,3),ML_parameters(m-1,4)];
    
    R = [ML_parameters(m-1,5),ML_parameters(m-1,6);
         ML_parameters(m-1,7),ML_parameters(m-1,8)]; % Covariance matrix of the states

    Q = [ML_parameters(m-1,9),ML_parameters(m-1,10);
         ML_parameters(m-1,11),ML_parameters(m-1,12)
         ML_parameters(m-1,13),ML_parameters(m-1,14)];
     
    S = [ML_parameters(m-1,15),0,0;
         0,ML_parameters(m-1,16),ML_parameters(m-1,17);
         0,ML_parameters(m-1,18),ML_parameters(m-1,19)]; % Covariance matrix of the observations
end

% Below are for global use in MVKalmanFilter and MVNegativeLogLikelihood;
% these parameters are not to be estimated and are assumed constant across
% the estimation window (but re-estimated at each window using Sims)
Theta1 = [Gamma(5,1),Gamma(5,3);
          Gamma(6,1),Gamma(6,3)];

Theta2 = [Gamma(5,2),Gamma(5,4);
          Gamma(6,2),Gamma(6,4)];

H1 = [0,0;
      Gamma(1,1),Gamma(1,3);
      Gamma(3,1),Gamma(3,3)];

H2 = [0,0;
      Gamma(1,2),Gamma(1,4);
      Gamma(3,2),Gamma(3,4)];
  
z = [de_inflation(window), de_outputGap(window)]'; 

%% Run Kalman filter to evolve the state, build predicted (filtered) states
clearvars options

options = optimset('fmincon');
options = optimset(options,'MaxFunEvals',1e+6);
options = optimset(options,'MaxIter',1e+6);
options = optimset(options,'TolFun',1e-6);
options = optimset(options,'TolX',1e-6);

initialEstimates = [Pi(1,1),Pi(1,2),Pi(2,1),Pi(2,2),R(1,1),R(1,2),R(2,1),R(2,2),...
    Q(1,1),Q(1,2),Q(2,1),Q(2,2),Q(3,1),Q(3,2),S(1,1),S(2,2),S(2,3),S(3,2),S(3,3)];

% Lower and upper bounds on the coefficients 
lb = [-1,-1,-1,-1,0,-10,-10,0,-10,-10,-10,-10,-10,-10,0,0,-10,-10,0];
ub = [1,1,1,1,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10];

% Add restrictions on the covariances of the states and observations
r = 2;
p = length(initialEstimates);
Aeq = zeros(r,p);
beq = zeros(r,1);

Aeq(1,6) = 1;
Aeq(1,7) = -1;
Aeq(2,17) = 1;
Aeq(2,18) = -1;

% Collect all observations into x-vector
x = [de_shortRate(window), de_inflation(window), de_outputGap(window)]';

% Perform Maximum Likelihood estimation
[ML_parameters_initML(i,:),ML_LogL_initML(i)] = fmincon('MVNegativeLogLikelihood',...
    initialEstimates,[],[],Aeq,beq,lb,ub,[],options,x);
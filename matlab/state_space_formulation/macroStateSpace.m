%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The variables below are found using regressions using in-sample data.
% These provide an "initial state" for the Kalman filter to begin ML
% estimation. First, the linear rational expectations system needs to be
% defined, and the Sims algorithm solves this system using QZ
% decomposition. A subset of the result is then used as the state
% transition equation, with the observation equation being dependent on the
% latents states L_t and S_t, as is the case in an arbitrage-free affine
% term structure model.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set global variables to be used in the Kalman filter
global Theta1 Theta2 z

%% Define variables
Gamma = rho(:,:,i);
Omega = sigma(:,:,i);

%% Use Sims output and data to create state-transition equation
% State-transition equation is given as:
% xi_{t+1} = Pi*xi_t + Theta1*z_t + Theta2*z_{t-1} + Sigma*epsilon_{t+1}
% where z_t = [inflation_t outputGap_t]' and xi_t = [L_t S_t u_{S,t}]'
Pi = [Gamma(5,5),Gamma(5,6),Gamma(5,7);
      Gamma(6,5),Gamma(6,6),Gamma(6,7);
      Gamma(7,5),Gamma(7,6),Gamma(7,7)];
  
% Next three variables are global for use in MVKalmanFilter; these
% parameters are not to be estimated and are assumed constant (non-time
% varying).
Theta1 = [Gamma(5,1),Gamma(5,3);
          Gamma(6,1),Gamma(6,3);
          Gamma(7,1),Gamma(7,3)];

Theta2 = [Gamma(5,2),Gamma(5,4);
          Gamma(6,2),Gamma(6,4);
          Gamma(7,2),Gamma(7,4)];

z = [inflation'; outputGap']; 

Sigma = [Omega(5,3) Omega(5,4);
         Omega(6,3) Omega(6,4);
         Omega(7,3) Omega(7,4)];
     
Q = Sigma*Sigma'; % Covariance matrix of the state disturbances

%% Initial estimates for observation equation
% Observation equation given as:
% i_t = H'*xi_t + sigma*epsilon^i_t where H = [deltaL deltaS 0]'
ssigma  = std(shortRate)+(abs(normrnd(0,1))/100); % Induce some randomness
deltaL = 1;
deltaS = 1;

%% Run Kalman filter to evolve the state, build predicted (filtered) states
clearvars options

options = optimset('fmincon');
options = optimset(options,'MaxFunEvals',1e+6);
options = optimset(options,'MaxIter',1e+6);
options = optimset(options,'TolFun',1e-6);
options = optimset(options,'TolX',1e-6);

initialEstimates = [Pi(1,1),Pi(1,2),Pi(1,3),Pi(2,1),Pi(2,2),Pi(2,3),...
    Pi(3,1),Pi(3,2),Pi(3,3),Q(1,1),Q(1,2),Q(1,3),Q(2,1),Q(2,2),Q(2,3),...
    Q(3,1),Q(3,2),Q(3,3),deltaL,deltaS,ssigma];

% Set (number of) parameter restrictions
r = 5;
p = 21;
Aeq = zeros(r,p);
beq = zeros(r,1);

Aeq(1,3) = 1;
Aeq(2,7) = 1;
Aeq(3,8) = 1;
Aeq(4,12) = 1;
Aeq(5,16) = 1;

% Perform Maximum Likelihood estimation
[ML_parameters(:,:,i),ML_LogL(i)] = fmincon('MVNegativeLogLikelihood',...
    initialEstimates,[],[],Aeq,beq,[],[],[],options,shortRate);
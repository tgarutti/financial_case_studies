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

% Set global variable to be used in the Kalman filter
global z

%% Define variables
Gamma = rho(:,:,i);
Omega = sigma(:,:,i);

%% Use Sims output and data to create initial matrices
Pi = [Gamma(5,5),Gamma(5,6);
      Gamma(6,5),Gamma(6,6)];

% Initialize inflation and output gap dependencies on latent states and
% lags of inflation/output gap
deltaL = 0.1;
deltaS = 0.1;

% As Sims may yield unwanted zeros for various windows, perform a check
% that assigns a uniform random number to the initial estimate if it is
% below a specified tolerance
e = 1e-4;

Sigma = zeros(2,2);

pit_yt = cov(inflation(window),outputGap(window));

Sigma(1,1) = simsCheck(Omega(5,3),e);
Sigma(1,2) = simsCheck(Omega(5,4),e);
Sigma(2,1) = simsCheck(Omega(6,3),e);
Sigma(2,2) = simsCheck(Omega(6,4),e);

R = Sigma*Sigma'; % Covariance matrix of the states

J      = zeros(3,3);
J(1,1) = std(shortRate(window));
J(2,2) = simsCheck(Omega(1,1)*sqrt(pit_yt(1,1)),e);
J(2,3) = simsCheck(Omega(1,2)*sqrt(pit_yt(1,2)),e);
J(3,2) = simsCheck(Omega(3,1)*sqrt(pit_yt(2,1)),e);
J(3,3) = simsCheck(Omega(3,2)*sqrt(pit_yt(2,2)),e);

S = J*J'; % Covariance matrix of the observations

Q = zeros(3,2);

Q(1,1) = deltaL;
Q(1,2) = deltaS;
Q(2,1) = coefpi(1);
Q(3,2) = -coefy(5);

Theta1 = [Gamma(5,1),Gamma(5,3);
          Gamma(6,1),Gamma(6,3)];

Theta2 = [Gamma(5,2),Gamma(5,4);
          Gamma(6,2),Gamma(6,4)];

H1 = [0,0;
      Gamma(1,1),Gamma(1,3);
      0,Gamma(3,3)];

H2 = [0,0;
      Gamma(1,2),0;
      0,Gamma(3,4)];
  
z = [inflation(window), outputGap(window)]';

c = [0,0,0]';

%% Run Kalman filter to evolve the state, build predicted (filtered) states
clearvars options

options = optimset('fmincon');
options = optimset(options,'MaxFunEvals',1e+6);
options = optimset(options,'MaxIter',1e+6);
options = optimset(options,'TolFun',1e-6);
options = optimset(options,'TolX',1e-6);

initialEstimates = [Pi(1,1),Pi(1,2),Pi(2,1),Pi(2,2),R(1,1),R(1,2),R(2,1),R(2,2),...
    Q(1,1),Q(1,2),Q(2,1),Q(3,2),S(1,1),S(2,2),S(2,3),S(3,2),S(3,3),...
    H1(2,1),H1(2,2),H1(3,2),H2(2,1),H2(3,2),c(1),c(2),c(3),...
    Theta1(1,1),Theta1(1,2),Theta1(2,1),Theta1(2,2),...
    Theta2(1,1),Theta2(1,2),Theta2(2,1),Theta2(2,2)];

% Lower and upper bounds on the coefficients 
lb = [0,-1,-1,0,0,-10,-10,0,-1,-1,-10,-10,0,0,-10,-10,0,0.2,-1,0.2,-1,-1,-10,-10,-10,-2,-2,-2,-2,-2,-2,-2,-2];
ub = [1,1,1,1,10,10,10,10,1,1,10,10,10,10,10,10,10,10,1,10,1,1,10,10,10,2,2,2,2,2,2,2,2];

% Add restrictions on the covariances of the states and observations
r = 2;
p = length(initialEstimates);
Aeq = zeros(r,p);
beq = zeros(r,1);

Aeq(1,6) = 1;
Aeq(1,7) = -1;
Aeq(2,15) = 1;
Aeq(2,16) = -1;

% Collect all observations into x-vector
x = [shortRate(window), inflation(window), outputGap(window)]';

% Perform Maximum Likelihood estimation
[ML_parameters(i,:),ML_LogL(i)] = fmincon('MVNegativeLogLikelihood',...
    initialEstimates,[],[],Aeq,beq,lb,ub,[],options,x);

%% Forecasting
forecastSSM;
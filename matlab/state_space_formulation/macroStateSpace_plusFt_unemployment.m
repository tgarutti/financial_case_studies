%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The variables below are found using regressions using in-sample data.
% These provide an "initial state" for the Kalman filter to begin ML
% estimation. First, the linear rational expectations system needs to be 
% solved using the Sims algorithm and resulting parametrers scaled
% accordingly.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% State-transition equation is given as:
% xi_{t+1} = Pi*xi_t + Theta1*z_t + Theta2*z_{t-1} + Sigma*v_{t+1}
% where z_t = [inflation_t' outputGap_t']', xi_t = [L_t S_t]' and v_t =
% [epsilon_{L,t} epsilon_{S,t}]', which has variance I_2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Observation equation given as:
% x_t = Q*xi_t + H1*z_{t-1} + H2*z_{t-2} + H3*Ft + J*w_t, where 
% x_t = [shortRate_t inflation_t outputGap_t]' , Ft = [Ft1 ... Ft10] and
% w_t = [epsilon_{i,t} epsilon_{pi,t} epsilon_{y,t}]', which has variance I_3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set global variable to be used in the Kalman filter
global z Ft g

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

g = [inflation(window),outputGap(window),unemployment(window),nairu(window)]';
obs = cov(g);

Sigma(1,1) = simsCheck(Omega(9,5),e);
Sigma(1,2) = simsCheck(Omega(9,6),e);
Sigma(2,1) = simsCheck(Omega(6,5),e);
Sigma(2,2) = simsCheck(Omega(6,6),e);

R = Sigma*Sigma'; % Covariance matrix of the states

J = [std(shortRate(window)),0,0,0,0;
    0,sqrt(obs(1,1)),sqrt(abs(obs(1,2))),sqrt(abs(obs(1,3))),sqrt(abs(obs(1,4)));
    0,sqrt(abs(obs(2,1))),sqrt(obs(2,2)),sqrt(abs(obs(2,3))),sqrt(abs(obs(2,4)));
    0,sqrt(abs(obs(3,1))),sqrt(abs(obs(3,2))),sqrt(obs(3,3)),sqrt(abs(obs(3,4)));
    0,sqrt(abs(obs(4,1))),sqrt(abs(obs(4,2))),sqrt(abs(obs(4,3))),sqrt(obs(4,4))];

S = J*J'; % Covariance matrix of the observations

Q = zeros(5,2);

Q(1,1) = deltaL;
Q(1,2) = deltaS;
Q(2,1) = coefpi(1);
Q(3,2) = -coefy(5);

Theta1 = [Gamma(5,1),Gamma(5,3);
          Gamma(6,1),Gamma(6,3)];

Theta2 = [Gamma(5,2),Gamma(5,4);
          Gamma(6,2),Gamma(6,4)];

H1 = [0,0,0,0;
      Gamma(1,1),Gamma(1,3),Gamma(1,5),0;
      0,Gamma(3,3),Gamma(3,5),Gamma(3,7);
      0,0,Gamma(5,5),0;
      0,0,Gamma(7,7),0];

H2 = [0,0,0,0;
      Gamma(1,2),0,0,0;
      0,Gamma(3,4),0,0;
      0,0,Gamma(5,6),0;
      0,0,Gamma(7,8),0];

H3 = [0,0,0,0,0,0,0,0,0,0;
      coefpi(6:end-1);
      coefy(6:end-1);
      0,0,0,0,0,0,0,0,0,0;
      0,0,0,0,0,0,0,0,0,0];
  
c = [0,0,0,0,0]';
  
z = [inflation(window),outputGap(window)]';

Ft = PCOrtec(window,:)';

g = [inflation(window),outputGap(window),unemployment(window),nairu(window)];

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
    Theta2(1,1),Theta2(1,2),Theta2(2,1),Theta2(2,2),...
    H3(2,1),H3(2,2),H3(2,3),H3(2,4),H3(2,5),H3(2,6),H3(2,7),H3(2,8),H3(2,9),H3(2,10),...
    H3(3,1),H3(3,2),H3(3,3),H3(3,4),H3(3,5),H3(3,6),H3(3,7),H3(3,8),H3(3,9),H3(3,10),...
    H1(3,3),H1(3,4),H1(4,3),H1(5,3),H2(4,3),H2(5,3),...
    S(2,4),S(2,5),S(3,4),S(3,5),S(4,2),S(4,3),S(4,4),S(4,5),...
    S(5,2),S(5,3),S(5,4),S(5,5)];

% Lower and upper bounds on the coefficients 
lb = [0,-1,-1,0,0,-10,-10,0,-1,-1,-10,-10,0,0,-10,-10,0,0.2,-1,0.2,-1,-1,-10,-10,-10,...
    -2,-2,-2,-2,-2,-2,-2,-2,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,...
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2,-2,...
    -10,-10,-10,-10,-10,-10,0,-10,-10,-10,-10,0];
ub = [1,1,1,1,10,10,10,10,1,1,10,10,10,10,10,10,10,10,1,10,1,1,10,10,10,...
    2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,...
    10,10,10,10,10,10,10,10,10,10,10,10];

% Add restrictions on the covariances of the states and observations
r = 8;
p = length(initialEstimates);
Aeq = zeros(r,p);
beq = zeros(r,1);

Aeq(1,6) = 1;
Aeq(1,7) = -1;
Aeq(2,15) = 1;
Aeq(2,16) = -1;
Aeq(3,60) = 1;
Aeq(3,64) = -1;
Aeq(4,61) = 1;
Aeq(4,68) = -1;
Aeq(5,62) = 1;
Aeq(5,65) = -1;
Aeq(6,63) = 1;
Aeq(6,69) = -1;
Aeq(7,67) = 1;
Aeq(7,70) = -1;
Aeq(8,54) = 1;
Aeq(8,55) = 1;

% Collect all observations into x-vector
x = [shortRate(window),inflation(window),outputGap(window),unemployment(window),nairu(window)]';

% Perform Maximum Likelihood estimation
[ML_parameters(i,:),ML_LogL(i)] = fmincon('MVNegativeLogLikelihood_plusFt_unemployment',...
    initialEstimates,[],[],Aeq,beq,lb,ub,[],options,x);

%% Forecasting
forecastHybridSSM_unemployment;
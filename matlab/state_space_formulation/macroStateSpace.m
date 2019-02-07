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
global Theta1 Theta2 H1 H2 z

%% Define variables
Gamma = rho(:,:,i);
Omega = sigma(:,:,i);

%% Use Sims output and data to create state-transition equation
% State-transition equation is given as:
% xi_{t+1} = Pi*xi_t + Theta1*z_t + Theta2*z_{t-1} + Sigma*v_{t+1}
% where z_t = [inflation_t' outputGap_t']', xi_t = [L_t S_t]' and v_t =
% [epsilon_{L,t} epsilon_{S,t}]', which has variance I_2
Pi = [Gamma(5,5),Gamma(5,6);
      Gamma(6,5),Gamma(6,6)];
  
% Next three variables are global for use in MVKalmanFilter; these
% parameters are not to be estimated and are assumed constant (non-time
% varying).
Theta1 = [Gamma(5,1),Gamma(5,3);
          Gamma(6,1),Gamma(6,3)];

Theta2 = [Gamma(5,2),Gamma(5,4);
          Gamma(6,2),Gamma(6,4)];

% De-mean the data, so we don't need constants in the filter
de_inflation = inflation-mean(inflation);
de_outputGap = outputGap-mean(outputGap);

z = [de_inflation'; de_outputGap']; 

Sigma = [Omega(5,3),Omega(5,4);
         Omega(6,3),Omega(6,4)];
     
R = Sigma*Sigma'; % Covariance matrix of the state disturbances

% Now, check tolerance level of each Sims coefficient and officially
% restrict to zero if less than eps
eps = 1e-20;
for k=1:2
    for j=1:2
        % Check Pi matrix
        if Pi(k,j)<=eps
            Pi(k,j) = 0;
        else
            continue;
        end
        % Check R matrix
        if R(k,j)<=eps
            R(k,j) = 0;
        else
            continue;
        end
    end
end

%% Initial estimates for observation equation
% Observation equation given as:
% x_t = Q*xi_t + H1*z_{t-1} + H2*z_{t-2} + J*w_t, where x_t = [shortRate_t
% inflation_t outputGap_t]' and w_t = [epsilon^i_t epsilon_{pi,t}
% epsilon_{y,t}]', which has variance I_3

% Initialize inflation and output gap dependencies on latent states and
% lags of inflation/output gap
deltaL = 1;
deltaS = 1;

Q = [deltaL,deltaS;
     Gamma(1,5),Gamma(1,6);
     Gamma(3,5),Gamma(3,6)];

H1 = [0,0;
      Gamma(1,1),Gamma(1,3);
      Gamma(3,1),Gamma(3,3)];

H2 = [0,0;
      Gamma(1,2),Gamma(1,4);
      Gamma(3,2),Gamma(3,4)];

% Initialize covariance matrix of the observation equation
J = [std(shortRate(window)),0,0;
     0,Omega(1,1),Omega(1,2);
     0,Omega(3,1),Omega(3,3)];

S = J*J';

% Now, check tolerance level of each Sims coefficient and officially
% restrict to zero if less than eps
eps = 1e-20;
for k=2:3
    for j=2:3
        % Check J matrix
        if J(k,j)<=eps
            J(k,j) = 0;
        else
            continue;
        end
    end
end

%% Run Kalman filter to evolve the state, build predicted (filtered) states
clearvars options

options = optimset('fmincon');
options = optimset(options,'MaxFunEvals',1e+6);
options = optimset(options,'MaxIter',1e+6);
options = optimset(options,'TolFun',1e-6);
options = optimset(options,'TolX',1e-6);

initialEstimates = [Pi(1,1),Pi(1,2),Pi(2,1),Pi(2,2),R(1,1),R(2,2),...
    Q(1,1),Q(1,2),Q(2,1),Q(2,2),Q(3,1),Q(3,2),S(1,1),S(2,2),S(3,3)];

Aeq = [];
beq = [];

% De-mean the short-rate so no constant is needed in the filter
de_shortRate = shortRate-mean(shortRate);

% Perform Maximum Likelihood estimation
[ML_parameters(i,:),ML_LogL(i)] = fmincon('MVNegativeLogLikelihood',...
    initialEstimates,[],[],Aeq,beq,[],[],[],options,...
    [de_shortRate(window) de_inflation de_outputGap]);
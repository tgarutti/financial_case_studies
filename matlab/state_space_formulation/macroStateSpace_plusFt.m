<<<<<<< HEAD:matlab/state_space_formulation/macroStateSpace_plusFt.m
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
% x_t = Q*xi_t + H1*z_{t-1} + H2*z_{t-2} + H3*Ft + J*w_t, where 
% x_t = [shortRate_t inflation_t outputGap_t]' , Ft = [Ft1 ... Ft10] and
% w_t = [epsilon_{i,t} epsilon_{pi,t} epsilon_{y,t}]', which has variance I_3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set global variable to be used in the Kalman filter
global z PCOrtec_window

%% Define variables
Gamma = rho(:,:,i);
Omega = sigma(:,:,i);

%% Use Sims output and data to create initial matrices
Pi = [Gamma(5,5),Gamma(5,6);
      Gamma(6,5),Gamma(6,6)];

% Initialize inflation and output gap dependencies on latent states and
% lags of inflation/output gap
deltaL = 1;
deltaS = 1;

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
Q(3,2) = simsCheck(Gamma(3,6),e);

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

H3 = [0,0,0,0,0,0,0,0,0,0;
      Gamma(1,9),Gamma(1,10),Gamma(1,11),Gamma(1,12),Gamma(1,13),...
      Gamma(1,14),Gamma(1,15),Gamma(1,16),Gamma(1,17),Gamma(1,18);
      Gamma(3,9),Gamma(3,10),Gamma(3,11),Gamma(3,12),Gamma(3,13),...
      Gamma(3,14),Gamma(3,15),Gamma(3,16),Gamma(3,17),Gamma(3,18)];
  
z = [de_inflation(window), de_outputGap(window)]'; 
PCOrtec_window = PCOrtec(window,:)';
%% Run Kalman filter to evolve the state, build predicted (filtered) states
clearvars options

options = optimset('fmincon');
options = optimset(options,'MaxFunEvals',1e+6);
options = optimset(options,'MaxIter',1e+6);
options = optimset(options,'TolFun',1e-6);
options = optimset(options,'TolX',1e-6);

initialEstimates = [Pi(1,1),Pi(1,2),Pi(2,1),Pi(2,2),R(1,1),R(1,2),R(2,1),R(2,2),...
    Q(1,1),Q(1,2),Q(2,1),Q(3,2),S(1,1),S(2,2),S(2,3),S(3,2),S(3,3),...
    Theta1(1,1),Theta1(1,2),Theta1(2,1),Theta1(2,2),...
    Theta2(1,1),Theta2(1,2),Theta2(2,1),Theta2(2,2),...
    H1(2,1),H1(2,2),H1(3,2),H2(2,1),H2(3,2),H3(2,1),H3(2,2),H3(2,3),...
    H3(2,4),H3(2,5),H3(2,6),H3(2,7),H3(2,8),H3(2,9),H3(2,10),...
    H3(3,1),H3(3,2),H3(3,3),H3(3,4),H3(3,5),H3(3,6),H3(3,7),...
    H3(3,8),H3(3,9),H3(3,10)];

% Lower and upper bounds on the coefficients 
lb = [-1,-1,-1,-1,0,-10,-10,0,-10,-10,-10,-10,0,0,-10,-10,0,-1,-1,-1,-1,...
    -1,-1,-1,-1,-1,-1,-1,-1,-1,-10,-10,-10,-10,-10,-10,-10,-10,-10,-10,...
    -10,-10,-10,-10,-10,-10,-10,-10,-10,-10];
ub = [1,1,1,1,10,10,10,10,10,10,10,10,10,10,10,10,10,...
    1,1,1,1,1,1,1,1,1,1,1,1,1,10,10,10,10,10,10,10,10,10,10,...
    10,10,10,10,10,10,10,10,10,10];

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
x = [de_shortRate(window), de_inflation(window), de_outputGap(window)]';

% Perform Maximum Likelihood estimation
[ML_parameters(i,:),ML_LogL(i)] = fmincon('MVNegativeLogLikelihood_plusFt',...
    initialEstimates,[],[],Aeq,beq,lb,ub,[],options,x);
=======
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
global predictedxi z

%% Define variables
Gamma = rho(:,:,i);
Omega = sigma(:,:,i);

%% Use Sims output and data to create initial matrices
Pi = [Gamma(5,5),Gamma(5,6);
      Gamma(6,5),Gamma(6,6)];

% Initialize inflation and output gap dependencies on latent states and
% lags of inflation/output gap
deltaL = 1;
deltaS = 1;

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
Q(3,2) = simsCheck(Gamma(3,6),e);

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
  
z = [de_inflation(window), de_outputGap(window)]'; 

%% Run Kalman filter to evolve the state, build predicted (filtered) states
clearvars options

options = optimset('fmincon');
options = optimset(options,'MaxFunEvals',1e+6);
options = optimset(options,'MaxIter',1e+6);
options = optimset(options,'TolFun',1e-6);
options = optimset(options,'TolX',1e-6);

initialEstimates = [Pi(1,1),Pi(1,2),Pi(2,1),Pi(2,2),R(1,1),R(1,2),R(2,1),R(2,2),...
    Q(1,1),Q(1,2),Q(2,1),Q(3,2),S(1,1),S(2,2),S(2,3),S(3,2),S(3,3),...
    Theta1(1,1),Theta1(1,2),Theta1(2,1),Theta1(2,2),...
    Theta2(1,1),Theta2(1,2),Theta2(2,1),Theta2(2,2),...
    H1(2,1),H1(2,2),H1(3,2),H2(2,1),H2(3,2)];

% Lower and upper bounds on the coefficients 
lb = [-1,-1,-1,-1,0,-10,-10,0,-10,-10,-10,-10,0,0,-10,-10,0,-1,-1,-1,-1,...
    -1,-1,-1,-1,-1,-1,-1,-1,-1];
ub = [1,1,1,1,10,10,10,10,10,10,10,10,10,10,10,10,10,...
    1,1,1,1,1,1,1,1,1,1,1,1,1];

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
x = [de_shortRate(window), de_inflation(window), de_outputGap(window)]';

% Perform Maximum Likelihood estimation
[ML_parameters(i,:),ML_LogL(i)] = fmincon('MVNegativeLogLikelihood',...
    initialEstimates,[],[],Aeq,beq,lb,ub,[],options,x);

%% Forecast unobserved and observed variables
% Set the number of steps ahead one would like to forecast
forecastHorizon = 16;

% Gather the full data set to evaluate forecasts
actualX = [de_shortRate, de_inflation, de_outputGap]';

forecastedXi = zeros(2,forecastHorizon);
forecastedX  = zeros(3,forecastHorizon);
forecastErr  = zeros(3,forecastHorizon);

% Build the s-step ahead forecasts
for s=1:forecastHorizon
    if s==1
        forecastedXi(:,s) = predictedxi(:,end);
        forecastedX(:,s)  = forecastX(predictedxi(:,end),[],...
                                ML_parameters(i,:),(i+w-1),s,actualX);
    else
        forecastedXi(:,s) = forecastXi(forecastedXi(:,s-1),...
                                forecastedX,ML_parameters(i,:),(i+w-1),s,actualX);
        forecastedX(:,s)  = forecastX(forecastedXi(:,s),...
                                forecastedX,ML_parameters(i,:),(i+w-1),s,actualX);
    end
    
    % Calculate forecast error
    if (i+w-1+s)<length(actualX)
        forecastErr(:,s) = forecastedX(:,s)-actualX(:,i+w-1+s);
end

forecastErrors(:,:,i) = forecastErr;
>>>>>>> master:matlab/state_space_formulation/macroStateSpace.asv

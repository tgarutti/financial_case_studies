%% Run the Sims (2001) algorithm to generate the state system
% Factor dynamics (RW for now)
rhoL = 0.989;
rhoS = 0.026;
rhoU = 0.975;
gPi  = 1.253;
gy   = 0.200;

% Inflation dynamics
muPi = 0.074;
ay   = 0.014;
aPi1 = 1.154;
aPi2 = -0.155;

% Output dynamics
muy  = 0.009;
br   = 0.089;
by1  = 0.918;
by2  = 0.078;

% Define the system as:
% Gamma0*Y_t = C + Gamma1*Y_{t-1} + Psi*epsilon_t * Pi*eta_t
Gamma0 = [1,0,0,0,-muPi,0,0,0;
          0,1,0,0,0,0,0,0;
          0,0,1,0,0,0,0,-muy;
          0,0,0,1,0,0,0,0;
          rhoL,0,0,0,1,0,0,0;
          (rhoS-1)*gPi,0,(rhoS-1)*gy,0,(1-rhoS)*gPi,1,-1,0;
          0,0,0,0,0,0,1,0;
          0,0,1,0,0,0,0,0];
      
Gamma1 = [(1-muPi)*aPi1,(1-muPi)*aPi2,ay,0,0,0,0,0;
          1,0,0,0,0,0,0,0;
          0,0,(1-muy)*by1,(1-muy)*by2,0,-br,0,0;
          0,0,1,0,0,0,0,0;
          0,0,0,0,rhoL,0,0,0;
          0,0,0,0,0,rhoS,0,0;
          0,0,0,0,0,0,rhoU,0;
          0,0,0,0,0,0,0,1];

c = zeros(8,1);
   
Psi = [1,0,0,0;
      0,0,0,0;
      0,1,0,0;
      0,0,0,0;
      0,0,1,0;
      0,0,0,0;
      0,0,0,1;
      0,0,0,0];

Pi = [0;0;0;0;0;0;0;1];

% Solve the system using the Sims algorithm to yield:
% Y_t = C + Gamma*Y_{t-1} + Omega*epsilon_t
[Gamma,C,Omega,~,~,~,~,eu] = gensys(Gamma0,Gamma1,c,Psi,Pi);

clear aPi1 aPi2 ay br by1 by2 c Gamma0 Gamma1 gPi gy muPi muy Pi Psi rhoL rhoS rhoU
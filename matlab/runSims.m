%% Run the Sims (2001) algorithm to generate the state system
% Factor dynamics (RW for now)
rhoL = coefLt(1);
rhoS = coefSt(1);
rhoU = coefres;
gPi  = coefSt(3);
gy   = coefSt(4);

% Inflation dynamics
muPi = coefpi(1);
ay   = coefpi(5);
aPi1 = coefpi(3);
aPi2 = coefpi(4);

% Output dynamics
muy  = coefy(1);
br   = coefy(5);
by1  = coefy(3);
by2  = coefy(4);

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

%% Clear variables
clear aPi1 aPi2 ay br by1 by2 c Gamma0 Gamma1 gPi gy muPi muy Pi Psi rhoL rhoS rhoU
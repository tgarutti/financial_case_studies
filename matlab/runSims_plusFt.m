%% Run the Sims (2001) algorithm to generate the state system
% Factor dynamics (RW for now)
rhoL = coefLt(1);
rhoS = coefSt(1);
rhoU = coefres;
gPi  = coefSt(4);
gy   = coefSt(3);

% Inflation dynamics
muPi   = coefpi(1);
ay     = coefpi(5);
aPi1   = coefpi(3);
aPi2   = coefpi(4);
aF1pi  = coefpi(5);
aF2pi  = coefpi(6);
aF3pi  = coefpi(7);
aF4pi  = coefpi(8);
aF5pi  = coefpi(9);
aF6pi  = coefpi(10);
aF7pi  = coefpi(11);
aF8pi  = coefpi(12);
aF9pi  = coefpi(13);
aF10pi = coefpi(14);

% Output dynamics
muy    = coefy(1);
br     = coefy(5);
by1    = coefy(3);
by2    = coefy(4);
bF1y   = coefy(5);
bF2y   = coefy(6);
bF3y   = coefy(7);
bF4y   = coefy(8);
bF5y   = coefy(9);
bF6y   = coefy(10);
bF7y   = coefy(11);
bF8y   = coefy(12);
bF9y   = coefy(13);
bF10y  = coefy(14);

%PC dynamics
rhoF1  = coefFt1;
rhoF2  = coefFt2;
rhoF3  = coefFt3;
rhoF4  = coefFt4;
rhoF5  = coefFt5;
rhoF6  = coefFt6;
rhoF7  = coefFt7;
rhoF8  = coefFt8;
rhoF9  = coefFt9;
rhoF10 = coefFt10;

% Define the system as:
% Gamma0*Y_t = C + Gamma1*Y_{t-1} + Psi*epsilon_t * Pi*eta_t
Gamma0 = [1,0,0,0,-muPi,0,0,0,-aF1pi,-aF2pi,-aF3pi,-aF4pi,-aF5pi,...
    -aF6pi,-aF7pi,-aF8pi,-aF9pi,-aF10pi;
          0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
          0,0,1,0,0,0,0,-muy,-bF1y,-bF2y,-bF3y,-bF4y,-bF5y,...
          -bF6y,-bF7y,-bF8y,-bF9y,bF10y;
          0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
          rhoL-1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0;
          (rhoS-1)*gPi,0,(rhoS-1)*gy,0,(1-rhoS)*gPi,1,-1,0,0,0,0,0,0,0,...
          0,0,0,0;
          0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0;
          0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
          0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0;
          0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0;
          0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0;
          0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0;
          0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0;
          0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0;
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0;
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0;
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0;
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1;];
      
Gamma1 = [(1-muPi)*aPi1,(1-muPi)*aPi2,ay,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
          1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
          0,0,(1-muy)*by1,(1-muy)*by2,0,-br,0,0,0,0,0,0,0,0,0,0,0,0;
          0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0;
          0,0,0,0,rhoL,0,0,0,0,0,0,0,0,0,0,0,0,0;
          0,0,0,0,0,rhoS,0,0,0,0,0,0,0,0,0,0,0,0;
          0,0,0,0,0,0,rhoU,0,0,0,0,0,0,0,0,0,0,0;
          0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0;
          0,0,0,0,0,0,0,0,rhoF1,0,0,0,0,0,0,0,0,0;
          0,0,0,0,0,0,0,0,0,rhoF2,0,0,0,0,0,0,0,0;
          0,0,0,0,0,0,0,0,0,0,rhoF3,0,0,0,0,0,0,0;
          0,0,0,0,0,0,0,0,0,0,0,rhoF4,0,0,0,0,0,0;
          0,0,0,0,0,0,0,0,0,0,0,0,rhoF5,0,0,0,0,0;
          0,0,0,0,0,0,0,0,0,0,0,0,0,rhoF6,0,0,0,0;
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,rhoF7,0,0,0;
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,rhoF8,0,0;
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,rhoF9,0;
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,rhoF10;];

c = zeros(18,1);
   
Psi = [1,0,0,0,0,0,0,0,0,0,0,0,0,0;
      0,0,0,0,0,0,0,0,0,0,0,0,0,0;
      0,1,0,0,0,0,0,0,0,0,0,0,0,0;
      0,0,0,0,0,0,0,0,0,0,0,0,0,0;
      0,0,1,0,0,0,0,0,0,0,0,0,0,0;
      0,0,0,0,0,0,0,0,0,0,0,0,0,0;
      0,0,0,1,0,0,0,0,0,0,0,0,0,0;
      0,0,0,0,0,0,0,0,0,0,0,0,0,0;
      0,0,0,0,1,0,0,0,0,0,0,0,0,0;
      0,0,0,0,0,1,0,0,0,0,0,0,0,0;
      0,0,0,0,0,0,1,0,0,0,0,0,0,0;
      0,0,0,0,0,0,0,1,0,0,0,0,0,0;
      0,0,0,0,0,0,0,0,1,0,0,0,0,0;
      0,0,0,0,0,0,0,0,0,1,0,0,0,0;
      0,0,0,0,0,0,0,0,0,0,1,0,0,0;
      0,0,0,0,0,0,0,0,0,0,0,1,0,0;
      0,0,0,0,0,0,0,0,0,0,0,0,1,0;
      0,0,0,0,0,0,0,0,0,0,0,0,0,1;];

Pi = [0;0;0;0;0;0;0;1;0;0;0;0;0;0;0;0;0;0];

% Solve the system using the Sims algorithm to yield:
% Y_t = C + Gamma*Y_{t-1} + Omega*epsilon_t
[gammaSims,C,omegaSims,~,~,~,~,eu] = gensys(Gamma0,Gamma1,c,Psi,Pi);

%% Clear variables
clear aPi1 aPi2 ay aFpi br by1 by2 bFy c Gamma0 Gamma1 gPi gy muPi muy Pi Psi rhoL rhoS rhoU rhoF
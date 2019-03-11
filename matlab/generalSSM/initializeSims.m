function [Gamma0, Gamma1, c, Psi, Lambda] = initializeSims(coefit,...
    coefLt, coefSt, coefpi, coefy, coefnu, coefnustar, restUnemp)
%RUNSIMS Runs Sims algorithm for the given coefficients and restrictions.

%% Factor dynamics
rhoL = coefLt(1);
rhoS = coefSt(1);
gPi  = coefSt(4);
gy   = coefSt(3);

%% Inflation dynamics
muPi = coefpi(1);
ay   = coefpi(5);
aPi1 = coefpi(3);
aPi2 = coefpi(4);
aNu  = coefpi(end);

%% Output dynamics
muy  = coefy(1);
br   = coefy(5);
by1  = coefy(3);
by2  = coefy(4);
bNu  = coefy(end);

%% Unemployment dynamics
muNu = coefnu(1);
psi1 = coefnu(3);
psi2 = coefnu(4);

%% NAIRU dynamics
muNuStar = coefnustar(1);
chi1     = coefnustar(3);
chi2     = coefnustar(4);

%% Define the system
% Gamma0*Y_t = C + Gamma1*Y_{t-1} + Psi*epsilon_t * Pi*eta_t
if restUnemp == 0
    Gamma0 = [1,0,0,0,-muPi,0,0,0;
              0,1,0,0,0,0,0,0;
              0,0,1,0,0,0,0,-muy;
              0,0,0,1,0,0,0,0;
              rhoL-1,0,0,0,1,0,0,0;
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
else
    Gamma0 = [1,0,0,0,0,0,0,0,-muPi,0,0,0,0;
          0,1,0,0,0,0,0,0,0,0,0,0,0;
          0,0,1,0,0,0,0,0,0,0,-muy,0,0;
          0,0,0,1,0,0,0,0,0,0,0,0,0;
          0,0,0,0,1,0,0,0,0,0,0,-muNu,0;
          0,0,0,0,0,1,0,0,0,0,0,0,0;
          0,0,0,0,0,0,1,0,0,0,0,0,-muNuStar;
          0,0,0,0,0,0,0,1,0,0,0,0,0;
          rhoL-1,0,0,0,0,0,0,0,1,0,0,0,0;
          (rhoS-1)*gPi,0,(rhoS-1)*gy,0,0,0,0,0,(1-rhoS)*gPi,1,0,0,0;
          0,0,1,0,0,0,0,0,0,0,0,0,0;
          0,0,0,0,1,0,0,0,0,0,0,0,0;
          0,0,0,0,0,0,1,0,0,0,0,0,0];
      
Gamma1 = [(1-muPi)*aPi1,(1-muPi)*aPi2,ay,0,-aNu,0,0,0,0,0,0,0,0;
          1,0,0,0,0,0,0,0,0,0,0,0,0;
          0,0,(1-muy)*by1,(1-muy)*by2,-bNu,0,bNu,0,0,-br,0,0,0;
          0,0,1,0,0,0,0,0,0,0,0,0,0;
          0,0,0,0,(1-muNu)*psi1,(1-muNu)*psi2,0,0,0,0,0,0,0;
          0,0,0,0,1,0,0,0,0,0,0,0,0;
          0,0,0,0,0,0,(1-muNuStar)*chi1,(1-muNuStar)*chi2,0,0,0,0,0;
          0,0,0,0,0,0,0,1,0,0,0,0,0;
          0,0,0,0,0,0,0,0,rhoL,0,0,0,0;
          0,0,0,0,0,0,0,0,0,rhoS,0,0,0;
          0,0,0,0,0,0,0,0,0,0,1,0,0;
          0,0,0,0,0,0,0,0,0,0,0,1,0;
          0,0,0,0,0,0,0,0,0,0,0,0,1];

c = zeros(13,1);
   
Psi = [1,0,0,0,0,0;
       0,0,0,0,0,0;
       0,1,0,0,0,0;
       0,0,0,0,0,0;
       0,0,1,0,0,0;
       0,0,0,0,0,0;
       0,0,0,1,0,0;
       0,0,0,0,0,0;
       0,0,0,0,1,0;
       0,0,0,0,0,1;
       0,0,0,0,0,0;
       0,0,0,0,0,0;
       0,0,0,0,0,0];

Lambda = [0,0,0;
          0,0,0;
          0,0,0;
          0,0,0;
          0,0,0;
          0,0,0;
          0,0,0;
          0,0,0;
          0,0,0;
          0,0,0;
          1,0,0;
          0,1,0;
          0,0,1];
end
end


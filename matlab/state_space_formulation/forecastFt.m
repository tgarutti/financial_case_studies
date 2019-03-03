function [fFt] = forecastFt(Phi,Ft,currentT,step)
% Function that forecasts the PCs

fFt = (Phi^step)*Ft(:,currentT);

end
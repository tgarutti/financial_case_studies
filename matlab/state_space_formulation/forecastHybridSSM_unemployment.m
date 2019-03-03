%% Forecast unobserved and observed variables
global xi Ft unemp nair_u

% Set the number of steps ahead one would like to forecast
forecastHorizon = 16;

% Gather the full data set to evaluate forecasts
actualX = [shortRate,inflation,outputGap]';

forecastedXi = zeros(2,forecastHorizon);
forecastedX  = zeros(3,forecastHorizon);
forecastedFt = zeros(10,forecastHorizon);
forecastErr  = zeros(3,forecastHorizon);

% Unpack ML parameters
Pi = zeros(2,2);
Q  = zeros(3,2);
H1 = zeros(3,2);
H2 = zeros(3,2);
H3 = zeros(3,10);
H4 = zeros(3,1);
H5 = zeros(3,1);
c = zeros(3,1);

Pi(1,1) = ML_parameters(i,1);
Pi(1,2) = ML_parameters(i,2);
Pi(2,1) = ML_parameters(i,3);
Pi(2,2) = ML_parameters(i,4);

Q(1,1) = ML_parameters(i,9);
Q(1,2) = ML_parameters(i,10);
Q(2,1) = ML_parameters(i,11);
Q(3,2) = ML_parameters(i,12);

H1(2,1) = ML_parameters(i,18);
H1(2,2) = ML_parameters(i,19);
H1(3,2) = ML_parameters(i,20);

H2(2,1) = ML_parameters(i,21);
H2(3,2) = ML_parameters(i,22);

c(1) = ML_parameters(i,23);
c(2) = ML_parameters(i,24);
c(3) = ML_parameters(i,25);

Theta1(1,1) = ML_parameters(i,26);
Theta1(1,2) = ML_parameters(i,27);
Theta1(2,1) = ML_parameters(i,28);
Theta1(2,2) = ML_parameters(i,29);

Theta2(1,1) = ML_parameters(i,30);
Theta2(1,2) = ML_parameters(i,31);
Theta2(2,1) = ML_parameters(i,32);
Theta2(2,2) = ML_parameters(i,33);

H3(2,1) = ML_parameters(i,34);
H3(2,2) = ML_parameters(i,35);
H3(2,3) = ML_parameters(i,36);
H3(2,4) = ML_parameters(i,37);
H3(2,5) = ML_parameters(i,38);
H3(2,6) = ML_parameters(i,39);
H3(2,7) = ML_parameters(i,40);
H3(2,8) = ML_parameters(i,41);
H3(2,9) = ML_parameters(i,42);
H3(2,10) = ML_parameters(i,43);
H3(3,1) = ML_parameters(i,44);
H3(3,2) = ML_parameters(i,45);
H3(3,3) = ML_parameters(i,46);
H3(3,4) = ML_parameters(i,47);
H3(3,5) = ML_parameters(i,48);
H3(3,6) = ML_parameters(i,49);
H3(3,7) = ML_parameters(i,50);
H3(3,8) = ML_parameters(i,51);
H3(3,9) = ML_parameters(i,52);
H3(3,10) = ML_parameters(i,53);

H4(2) = ML_parameters(i,54);
H4(3) = ML_parameters(i,55);

H5(3) = ML_parameters(i,56);

% Construct a VAR(1) model for the window PCs
varModel = varm(10,1);
Est = estimate(varModel,Ft');
PCPhi = Est.AR{1};

% Construct AR(2) model for unemployment and nairu
varUnemp = varm(1,2);
Est1 = estimate(varUnemp,unemp);
f1   = forecast(Est1,forecastHorizon,unemp);

varNairu = varm(1,2);
Est2 = estimate(varNairu,nair_u);
f2   = forecast(Est2,forecastHorizon,nair_u);

usedUnemp = [unemp(end),f1(1:end-1)'];
usedNairu = [nair_u(end),f2(1:end-1)'];

for s=1:forecastHorizon
    % First, forecast the PCs
    forecastedFt(:,s) = forecastFt(PCPhi,PCOrtec',(i+w-1),s);
    
    % Second, forecast the hidden states
    if s==1
        forecastedXi(:,s) = forecastXi(xi(:,end),forecastedX,...
                                Pi,Theta1,Theta2,(i+w-1),s,actualX);
    else
        forecastedXi(:,s) = forecastXi(forecastedXi(:,s-1),forecastedX,...
                                Pi,Theta1,Theta2,(i+w-1),s,actualX);
    end
    
    % Third, forecast the macroeconomic variables
    forecastedX(:,s)  = forecastX(forecastedXi(:,s),forecastedX,...
                            Q,H1,H2,H3,H4,H5,forecastedFt,...
                            usedUnemp,usedNairu,c,(i+w-1),s,actualX);       
    
    forecastsX(i,:,:) = forecastedX;
    forecastsXi(i,:,:) = forecastedXi;
    
    % Finally, calculate forecast error
    if (i+w-1+s)<length(actualX)
        forecastErr(:,s) = forecastedX(:,s)-actualX(:,i+w-1+s);
    else
        continue;
    end
end

forecastErrors(:,:,i) = forecastErr;
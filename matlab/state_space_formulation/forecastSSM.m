%% Forecast unobserved and observed variables
global xi

% Set the number of steps ahead one would like to forecast
forecastHorizon = 16;

% Gather the full data set to evaluate forecasts
actualX = [shortRate, inflation,  outputGap]';

forecastedXi = zeros(2,forecastHorizon);
forecastedX  = zeros(3,forecastHorizon);
forecastErr  = zeros(3,forecastHorizon);

% Unpack ML parameters
Pi = zeros(2,2);
Q  = zeros(3,2);
H1 = zeros(3,2);
H2 = zeros(3,2);
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

for s=1:forecastHorizon
    if s==1
        forecastedXi(:,s) = forecastXi(xi(:,end),forecastedX,...
                                Pi,Theta1,Theta2,(i+w-1),s,actualX);
    else
        forecastedXi(:,s) = forecastXi(forecastedXi(:,s-1),forecastedX,...
                                Pi,Theta1,Theta2,(i+w-1),s,actualX);
    end
    forecastedX(:,s)  = forecastX(forecastedXi(:,s),forecastedX,...
                            Q,H1,H2,c,(i+w-1),s,actualX);       
    
   
    forecastsX(i,:,:) = forecastedX;
    forecastsXi(i,:,:) = forecastedXi;
    
    % Calculate forecast error
    if (i+w-1+s)<length(actualX)
        forecastErr(:,s) = forecastedX(:,s)-actualX(:,i+w-1+s);
    else
        continue;
    end
end

forecastErrors(:,:,i) = forecastErr;
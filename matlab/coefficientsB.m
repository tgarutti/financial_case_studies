%% Obtain A and B coefficients
window = i:(i+w-1);
delta = regress(shortRate(window(2):window(end)), [ones(length(window)-1,1) F(:,:,i)']);
%lambda = regress(riskPremium, [ones(length(window)-1,1) F(:,:,i)']);
lambda = normrnd(0,1,[4,8]);

% Update A and B matrices for every maturity
A(1,:,i) = - delta(1);
B(1,:,i) = - delta(2:8)';
for j = 2:8
    B(j,:,i) = B(j-1,:,i)*(rho(:,:,i) - sigma(:,:,i)*lambda(:,2:8)) + B(1,:,i);
    A(j,:,i) = A(j-1,:,i) + B(j-1,:,i)*(-sigma(:,:,i)*lambda(:,1))...
        + 0.5*B(j-1,:,i)*(sigma(:,:,i)*sigma(:,:,i)')*B(j-1,:,i)'+A(1,:,i);
end

clear delta lambda

%% Obtain B coefficients
window = i:(i+w-1);
delta = regress(shortRate(window(2):window(end)), [ones(length(window)-1,1) F(:,:,i)']);


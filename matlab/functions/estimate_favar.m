function [ ffs1 ffs2 ] = estimate_favar( PCs, X, lagPC, lagVAR, window )
%UNTITLED5 pls work 
varPC = varm(size(PCs,2), lagPC);
[ffs1,~] = estimate(varPC, PCs(window,:));
favar = varm(size(X,2), lagVAR);
[ffs2,~] = estimate(favar, X(window,:), 'X', PCs(window,:));
end
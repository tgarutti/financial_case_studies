function [ norm_mat ] = normalize( mat )
%NORMALIZE Normalizes columns of input matrix
ncols = length(mat(1,:));
norm_mat = mat;

for i = 1:ncols
    norm_mat(:,i) = (mat(:,i) - mean(mat(:,i)))/std(mat(:,i));
end
end


function W = calculate_weights(A, beta)

% Input:
%   A: image
%   beta: free parameter
% Output:
%   W: matrix of weights of pixel p_kl reaching pixel p_ij

[n,m] = size(A);
MN = m*n;
Aij = reshape(A', MN, 1);
W = eye(MN,MN);
for i = 1:MN
   idx = connected(i,n,m);
   d=zeros(MN,1);
   d(idx) = (Aij(i) - Aij(idx)).^2;
   dmax = max(d);
    W(idx,i) = exp(-beta * d(idx) / dmax);
end
end
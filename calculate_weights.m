function W = calculate_weights(A, beta)

% Input:
%   A: image
%   beta: free parameter
% Output:
%   W: matrix of weights of pixel p_kl reaching pixel p_ij

[n,m] = size(A);
MN = m*n;
Aij = reshape(A', MN, 1);
dmax = 0;
for i=1:MN
    for j=i:MN
        pm = (Aij(i)-Aij(j)).^2;
        if pm > dmax
            dmax = pm;
    end
end
W = eye(MN,MN);
for i = 1:MN
   idx = connected(i,n,m);
   d=zeros(MN,1);
   d(idx) = (Aij(i) - Aij(idx)).^2;
   W(idx,i) = exp(-beta * d(idx) / dmax);
end
end
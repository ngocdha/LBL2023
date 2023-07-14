function W = calculate_weights(A, beta)

% Input:
%   A: image
%   beta: free parameter
% Output:
%   W: matrix of weights of pixel p_kl reaching pixel p_ij

[n,m,z] = size(A);
MN = m*n;
W = zeros(MN,MN);
% Aij = reshape(A', MN, 1);
dmax = max(max(max(A)));
A = [zeros(1,m+2,z);zeros(n,1,z), A, zeros(n,1,z); zeros(1,m+2,z)];
% for i=1:MN
%     for j=i:MN
%         pm = (Aij(i)-Aij(j)).^2;
%         if pm > dmax
%             dmax = pm;
%     end
% end
% for i = 1:MN
%    idx = connected(i,n,m);
%    W(idx,i) = exp(-beta * (Aij(i) - Aij(idx)).^2 / dmax);
% end
for i = 2:n+1
    for j = 2:m+1
        k = 4*(i-2) + j-1;
        W(k,k) = 1;
        if k-1 >= 1
            W(k-1,k) = exp(-beta * sqrt(sum((A(i,j,:) - A(i,j-1,:).^2))) / dmax);
        elseif k + 1 <= MN
            W(k+1,k) = exp(-beta * sqrt(sum((A(i,j,:) - A(i,j+1,:).^2))) / dmax);
        elseif k-m >= 1
            W(k-m,k) = exp(-beta * sqrt(sum((A(i,j,:) - A(i-1,j,:).^2))) / dmax);
        elseif k + m <= MN
            W(k+m,k) = exp(-beta * sqrt(sum((A(i,j,:) - A(i+1,j,:).^2))) / dmax);
        end
    end
end
% for k = 1:MN
%     for l = 1:MN
%         W(k,l) = exp(-beta * (A(fix(k,4)+1, rem(k,4)) - A(fix(l,4)+1, rem(l,4))).^2 / dmax);
%     end
% end
end
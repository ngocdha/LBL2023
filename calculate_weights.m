function W = calculate_weights(A, beta)

% Input:
%   A: image
%   beta: free parameter
% Output:
%   W: matrix of weights of pixels p_kl adjacent to pixel p_ij

[n,m,z] = size(A);
MN = m*n;
W = zeros(MN,MN);
dmax = max(max(max(A)));
A = [zeros(1,m+2,z);zeros(n,1,z), A, zeros(n,1,z); zeros(1,m+2,z)];

for i = 2:n+1
    for j = 2:m+1
        k = m*(i-2) + (j-1);
        W(k,k) = 1;
        if rem(k,m) ~= 1
            W(k-1,k) = exp(-beta * sqrt(sum((A(i,j,:) - A(i,j-1,:)).^2)) / dmax);
        end
        if rem(k,m) ~= 0
            W(k+1,k) = exp(-beta * sqrt(sum((A(i,j,:) - A(i,j+1,:)).^2)) / dmax);
        end
        if k - m >= 1
            W(k-m,k) = exp(-beta * sqrt(sum((A(i,j,:) - A(i-1,j,:)).^2)) / dmax);
        end
        if k + m <= MN
            W(k+m,k) = exp(-beta * sqrt(sum((A(i,j,:) - A(i+1,j,:)).^2)) / dmax);
        end
    end
end
W = 1/2*(W+W');
end
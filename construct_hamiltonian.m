function H = construct_hamiltonian(W,gamma)
    % Inputs:
    %   W: Matrix of weights between pixels
    %   gamma: rate of spread parameter
    % Outputs: 
    % H: Hamiltonian
    MN = size(W, 1);
    H = zeros(MN,MN);
    for i = 1:MN
        for j = 1:MN
            if i ~= j
                H(i,j) = -gamma * W(i,j);
            else
                H(i,j) = gamma * sum(W(:,j));
            end
        end
    end
end
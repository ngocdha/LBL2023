function H = construct_hamiltonian(W,gamma)
    % Inputs:
    %   W: Matrix of weights between pixels
    %   gamma: rate of spread parameter
    % Outputs: 
    % H: Hamiltonian
    MN = size(W, 1);
    H = -gamma * W;
    for i = 1:MN
        H(i,i) = gamma * (sum(W(i,:)) - W(i,i));
    end
end
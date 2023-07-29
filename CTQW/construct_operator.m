function U = construct_operator(H)
    % Inputs:
    %   H: Hamiltonian matrix
    % Outputs: 
    %   U: Unitary operator
    U = expm(-1i*H);
end
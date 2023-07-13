function D = retrieve_position(psi)

    % Input: 
    %   psi: quantum state of the walker (vector of amplitude values)
    %   output: vector of probabilities measuring each of the position

    nq = numel(psi);
    D = abs(psi).^2;
end
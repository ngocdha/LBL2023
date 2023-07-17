function new_state = update_state(t, H,state)
% update_state: takes a step of the random walk by
% applying a unitary operator U to the state 
% Input:
%   H: Hamiltonian matrix
%   state: state vector
% Output: 
%   new_state: state vector after a step of the random walk
    new_state = expmv(t, H, state);
end
numC = 0; % number of quantum coins
nbQubits = 8; % number of register qubits
nbQubits = nbQubits + numC; %total number of qubits

% Call necessary gates
MCX = @qclab.qgates.MCX;
MCRx = @qclab.qgates.MCRotationX;
MCRy = @qclab.qgates.MCRotationY;
X = @qclab.qgates.PauliX;
S = @qclab.qgates.Phase;
H = @qclab.qgates.Hadamard;
MCP = @qclab.qgates.MCPhase;
Phase90 = @qclab.qgates.Phase90;

% Make 1d Image
A = [ones(2^nbQubits/8,1); 100*ones(2^nbQubits/4,1); ones(2^nbQubits/8,1); 100*ones(2^nbQubits/2,1)];

c = gray(100);
%
%%

% Define labels
L = [1,2];
% Set seeds: 1 - white, 2 - black
seeds = [65,1,1; 200, 1, 1;
    15,1, 2; 120,1, 2];

%circuit_2 = qclab.QCircuit(2);
circuit_n = qclab.QCircuit( nbQubits ) ;
    
% 2-qubit block:
function 

% circuit

for i=1:nbQubits-1
    circuit_n.push_back(H(i));
    circuit_n.push_back(S(i,pi/2));
    circuit_n.push_back(H(i));
end
circuit_n.draw( fID, 'S' );




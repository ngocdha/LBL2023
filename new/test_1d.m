numC = 0; % number of quantum coins
nbQubits = 9; % number of register qubits
nbQubits = nbQubits + numC; %total number of qubits

% Call necessary gates
CX = @qclab.qgates.CNOT;
Rx = @qclab.qgates.RotationX;
Ry = @qclab.qgates.RotationY;
Rz = @qclab.qgates.RotationZ;
S = @qclab.qgates.Phase;
H = @qclab.qgates.Hadamard;
MCP = @qclab.qgates.MCPhase;
Phase90 = @qclab.qgates.Phase90;

% Make 1d Image
A = [ones(1,1); 100*ones(6,1); ones(2,1)];

c = gray(100);
%
%%

% Define labels
L = [1,2];
% Set seeds: 1 - white, 2 - black
seeds = [65,1,1; 200, 1, 1;
    15,1, 2; 120,1, 2];


% Make theta parameters for each location on the ring
theta = zeros(2^nbQubits,1);
beta = 150;
for i = 1:nbQubits-1
    theta(i) = exp(-beta * sum((c(A(i)) - c(A(i+1))).^2) );
end

theta = pi/40 * theta;
theta_b = [theta(1); theta(2^nbQubits:-1:2)]; 
%


%circuit_2 = qclab.QCircuit(2);
circuit_n = qclab.QCircuit( nbQubits ) ;

% QASM
fID = 1;
fprintf( fID, '\n\nQASM output:\n\n' );
fprintf( fID, 'OPENQASM 2.0;\ninclude "qelib1.inc";\n\n');
fprintf( fID, 'qreg q[%d];\n',nbQubits);
circuit_n.toQASM( fID );

% 2-qubit block:
% function 

% circuit

for i=0:nbQubits-1
    circuit_n.push_back(H(i));
    circuit_n.push_back(S(i,-pi/2));
    circuit_n.push_back(H(i));
end
    
for i=0:nbQubits-1
    if i<nbQubits-1
        j = i+1;
    else 
        j = 0;
    end

    circuit_n.push_back(CX(i,j));
    circuit_n.push_back(Rx(i,2*theta(i+1)));
    circuit_n.push_back(Rz(j,2*theta(i+1)));
    circuit_n.push_back(CX(i,j));
end

for i=0:nbQubits-1
    circuit_n.push_back(H(i));
    circuit_n.push_back(S(i,pi/2));
    circuit_n.push_back(H(i));        
end
circuit_n.draw( fID, 'S' );

% Simulate

psi = zeros(2^nbQubits,1);
psi(17) = 1;
T = 200;
p = zeros(2^nbQubits,T+1);
p(:,1) = abs(psi).^2;
for t = 1:T
    psi = circuit_n.apply('R','N',nbQubits,psi);
    p(:,1+t) = abs(psi).^2;
end

indices = zeros(nbQubits);
for i = 0:nbQubits-1
    indices(i+1) = 2^(i)+1;
end
p_state = p([2,3,5,9,17,33,65,129,257],:);

p_avg=zeros(T+1,nbQubits);
for i = 1:T+1
    p_avg(i,:) = mean(p_state(:,1:i),2);
end

figure;
surf(p_state);
title("Limiting distribution of state (1d case)");
xlabel("Time (iterations)");
ylabel("Position of up spin");
zlabel("Probability mass");

figure;
surf(p_avg);
title("Average distribution of state (1 case)");
ylabel("Time (iterations)");
xlabel("Position of up spin");
zlabel("Probability mass");



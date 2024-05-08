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
A = [99*ones(3,1); 100*ones(3,1); 99*ones(3,1)];
%A = 20:10:100;
c = gray(100);
%
%%

% Define labels
L = [1,2];
% Set seeds: 1 - white, 2 - black
seeds = [65,1,1; 200, 1, 1;
    15,1, 2; 120,1, 2];

% 
% Make theta parameters for each location on the ring

beta = 150;

theta_global = zeros(nbQubits,1);
for i = 1:nbQubits
    if i == nbQubits
        %theta_global(i) = 0;
        theta_global(i) = exp(-beta * ( sum((c(A(i)) - c(A(1))).^2 + sum((c(A(5)) - c(A(1))).^2) )));
    else
        theta_global(i) = exp(-beta * ( sum((c(A(i)) - c(A(5))).^2+sum((c(A(5)) - c(A(i+1))).^2) )));
    end
end
theta_global = pi/40 * theta_global;

theta_local = zeros(nbQubits,1);
for i = 1:nbQubits
    if i == nbQubits
        %theta_local(i) = 0;
        theta_local(i) = exp(-beta * ( sum((c(A(i)) - c(A(1))).^2) ));
    else
        theta_local(i) = exp(-beta * ( sum((c(A(i)) - c(A(i+1))).^2) ));
    end
end
theta_local = pi/40 * theta_local;

% local circuit
circuit_local = qclab.QCircuit( nbQubits ) ;

% QASM
fID = 1;
fprintf( fID, '\n\nQASM output:\n\n' );
fprintf( fID, 'OPENQASM 2.0;\ninclude "qelib1.inc";\n\n');
fprintf( fID, 'qreg q[%d];\n',nbQubits);
circuit_local.toQASM( fID ); 

% circuit

for i=0:nbQubits-1
    circuit_local.push_back(H(i));
    circuit_local.push_back(S(i,-pi/2));
    circuit_local.push_back(H(i));
end

for i = 0:2:nbQubits-2
    j = i+1;
    circuit_local.push_back(CX(i,j));
    circuit_local.push_back(Rx(i,2*theta_local(i+1)));
    circuit_local.push_back(Rz(j,2*theta_local(i+1)));
    circuit_local.push_back(CX(i,j));
end

for i = 1:2:nbQubits-2
    j = i+1;
    circuit_local.push_back(CX(i,j));
    circuit_local.push_back(Rx(i,2*theta_local(i+1)));
    circuit_local.push_back(Rz(j,2*theta_local(i+1)));
    circuit_local.push_back(CX(i,j));
end

circuit_local.push_back(CX(nbQubits-1,0));
    circuit_local.push_back(Rx(nbQubits-1,2*theta_local(nbQubits)));
    circuit_local.push_back(Rz(0,2*theta_local(nbQubits)));
    circuit_local.push_back(CX(nbQubits-1,0));

for i=0:nbQubits-1
    circuit_local.push_back(H(i));
    circuit_local.push_back(S(i,pi/2));
    circuit_local.push_back(H(i));
end

circuit_local.draw( fID, 'S' );

% Global circuit
circuit_global = qclab.QCircuit( nbQubits ) ;

% QASM
fID_2 = 2;
fprintf( fID_2, '\n\nQASM output:\n\n' );
fprintf( fID_2, 'OPENQASM 2.0;\ninclude "qelib1.inc";\n\n');
fprintf( fID_2, 'qreg q[%d];\n',nbQubits);
circuit_global.toQASM( fID_2 );

% function 

% circuit

for i=0:nbQubits-1
    circuit_global.push_back(H(i));
    circuit_global.push_back(S(i,-pi/2));
    circuit_global.push_back(H(i));
end

for i = 0:2:nbQubits-2
    j = i+1;
    circuit_global.push_back(CX(i,j));
    circuit_global.push_back(Rx(i,2*theta_global(i+1)));
    circuit_global.push_back(Rz(j,2*theta_global(i+1)));
    circuit_global.push_back(CX(i,j));
end

for i = 1:2:nbQubits-2
    j = i+1;
    circuit_global.push_back(CX(i,j));
    circuit_global.push_back(Rx(i,2*theta_global(i+1)));
    circuit_global.push_back(Rz(j,2*theta_global(i+1)));
    circuit_global.push_back(CX(i,j));
end

circuit_local.push_back(CX(nbQubits-1,0));
    circuit_global.push_back(Rx(nbQubits-1,2*theta_global(nbQubits)));
    circuit_global.push_back(Rz(0,2*theta_global(nbQubits)));
    circuit_global.push_back(CX(nbQubits-1,0));

for i=0:nbQubits-1
    circuit_global.push_back(H(i));
    circuit_global.push_back(S(i,pi/2));
    circuit_global.push_back(H(i));
end

circuit_global.draw( fID_2, 'S' );

% Simulate

psi = zeros(2^nbQubits,1);
psi(17) = 1;
T = 199;
p = zeros(2^nbQubits,T+1);
p(:,1) = abs(psi).^2;
for t = 1:T
    psi = circuit_local.apply('R','N',nbQubits,psi);
    % p(:,1+t) = abs(psi).^`2;
end

indices = zeros(nbQubits);
for i = 0:nbQubits-1
    indices(i+1) = 2^(i)+1;
end
p_state = p([2,3,5,9,17,33,65,129,257],:);

p_avg_local=zeros(T+1,nbQubits);
for i = 1:T+1
    p_avg_local(i,:) = mean(p_state(:,1:i),2);
end

psi = zeros(2^nbQubits,1);
psi(17) = 1;
T = 199;
p = zeros(2^nbQubits,T+1);
p(:,1) = abs(psi).^2;
for t = 1:T
    psi = circuit_global.apply('R','N',nbQubits,psi);
    % p(:,1+t) = abs(psi).^`2;
end

indices = zeros(nbQubits);
for i = 0:nbQubits-1
    indices(i+1) = 2^(i)+1;
end
p_state = p([2,3,5,9,17,33,65,129,257],:);

p_avg_global=zeros(T+1,nbQubits);
for i = 1:T+1
    p_avg_global(i,:) = mean(p_state(:,1:i),2);
end

% figure;
% surf(p_state);
% shading interp;
% title("Distribution of state (1-D case)");
% xlabel("Time (iterations)");
% ylabel("Position of up spin");
% zlabel("Probability mass");

figure;
subplot(1,2,1);
surf(p_avg_global);
shading interp;
cb = colorbar(); 
ylabel(cb,'Probability','FontSize',16,'Rotation',270)
title("Average distribution of state (1-D case, global weights)");
ylabel("Time (iterations)");
xlabel("Position of up spin");
zlabel("Probability mass");

subplot(1,2,2);
surf(p_avg_local);
shading interp;
cb = colorbar(); 
ylabel(cb,'Probability','FontSize',16,'Rotation',270)
title("Average distribution of state (1-D case, local weights)");
ylabel("Time (iterations)");
xlabel("Position of up spin");
zlabel("Probability mass");
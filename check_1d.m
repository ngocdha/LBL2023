numC = 0; % number of quantum coins
nbQubits = 8; % number of register qubits
nbQubits = nbQubits + numC; %total number of qubits

% Call necessary gates
MCX = @qclab.qgates.MCX;
MCRx = @qclab.qgates.MCRotationX;
MCRy = @qclab.qgates.MCRotationY;
X = @qclab.qgates.PauliX;
MCP = @qclab.qgates.MCPhase;

% Make 1d Image
A = [ones(2^nbQubits/8,1); 100*ones(2^nbQubits/4,1); ones(2^nbQubits/8,1); 100*ones(2^nbQubits/2,1)];

c = gray(100);
%
%% 

% Define labels
L = [1,2];
% Set seeds: 1 - white, 2 - black
S = [65,1,1; 200, 1, 1;
    15,1, 2; 120,1, 2];

% Make theta parameters for each location on the ring
theta = zeros(2^nbQubits,1);
beta = 150;
for i = 1:2^nbQubits-1
    theta(i) = exp(-beta * sum((c(A(i)) - c(A(i+1))).^2) );
end

theta = pi/4 * theta;
theta_b = [theta(1); theta(2^nbQubits:-1:2)]; 
%
%%
circuit_inc = qclab.QCircuit( nbQubits ) ;
circuit_dec = qclab.QCircuit( nbQubits ) ;

% QASM
fID = 1;
fprintf( fID, '\n\nQASM output:\n\n' );
fprintf( fID, 'OPENQASM 2.0;\ninclude "qelib1.inc";\n\n');
fprintf( fID, 'qreg q[%d];\n',nbQubits);
circuit_inc.toQASM( fID );
circuit_dec.toQASM( fID );

% Increment version of our circuit
for i=1:2^nbQubits
    circuit_inc.push_back( MCRy([0:nbQubits-2], nbQubits-1, zeros(nbQubits-1,1), theta_b(i)) ) ;
    circuit_inc.push_back( MCP([0:nbQubits-2], nbQubits-1, zeros(nbQubits-1,1), theta_b(i)) ) ;
    for j = 0:nbQubits-2
        circuit_inc.push_back( MCX([j+1:nbQubits-1], j,  ones(length([j+1:nbQubits-1]),1) ) ) ;
    end
    circuit_inc.push_back(  X(nbQubits-1) ) ;
    if i==1
        fprintf( fID, '\n\nCircuit diagram:\n\n' );
        circuit_inc.draw( fID, 'S' );
    end
end

% Decrement version of our circuit
for i=1:2^nbQubits
    circuit_dec.push_back( MCRy([0:nbQubits-2], nbQubits-1, zeros(nbQubits-1,1), theta(i)) ) ;
    circuit_dec.push_back( MCP([0:nbQubits-2], nbQubits-1, zeros(nbQubits-1,1), theta(i)) ) ;
    for j = 0:nbQubits-2
        circuit_dec.push_back( MCX([j+1:nbQubits-1], j,  zeros(length([j+1:nbQubits-1]),1) ) ) ;
    end
    circuit_dec.push_back(  X(nbQubits-1) ) ;
    if i==1
        fprintf( fID, '\n\nCircuit diagram:\n\n' );
        circuit_dec.draw( fID, 'S' );
    end
end
%%

tic

psi = zeros(2^nbQubits,numel(L));
% Simulate the circuit, interpret results and plot probabilities
for l = 1:numel(L)
    subset = seeds_subset(S,L(l));
    subset_length = size(subset,1);
    for s = 1:subset_length
        psi(subset(s,1),l) = 1;
    end
    psi(:,l) = 1/sqrt(subset_length) * psi(:,l);
end

T = 2; % Set number of steps
p = zeros(2^nbQubits, 1+T, numel(L)); % Initialize probabilities
LD = zeros(2^nbQubits,1, numel(L));

p(:,1,:) = abs(psi).^2;
% Simulate circuit, alternate between increment and decrement
for l = 1:numel(L)
    for t = 1:T
        if mod(t,2) == 1
            psi(:,l) = circuit_dec.apply('R', 'N', nbQubits, psi(:,l));
        else
            psi(:,l) = circuit_inc.apply('R', 'N', nbQubits, psi(:,l));
        end
        p(:,1+t,l) = abs(psi(:,l)).^2;
    end
    LD(:,l) = 1/(T+1) * sum(p(:,:,l),2);
end
%
%%
figure; subplot(1,2,1)
for i = 1:2^nbQubits
    plot(cos((i-1)*2*pi/numel(A)), -sin((i-1)*2*pi/numel(A)), 'o', 'Color', c(A(i),:), MarkerFaceColor=c(A(i),:))
    hold on
end
for s = 1:size(S,1)
    plot(cos((S(s,1)-1)*2*pi/numel(A)), -sin((S(s,1)-1)*2*pi/numel(A)), 'ro')
end
axis square

B = zeros(2^nbQubits,1);
for i = 1:2^nbQubits
    [a,id] = max(LD(i,:));
    B(i) = id;
end
b = [c(100,:); c(1,:)];
subplot(1,2,2)
for i = 1:2^nbQubits
    plot(cos((i-1)*2*pi/2^nbQubits), -sin((i-1)*2*pi/2^nbQubits), 'o', 'Color', b(B(i),:), MarkerFaceColor=b(B(i),:))
    hold on
end
axis square
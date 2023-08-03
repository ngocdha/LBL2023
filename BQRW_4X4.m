numC = 2;
numQ = 8;
nbQubits = numQ + numC; 

MCX = @qclab.qgates.MCX;
Ry = @qclab.qgates.RotationY;
MCRy = @qclab.qgates.MCRotationY;
X = @qclab.qgates.PauliX;
H = @qclab.qgates.Hadamard;

theta = [pi/2; pi/2];

circuit = qclab.QCircuit( nbQubits ) ;
% initialize the coins as heads instead of tails
% for i = 1:numC
%     circuit.push_back( X(nbQubits-i) ) ; 
% end
% circuit.push_back( X(nbQubits-1) ) ;

for T=1:1
    for c = 1:numC;
        circuit.push_back( Ry(nbQubits-c, theta(c)) ) ;
    end
    for i=0:numQ-1
        circuit.push_back( MCX([i+1:numQ],i, ones(size([i+1:numQ])) )) ;
    end
    for i=0:numQ-1
        circuit.push_back( MCX([i+1:numQ+1],i, [zeros(size([i+1:numQ+1]))] )) ;
    end
end

% QASM
fID = 1;
fprintf( fID, '\n\nQASM output:\n\n' );
fprintf( fID, 'OPENQASM 2.0;\ninclude "qelib1.inc";\n\n');
fprintf( fID, 'qreg q[%d];\n',nbQubits);
circuit.toQASM( fID );

% Draw circuit
fprintf( fID, '\n\nCircuit diagram:\n\n' );
circuit.draw( fID, 'S' );

% Simulate the circuit, interpret results and plot probabilities
pos = 512;
psi = zeros(1024,1); psi(pos) = 1;
psi = circuit.apply('R', 'N', nbQubits, psi);
p = abs(psi).^2;

myXticklabels = cell( 2^(nbQubits), 1 );
for i = 0:2^(nbQubits)-1
    myXticklabels{i+1} = dec2bin( i, nbQubits );
end

TTL = strcat('100 steps, angle $\frac{\pi}{4}$, initial state: $\vert 0,1\rangle_C\otimes\vert$', sprintf('%d', pos/4-1), '$\rangle_P$');

figure; clf
bar( 1:2^(nbQubits), p );
xticks( 1:2^(nbQubits) );
xticklabels( myXticklabels );
ylabel('Probabilities');
%
figure; clf
% myPositionLabels = cell( 2^(nbQubits-2), 1 );
% for i = 0:2^(nbQubits-2)-1
%   myPositionLabels{i+1} = strcat(sprintf('%d, ', floor(i/(nbQubits-2))), sprintf('%d', mod(i,(nbQubits-2))));
% end
q = ( p(1:4:2^nbQubits) + p(2:4:2^nbQubits) + p(3:4:2^nbQubits) + p(4:4:2^nbQubits));
bar(0:2^(nbQubits-2)-1, q)
% xticks(0:2^(nbQubits-2)-1)
% xticklabels(myPositionLabels)
ylabel('Probabilities');xlabel('Position')
%
title(TTL, 'Interpreter','latex')
%
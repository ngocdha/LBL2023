nbQubits = 5;

MCX = @qclab.qgates.MCX;
H = @qclab.qgates.Hadamard;
CNOT = @qclab.qgates.CNOT;
X = @qclab.qgates.PauliX;

circuit = qclab.QCircuit( nbQubits ) ;
circuit.push_back( X(nbQubits-1) ) ;
circuit.push_back( H (nbQubits-1) ) ;


for T = 1:100
    increment( circuit ) ;
    decrement( circuit ) ;
    circuit.push_back( H(nbQubits-1) );
end

% QASM
fID = 1;
fprintf( fID, '\n\nQASM output:\n\n' );
fprintf( fID, 'OPENQASM 2.0;\ninclude "qelib1.inc";\n\n');
fprintf( fID, 'qreg q[%d];\n',nbQubits);
circuit.toQASM( fID );

% Draw circuit
% fprintf( fID, '\n\nCircuit diagram:\n\n' );
% circuit.draw( fID, 'S' );

% Simulate the circuit, interpret results and plot probabilities
psi = eye(2^nbQubits, 1);
psi = circuit.apply('R', 'N', nbQubits, psi);
p = abs(psi).^2;

myXticklabels = cell( 2^(nbQubits), 1 );
for i = 0:2^(nbQubits)-1
  myXticklabels{i+1} = dec2bin( i, nbQubits );
end

figure(1); clf
bar( 1:2^(nbQubits), p );
xticks( 1:2^(nbQubits) );
xticklabels( myXticklabels );
ylabel('Probabilities');


function increment(circuit)
    MCX = @qclab.qgates.MCX;
    X = @qclab.qgates.PauliX;

    n = double(circuit.nbQubits);
    for i = 1:n-2
        circuit.push_back( MCX(i:n-1, i-1, ones(length(i:n-1))) );
    end

    % circuit.push_back( X(n-2) );
    circuit.push_back( MCX(n-1, n-2, 1) );
end

function decrement(circuit)
    MCX = @qclab.qgates.MCX;
    X = @qclab.qgates.PauliX;

    n = double(circuit.nbQubits);
    for i = 1:n-2
        circuit.push_back( MCX(i:n-1, i-1, zeros(length(i:n-1)))) ;
    end
    % circuit.push_back( X(n-2) );
    circuit.push_back( MCX(n-1, n-2, 0) );
end
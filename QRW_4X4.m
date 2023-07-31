nbQubits = 6; 

MCX = @qclab.qgates.MCX;
MCH = @qclab.qgates.MCH;
H = @qclab.qgates.Hadamard;
CNOT = @qclab.qgates.CNOT;

circuit = qclab.QCircuit( nbQubits ) ;


circuit.push_back( H(nbQubits - 1) ) ;
circuit.push_back( H(nbQubits - 2) ) ;

circuit.push_back( MCH([2, 3], 4, [1,1]) ) ;

circuit.push_back( MCX([5,4,3], 2, [1,1,1]) ) ;

circuit.push_back( MCX([5,4], 3, [1,1]) ) ;

circuit.push_back( MCH([2,3], 4, [1,1]) ) ;

circuit.push_back( MCH([0,1], 5, [1,1]) ) ;

circuit.push_back( MCX([5,4,1], 0, [1,0,1]) ) ;

circuit.push_back( MCX([5, 4], 1, [1,0]) ) ;

circuit.push_back( MCH([0,1], 5, [1,1]) ) ;

circuit.push_back( MCH([2, 3], 4, [0,0]) ) ;

circuit.push_back( MCX([2, 3], 4, [0,0]) ) ;

circuit.push_back( MCX([5,4,3], 2, [0,0,0,]) ) ;

circuit.push_back( MCX([5,4], 3, [0,0]) ) ;

circuit.push_back( MCH([2,3], 4, [0,0]) ) ;

circuit.push_back( MCX([0,1], 5, [0,0]) ) ;

circuit.push_back( MCX([5,4,1], 0, [0,1,0]) ) ;

circuit.push_back( MCX([5,4], 1, [0,1]) ) ;

circuit.push_back( MCX([0,1], 5, [0,0]) ) ;

circuit.push_back( MCH([0,1], 5, [0,0]) ) ;


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
psi = eye(2^nbQubits, 1);
psi = circuit.apply('R', 'N', nbQubits, psi);
p = abs(psi).^2;

myXticklabels = cell( 2^(nbQubits), 1 );
for i = 0:2^(nbQubits)-1
  myXticklabels{i+1} = dec2bin( i, nbQubits );
end

figure; clf
bar( 1:2^(nbQubits), p );
xticks( 1:2^(nbQubits) );
xticklabels( myXticklabels );
ylabel('Probabilities');

figure; clf
q = 1/2 *( p(1:2:2^nbQubits - 1) + p(2:2:2^nbQubits));
bar(0:2^(nbQubits-1)-1, q)
% xticks(0:2^(nbQubits-1)-1)
ylabel('Probabilities');xlabel('Position')
% title(TTL, 'Interpreter','latex')


function increment(circuit)
    MCX = @qclab.qgates.MCX;
    X = @qclab.qgates.PauliX;

    n = double(circuit.nbQubits);
    for i = 1:n-2
        circuit.push_back( MCX(i:n-1, i-1, ones(length(i:n-1))) );
    end

    circuit.push_back( X(n-1) );
end

function decrement(circuit)
    MCX = @qclab.qgates.MCX;
    X = @qclab.qgates.PauliX;

    n = double(circuit.nbQubits);
    for i = 1:n-2
        circuit.push_back( MCX(i:n-1, i-1, zeros(length(i:n-1)))) ;
    end
    circuit.push_back( X(n-1) );
end
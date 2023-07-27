nbQubits = 5;

MCX = @qclab.qgates.MCX;
H = @qclab.qgates.Hadamard;

circuit = qclab.QCircuit( nbQubits ) ;
circuit.push_back( H (nbQubits-1) ) ;
increment( circuit ) ;

decrement( circuit ) ;

% QASM
fID = 1;
fprintf( fID, '\n\nQASM output:\n\n' );
fprintf( fID, 'OPENQASM 2.0;\ninclude "qelib1.inc";\n\n');
fprintf( fID, 'qreg q[%d];\n',nbQubits);
circuit.toQASM( fID );

% Draw circuit
fprintf( fID, '\n\nCircuit diagram:\n\n' );
circuit.draw( fID, 'S' );

function increment(circuit)
    MCX = @qclab.qgates.MCX;

    n = double(circuit.nbQubits);
    for i = 1:n-2
        circuit.push_back( MCX(i:n-2, i-1, ones(length(i:n-2))) );
    end
end

function decrement(circuit)
    MCX = @qclab.qgates.MCX;

    n = double(circuit.nbQubits);
    for i = 1:n-2
        circuit.push_back( MCX(i:n-2, i-1, zeros(length(i:n-2)))) ;
    end
end
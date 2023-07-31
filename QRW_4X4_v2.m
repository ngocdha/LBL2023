nbQubits = 6; 

MCX = @qclab.qgates.MCX;
MCH = @qclab.qgates.MCH;
H = @qclab.qgates.Hadamard;

circuit = qclab.QCircuit( nbQubits ) ;


circuit.push_back( H(nbQubits - 1) ) ;
circuit.push_back( H(nbQubits - 2) ) ;

% decrement in x
%   if x is 0 (00): don't decrease
circuit.push_back( MCH([0,1], nbQubits-2, [0,0]) ) ; % puts x-coin in 0 - state
circuit.push_back( MCX([0,1], nbQubits-2, [0,0]) ) ; % puts x-coin in 1 - state

circuit.push_back( MCX([nbQubits-2, nbQubits-1, 1], 0, [0,1,0]) ) ;
circuit.push_back( MCX([nbQubits-2, nbQubits-1], 1, [0,1]) ) ;

% reset the x-coin if x was 0 (00)
circuit.push_back( MCX([0,1], nbQubits-2, [0,0]) ) ;
circuit.push_back( MCH([0,1], nbQubits-2, [0,0]) ) ;

% decrement in y
%   if y is 0 (00): don't decrease
circuit.push_back( MCH([2,3], nbQubits-1, [0,0]) ) ; % puts y-coin in 0 - state
circuit.push_back( MCX([2,3], nbQubits-1, [0,0]) ) ; % puts y-coin in 1 - state

circuit.push_back( MCX([nbQubits-2, nbQubits-1, 3], 2, [0,0,0]) ) ;
circuit.push_back( MCX([nbQubits-2, nbQubits-1], 3, [0,0]) ) ;

% reset the y-coin if y was 0 (00)
circuit.push_back( MCX([2,3], nbQubits-1, [0,0]) ) ;
circuit.push_back( MCH([2,3], nbQubits-1, [0,0]) ) ;

% increment in x
%   if x is 3 (11): don't increase
circuit.push_back( MCH([0,1], nbQubits-2, [1,1]) ) ; % puts x-coin in 0 - state

circuit.push_back( MCX([nbQubits-2, nbQubits-1, 1], 0, [1,0,1]) ) ;
circuit.push_back( MCX([nbQubits-2, nbQubits-1], 1, [1,0]) ) ;

%reset the x-coin if x was 3 (11)
circuit.push_back( MCH([0,1], nbQubits-2, [1,1]) ) ;

% increment in y
%   if y is 3 (11): don't increase

circuit.push_back( MCH([2,3], nbQubits-1, [1,1]) ) ; % puts y-coin in 0 - state

circuit.push_back( MCX([nbQubits-2, nbQubits-1, 3], 2, [1,1,1]) ) ;
circuit.push_back( MCX([nbQubits-2, nbQubits-1], 3, [1,1]) ) ;

%reset the y-coin if y was 3 (11)
circuit.push_back( MCH([2,3], nbQubits-1, [1,1]) ) ;



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
myPositionLabels = cell( 2^(nbQubits-2), 1 );
for i = 0:2^(nbQubits-2)-1
  myPositionLabels{i+1} = strcat(sprintf('%d, ', floor(i/(nbQubits-2))), sprintf('%d', mod(i,(nbQubits-2))));
end
q = ( p(1:4:2^nbQubits) + p(2:4:2^nbQubits) + p(3:4:2^nbQubits) + p(4:4:2^nbQubits));
bar(0:2^(nbQubits-2)-1, q)
xticks(0:2^(nbQubits-2)-1)
xticklabels(myPositionLabels)
ylabel('Probabilities');xlabel('Position')

% title(TTL, 'Interpreter','latex')

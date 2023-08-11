numC = 0; % number of quantum coins
numQ = 8; % number of register qubits
nbQubits = numQ + numC; %total number of qubits

% Call necessary gates
MCX = @qclab.qgates.MCX;
MCRx = @qclab.qgates.MCRotationX;
MCRy = @qclab.qgates.MCRotationY;
X = @qclab.qgates.PauliX;
MCP = @qclab.qgates.MCPhase;

% Make theta parameters for each location on the ring
theta = pi/4 * ones(2^nbQubits,1);
theta(1:101) =  pi/6; theta(201:2^nbQubits) = pi/6;
theta(nbQubits) = 0;
theta_b = [theta(1); theta(2^nbQubits:-1:2)]; 

circuit_inc = qclab.QCircuit( nbQubits ) ;
circuit_dec = qclab.QCircuit( nbQubits ) ;

% QASM
fID = 1;
fprintf( fID, '\n\nQASM output:\n\n' );
fprintf( fID, 'OPENQASM 2.0;\ninclude "qelib1.inc";\n\n');
fprintf( fID, 'qreg q[%d];\n',nbQubits);
circuit_inc.toQASM( fID );
circuit_dec.toQASM( fID );

tic

% Increment version of our circuit
for i=1:2^nbQubits
    circuit_inc.push_back( MCRy([0:numQ-2], numQ-1, zeros(numQ-1,1), theta_b(i)) ) ;
    circuit_inc.push_back( MCP([0:numQ-2], 7, zeros(numQ-1,1), pi/10) ) ;
    for j = 0:numQ-2
        circuit_inc.push_back( MCX([j+1:numQ-1], j,  ones(length([j+1:numQ-1]),1) ) ) ;
    end
    circuit_inc.push_back(  X(nbQubits-1) ) ;
    if i==1
        fprintf( fID, '\n\nCircuit diagram:\n\n' );
        circuit_inc.draw( fID, 'S' );
    end
end

% Decrement version of our circuit
for i=1:2^nbQubits
    circuit_dec.push_back( MCRy([0:numQ-2], numQ-1, zeros(numQ-1,1), theta(i)) ) ;
    circuit_dec.push_back( MCP([0:numQ-2], 7, zeros(numQ-1,1), pi/10) ) ;
    for j = 0:numQ-2
        circuit_dec.push_back( MCX([j+1:numQ-1], j,  zeros(length([j+1:numQ-1]),1) ) ) ;
    end
    circuit_dec.push_back(  X(nbQubits-1) ) ;
    if i==1
        fprintf( fID, '\n\nCircuit diagram:\n\n' );
        circuit_dec.draw( fID, 'S' );
    end
end
toc
%%

tic

% Simulate the circuit, interpret results and plot probabilities
pos = 151; % MATLAB indexing for beggining location
           % i.e. pos = n corresponds to position n-1 on the ring

psi = zeros(2^nbQubits,1); psi(pos) = 1; % Set initial state

T = 200; % Set number of steps
p = zeros(2^nbQubits, T); % Initialize probabilities

% Simulate circuit, alternate between increment and decrement
for t = 1:T
    if mod(t,2) == 1
        psi = circuit_dec.apply('R', 'N', nbQubits, psi);
    else
        psi = circuit_inc.apply('R', 'N', nbQubits, psi);
    end
    p(:,t) = abs(psi).^2;
end
toc
%
%%
TTL = strcat('Initial state: $\vert$', sprintf('%d', pos-1), '$\rangle_P$, Number of steps: ', sprintf('%d, ', T), 'boundary rotation angle: (L,R) = ($\frac{\pi}{5}, \frac{\pi}{5}$)');

figure; clf

k = (0:(2^numQ - 1)); % position vector

% Initialize expected position and std.dev. vectors
E_pos = zeros(T,1);
std_dev = zeros(T,1);

for t=1:T
    E_pos(t) = dot(k,p(:,t));
    std_dev(t) = sqrt(dot(k.^2, p(:,t)) - E_pos(t).^2);
end

% plot prob. dist. at final time
plot(k,p(:,T))
xlim([0,256])
ylabel('Probabilities'); xlabel('Position')
title(TTL, 'Interpreter','latex')
%
%% 
% Create surface plot
figure; clf
surf(1:T, k, p)
axis([1 T 0 256])
xlabel('Time')
ylabel('Position')
zlabel('Probablity')

%% 
% Create plot of std. dev. over time
figure; clf
plot(1:T, std_dev)
hold on
plot(1:T, min(std_dev)*ones(T,1), '--k')
plot(1:T, max(std_dev)*ones(T,1), '--k')
axis([1, T, 0, 2^nbQubits])
xlabel('Time')
ylabel('$\sigma$', 'Interpreter', 'latex')
title('Standard deviation over time')
%% 
%Create plot of Expected position over time 
figure; clf
plot(1:T, E_pos)
hold on
plot(1:T, min(E_pos)*ones(T,1), '--k')
plot(1:T, max(E_pos)*ones(T,1), '--k')
axis([1, T, 0, 2^nbQubits])
xlabel('Time')
ylabel('Expected position')
title('Expected position over time')
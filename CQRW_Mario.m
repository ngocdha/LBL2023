% Define a 4X4 image // small numbers are dark, large numbers are white
% A = [2, 7, 84, 100;
%     1, 12, 74, 98;
%     13, 21, 4, 9;
%     31, 13, 7, 3];
s = 4;
% A = [ones(2*s,s), [100*ones(s,s); ones(s,s)]];
% c = gray(100);
A = imread('Images/mario.jpg'); imshow(A)
[n,m,d] = size(A);

% Define labels
L = [1, 2, 3, 4, 5, 6]; % 1 - red, 2 - blue, 3 - brown, 4 - white, 5 - black, 6 - skin
% Define seeds
S = [8, 1, 1; 12, 9, 1; 4, 9, 1;
    9, 12, 2; 
    12, 16, 3; 5, 15, 3; 4, 6, 3;
    1, 8, 4; 16, 8, 4; 9, 15, 4;
    11, 3, 5; 12, 6, 5;
    3, 12, 6; 13, 12, 6; 8, 5, 6; 13, 4, 6];
c = [A(1,8,:); A(12,9,:); A(16,12,:); reshape([255,255,255],1,1,3); reshape([0,0,0],1,1,3); A(12,3,:)]; c = reshape(c,6,3); c = double(c);

theta = zeros(n,m,2);
beta = 150;
tau = pi/4;
for i = 1:n-1
    for j = 1:m
        theta(i,j,1) = exp(-beta * sum((A(i,j,:) - A(i+1,j,:)).^2) );
    end
end
for i = 1:n
    for j = 1:m-1
        theta(i,j,2) = exp(-beta * sum((A(i,j,:) - A(i,j+1,:)).^2) );
    end
end
theta = tau * theta;
%
%%
numQx = log2(m); % number of x-register qubits
numQy = log2(n); % number of y-register qubits
nbQubits = numQx + numQy; % total number of qubits

circuit = qclab.QCircuit( nbQubits ) ; % Create the circuit

% QASM
fID = 1;
fprintf( fID, '\n\nQASM output:\n\n' );
fprintf( fID, 'OPENQASM 2.0;\ninclude "qelib1.inc";\n\n');
fprintf( fID, 'qreg q[%d];\n',nbQubits);
circuit.toQASM( fID );

%
%% Construct the circuit

for i = 1:2^numQy
    for j = 1:2^numQx
        block(circuit, theta(i,j,1), theta(i,j,2), numQy)
    end
    dec_x(circuit, numQy)
    if i == 1
        fprintf( fID, '\n\nCircuit diagram:\n\n' );
        circuit.draw( fID, 'S' );
    end
end

% fprintf( fID, '\n\nCircuit diagram:\n\n' );
% circuit.draw( fID, 'S' );

%
%%
T = [100]; % Number of steps
for w = 1:numel(T)
    LD = zeros(2^(numQx+numQy),numel(L));

    psi = zeros(2^(numQx + numQy),numel(L));

    for l = 1:numel(L)
        subset = seeds_subset(S,L(l));
        subset_length = size(subset,1);
        for s = 1:subset_length
            psi(subset(s,2) + m * (subset(s,1)-1),l) = 1;
        end
        psi(:,l) = 1/sqrt(subset_length) * psi(:,l);
    end

    p = zeros(2^(numQx+numQy), 1+T(w), numel(L));
    p(:,1,:) = abs(psi(:,:)).^2;
    for l = 1:numel(L)
        for t = 1:T(w)
            psi(:,l) = circuit.apply('R', 'N', nbQubits, psi(:,l));
            p(:,1+t,l) = abs(psi(:,l)).^2;
        end
        LD(:,l) = 1/(1+T(w)) * sum(p(:,:,l),2);
    end

    
    if w == 10
        figure; subplot(1,2,1); imshow(A)
        hold on
        plot(S(:,1), S(:,2), 'o', 'Color', 'green')
        hold off
        title('Original Image', Interpreter='latex')
        hold off
        B = zeros(n,m,3);
    
        for i=1:n
            for j=1:m
                [a,id] = max(LD(m*(j-1)+i,:));
                B(i,j,:) = c(id,:);
            end
        end
        B = uint8(B);
        subplot(1,2,2)
        imshow(B)
        title(strcat('Segmented Image: $T = ', sprintf('%d$', w)), Interpreter="latex")
        hold off
    end
end
%
%% Function definitions %%

function block(circuit, tht_h, tht_v, numQy)
MCRy = @qclab.qgates.MCRotationY;
MCP = @qclab.qgates.MCPhase;
MCX = @qclab.qgates.MCX;
X = @qclab.qgates.PauliX;

n = circuit.nbQubits;

circuit.push_back( MCRy(0:n-2, n-1, zeros(length(0:n-2)), tht_h) ) ;
circuit.push_back( MCP(0:n-2, n-1, zeros(length(0:n-2)), tht_h) ) ;

circuit.push_back( MCRy([0:numQy-2, numQy:n-1], numQy-1, ...
    zeros(length([0:numQy-2, numQy:n-1])), tht_v) ) ;

circuit.push_back( MCP([0:numQy-2, numQy:n-1], numQy-1, ...
    zeros(length([0:numQy-2, numQy:n-1])), tht_v) ) ;

% for j = numQy:n-2
%     circuit.push_back( MCX(j+1:n-1, j,  zeros(length(j+1:n-1),1) ) ) ;
% end
% circuit.push_back( X(n-1) ) ;

for j = 0:numQy-2
    circuit.push_back( MCX(j+1:numQy-1, j,  zeros(length(j+1:numQy-1),1) ) ) ;
end
circuit.push_back( X(numQy-1) ) ;

end

% function dec_y(circuit, numQy)
% MCX = @qclab.qgates.MCX;
% X = @qclab.qgates.PauliX;
% 
% for j = 0:numQy-2
%     circuit.push_back( MCX(j+1:numQy-1, j, zeros(length(j+1:numQy-1))) ) ;
% end
% circuit.push_back( X(numQy-1) ) ;
% end

function dec_x(circuit, numQy)
MCX = @qclab.qgates.MCX;
X = @qclab.qgates.PauliX;

n = circuit.nbQubits;

for j = numQy:n-2
    circuit.push_back( MCX(j+1:n-1, j, zeros(length(j+1:n-1))) ) ;
end
circuit.push_back( X(n-1) ) ;
end
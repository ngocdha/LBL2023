% Load image
% A = imread('Images/mario.jpg'); % imshow(A)
A = egg; % figure; imshow(A)
[n,m,d] = size(A);
%
%%
% Define labels
L = [1, 2, 3]; % 1 - cream, 2 - blue, 3 - black
% Define seeds
S = [8, 5, 1; 8, 14, 1; 5, 9, 1; 13, 9, 1;
    10, 9, 2; 13, 13, 2; 11, 4, 2; 4, 11, 2; 5, 5, 2;
    9, 1, 3; 2, 9, 3; 15, 10, 3; 9, 16, 3; 4, 14, 3; 13, 5, 3; 4, 4, 3; 14, 13, 3];
c = [A(8,5,:); A(9,10,:); uint8(zeros(1,1,3)); A(1,1,:)]; c = reshape(c,4,3); c = double(c);

theta = zeros(n,m,2);
beta = 1/1000;
tau = pi/4;
for i = 1:n-1
    for j = 1:m
        theta(i,j,1) = exp(-beta * sum((double(A(i,j,:)) - double(A(i+1,j,:))).^2) );
    end
end
for i = 1:n
    for j = 1:m-1
        theta(i,j,2) = exp(-beta * sum((double(A(i,j,:)) - double(A(i,j+1,:))).^2) );
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
T = [1:5, 10, 25]; % Number of steps
LD = zeros(2^(numQx+numQy),numel(L));
p = zeros(2^(numQx+numQy), 1+T(end), numel(L));
psi = zeros(2^(numQx + numQy),numel(L));
for l = 1:numel(L)
    subset = seeds_subset(S,L(l));
    subset_length = size(subset,1);
    for s = 1:subset_length
        psi(subset(s,2) + n * (subset(s,1)-1),l) = 1;
    end
    psi(:,l) = 1/sqrt(subset_length) * psi(:,l);
end

p(:,1,:) = abs(psi(:,:)).^2;

M(1+10) = struct('cdata',[],'colormap',[]);
h = figure; h.Visible = 'off';

axis tight manual
ax = gca;
ax.NextPlot = 'replaceChildren';

v = VideoWriter('egg', 'MPEG-4') ; 
open(v)
subplot(1,2,1); imshow(A)
hold on
plot(S(:,1), S(:,2), 'o', 'Color', 'red')
hold off
title('Original Image', Interpreter='latex')
hold off

B = zeros(n,m,3);

for i=1:n
    for j=1:m
        if ismember( A(i,j,:), c(1:3,:,:) )
            [a,id] = max(p(m*(j-1)+i,1,:));
            if a == 0
                B(i,j,:) = [255, 0, 255]; % fuchsia
            else
                B(i,j,:) = c(id,:);
            end
        else
            B(i,j,:) = c(4,:);
        end
    end
end
B = uint8(B);
subplot(1,2,2)
imshow(B)
title(strcat('Segmented Image: $T = ', sprintf('%d$', 0)), Interpreter="latex")
hold off
drawnow
f = getframe(gcf);
M(1) = f;
writeVideo(v,f);

for w = 1:10

    for l = 1:numel(L)
        psi(:,l) = circuit.apply('R', 'N', nbQubits, psi(:,l));
        p(:,1+w,l) = abs(psi(:,l)).^2;
        LD(:,l) = 1/(1+w) * sum(p(:,:,l),2);
    end


    % if ismember(w,T)
    figure; subplot(1,2,1); imshow(A)
    hold on
    plot(S(:,1), S(:,2), 'o', 'Color', 'red')
    hold off
    title('Original Image', Interpreter='latex')
    hold off
    B = zeros(n,m,3);

    for i=1:n
        for j=1:m
            if ismember( A(i,j,:), c(1:3,:,:) )
                [a,id] = max(LD(m*(j-1)+i,:));
                if a == 0
                    B(i,j,:) = [255, 0, 255]; % fuchsia
                else
                    B(i,j,:) = c(id,:);
                end
            else
                B(i,j,:) = c(4,:);
            end
        end
    end
    B = uint8(B);
    subplot(1,2,2)
    imshow(B)
    title(strcat('Segmented Image: $T = ', sprintf('%d$', w)), Interpreter="latex")
    hold off

    drawnow
    f = getframe(gcf);
    M(1+w) = f;
    for i = 1:10
        writeVideo(v,f);
    end
    % end
end
close(v)
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

%
%%
function A = egg
A = 255*ones(16,14,3); A(1,6:9,:) = zeros(4,1,3); A(16,6:9,:) = zeros(4,1,3);
A(8:11,1,:) = zeros(4,1,3); A(8:11,14,:) = zeros(4,1,3);
A(6:7,2,:) = zeros(2,1,3); A(4:5,3,:) = zeros(2,1,3); A(6:7,13,:) = zeros(2,1,3); A(4:5,12,:) = zeros(2,1,3);
A(12:13,2,:) = zeros(2,1,3); A(12:13,13,:) = zeros(2,1,3);
A(14,3,:) = zeros(1,1,3); A(14,12,:) = zeros(1,1,3);
A(15,4:5,:) = zeros(1,2,3); A(15, 10:11,:) = zeros(1,2,3);
A(3,4,:) = zeros(1,1,3); A(2,5,:) = zeros(1,1,3);
A(2,10,:) = zeros(1,1,3); A(3,11,:) = zeros(1,1,3);

A(3,9:10,1) = 70*ones(1,2); A(3,9:10,2) = 130*ones(1,2); A(3,9:10,3) = 180*ones(1,2);
A(4:5,9:11,1) = 70*ones(2,3); A(4:5,9:11,2) = 130*ones(2,3); A(4:5,9:11,3) = 180*ones(2,3);
A(6,10:11,1) = 70*ones(1,2); A(6,10:11,2) = 130*ones(1,2); A(6,10:11,3) = 180*ones(1,2);
A(4:6,4:5,1) = 70*ones(3,2); A(4:6,4:5,2) = 130*ones(3,2); A(4:6,4:5,3) = 180*ones(3,2);
A(6:7,3,1) = 70*ones(1,2); A(6:7,3,2) = 130*ones(1,2); A(6:7,3,3) = 180*ones(1,2);
A(7,4,1) = 70; A(7,4,2) = 130; A(7,4,3) = 180;
A(11:13,3:4,1) = 70*ones(3,2); A(11:13,3:4,2) = 130*ones(3,2); A(11:13,3:4,3) = 180*ones(3,2);
A(10:11,2,1) = 70*ones(1,2); A(10:11,2,2) = 130*ones(1,2); A(10:11,2,3) = 180*ones(1,2);
A(10,3,1) = 70; A(10,3,2) = 130; A(10,3,3) = 180;
A(8:12,7:9,1) = 70*ones(5,3); A(8:12,7:9,2) = 130*ones(5,3); A(8:12,7:9,3) = 180*ones(5,3);
A(9:11,6,1) = 70*ones(1,3); A(9:11,6,2) = 130*ones(1,3); A(9:11,6,3) = 180*ones(1,3);
A(9:11,10,1) = 70*ones(1,3); A(9:11,10,2) = 130*ones(1,3); A(9:11,10,3) = 180*ones(1,3);
A(12:14,11,1) = 70*ones(1,3); A(12:14,11,2) = 130*ones(1,3); A(12:14,11,3) = 180*ones(1,3);
A(11:13,12,1) = 70*ones(1,3); A(11:13,12,2) = 130*ones(1,3); A(11:13,12,3) = 180*ones(1,3);
A(11,13,1) = 70; A(11,13,2) = 130; A(11,13,3) = 180;
A = [255*ones(16,1,3), A, 255*ones(16,1,3)];

A(:,1,1) = 172*ones(16,1); A(:,1,2) = 165*ones(16,1); A(:,1,3) = 158*ones(16,1);
A(:,16,1) = 172*ones(16,1); A(:,16,2) = 165*ones(16,1); A(:,16,3) = 158*ones(16,1);

A(1:7,2,1) = 172*ones(7,1); A(1:7,2,2) = 165*ones(7,1); A(1:7,2,3) = 158*ones(7,1);
A(12:16,2,1) = 172*ones(5,1); A(12:16,2,2) = 165*ones(5,1); A(12:16,2,3) = 158*ones(5,1);
A(1:7,15,1) = 172*ones(7,1); A(1:7,15,2) = 165*ones(7,1); A(1:7,15,3) = 158*ones(7,1);
A(12:16,15,1) = 172*ones(5,1); A(12:16,15,2) = 165*ones(5,1); A(12:16,15,3) = 158*ones(5,1);

A(1:5,3,1) = 172*ones(5,1); A(1:5,3,2) = 165*ones(5,1); A(1:5,3,3) = 158*ones(5,1);
A(14:16,3,1) = 172*ones(3,1); A(14:16,3,2) = 165*ones(3,1); A(14:16,3,3) = 158*ones(3,1);
A(1:5,14,1) = 172*ones(5,1); A(1:5,14,2) = 165*ones(5,1); A(1:5,14,3) = 158*ones(5,1);
A(14:16,14,1) = 172*ones(3,1); A(14:16,14,2) = 165*ones(3,1); A(14:16,14,3) = 158*ones(3,1);

A(1:3,4,1) = 172*ones(3,1); A(1:3,4,2) = 165*ones(3,1); A(1:3,4,3) = 158*ones(3,1);
A(15:16,4,1) = 172*ones(2,1); A(15:16,4,2) = 165*ones(2,1); A(15:16,4,3) = 158*ones(2,1);
A(1:3,13,1) = 172*ones(3,1); A(1:3,13,2) = 165*ones(3,1); A(1:3,13,3) = 158*ones(3,1);
A(15:16,13,1) = 172*ones(2,1); A(15:16,13,2) = 165*ones(2,1); A(15:16,13,3) = 158*ones(2,1);

A(16,11:12,1) = 172*ones(2,1); A(16,11:12,2) = 165*ones(2,1); A(16,11:12,3) = 158*ones(2,1);
A(16,5:6,1) = 172*ones(2,1); A(16,5:6,2) = 165*ones(2,1); A(16,5:6,3) = 158*ones(2,1);
A(1,11:12,1) = 172*ones(2,1); A(1,11:12,2) = 165*ones(2,1); A(1,11:12,3) = 158*ones(2,1);
A(1,5:6,1) = 172*ones(2,1); A(1,5:6,2) = 165*ones(2,1); A(1,5:6,3) = 158*ones(2,1);

A(2,5,1) = 172; A(2,5,2) = 165; A(2,5,3) = 158;
A(2,12,1) = 172; A(2,12,2) = 165; A(2,12,3) = 158;

idx = A(:,:,1) == 255;
for i = 1:16
    for j = 1:16
        if idx(i,j) == 1
            A(i,j,2) = 253; A(i,j,3) = 208;
        end
    end
end
A = uint8(A);
end
numQx = 4; % number of x-register qubits
numQy = 4; % number of y-register qubits
nbQubits = numQx + numQy; % total number of qubits

circuit = qclab.QCircuit( nbQubits ) ; % Create the circuit

% QASM
fID = 1;
fprintf( fID, '\n\nQASM output:\n\n' );
fprintf( fID, 'OPENQASM 2.0;\ninclude "qelib1.inc";\n\n');
fprintf( fID, 'qreg q[%d];\n',nbQubits);
circuit.toQASM( fID );

ex = 10; ey = 10; % Define the rectangular boundaries
%
%% Construct the circuit

tic
for j = 1:2^numQy
    for i = 1:2^numQx
        block(circuit, theta_h(i,j,ex,ey,numQx), theta_v(i,j,ex,ey,numQy), numQx, numQy)
    end
    dec_y(circuit, numQy)
end
toc

% fprintf( fID, '\n\nCircuit diagram:\n\n' );
% circuit.draw( fID, 'S' );

%
%% Initialize the state vector

psi = zeros(2^(numQx + numQy),1);
psi(1) = 1;
% psi( 5*2^numQx + 5 ) = 1;

T = 0; % Number of steps

h = figure; h.Visible = 'off';

axis tight manual
ax = gca;
ax.NextPlot = 'replaceChildren';

loops = 40*10;
M(loops) = struct('cdata',[],'colormap',[]);
v = VideoWriter('QRW_2d', 'MPEG-4') ; 
open(v)

for i = 1:loops/10
    for t = 1:T
        psi = circuit.apply('R', 'N', nbQubits, psi);
    end
    
    p = abs(psi).^2; p = reshape(p,2^numQx, 2^numQy);
    %
    %% Create a surface plot
    
    % figure; clf
    surf(0:2^numQy-1, 0:2^numQx-1,p)
    title(strcat('CQRW after T = ', sprintf('%d ',T+1), ' steps'))
    xlabel('$x$', 'Interpreter','latex')
    ylabel('$y$', 'Interpreter','latex')
    xlim([0, 2^numQx-1])
    ylim([0, 2^numQy-1])
    drawnow
    f = getframe(gcf);
    M(10*(t-1)+1:10*t) = f;
    for p = 1:10
        writeVideo( v, f ) ;
    end
    T = T + 1;
end
close(v)
%
%% Function definitions %%

function block(circuit, tht_h, tht_v, numQx, numQy)
MCRy = @qclab.qgates.MCRotationY;
MCP = @qclab.qgates.MCPhase;
MCX = @qclab.qgates.MCX;
X = @qclab.qgates.PauliX;

n = circuit.nbQubits;

circuit.push_back( MCRy([0:n-2], n-1, zeros(length(0:n-2)), tht_h) ) ;
circuit.push_back( MCP([0:n-2], n-1, zeros(length(0:n-2)), tht_h) ) ;
circuit.push_back( MCRy([0:numQy-2, numQy:n-1], numQy-1, zeros(length([0:numQy-2, numQy:n-1])), tht_v) ) ;
circuit.push_back( MCP([0:numQy-2, numQy:n-1], numQy-1, zeros(length([0:numQy-2, numQy:n-1])), tht_v) ) ;
for j = numQy:n-2
    circuit.push_back( MCX([j+1:n-1], j,  zeros(length([j+1:n-1]),1) ) ) ;
end
circuit.push_back( X(n-1) ) ;
end

function dec_y(circuit, numQy)
MCX = @qclab.qgates.MCX;
X = @qclab.qgates.PauliX;

n = circuit.nbQubits;

for j = 0:numQy-2
    circuit.push_back( MCX([j+1:numQy-1], j, zeros(length([j+1:numQy-1]))) ) ;
end
circuit.push_back( X(numQy-1) ) ;
end

function [th] = theta_h(i,j, ex, ey, numQx)
    if i == ex
        if j <= ey
            th = 0;
        else
            th = pi/40;
        end
    elseif i == 2^numQx
        if j <= ey
            th = 0;
        else
            th = pi/40;
        end
    else
        th = pi/40;
    end
end

function [tv] = theta_v(i,j, ex, ey, numQy)
    if j == ey
        if i <= ex
            tv = 0;
        else
            tv = pi/40;
        end
    elseif j == 2^numQy
        if i <= ex
            tv = 0;
        else
            tv = pi/40;
        end
    else
        tv = pi/40;
    end
end
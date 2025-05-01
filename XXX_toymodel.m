clc; clear;

tic

% === 1. Input Image ===
n1=5;% half the legth of image 1
img1 = [255 *ones(1,n1),ones(1, n1)];% image 1 is half balck and half white
n2=8;% length of image 2
img2 = ones(1,n2); %image 2 is all the same color
img = img1; %choose between image 1 and image 2 to run the algorithm
n = length(img);

% === 2. Spin Operators and Identity ===
sx = [0, 1; 1, 0];
sy = [0, 1i; -1i, 0];
sz = [1, 0; 0, -1];
I = eye(2);

% === 3. Pixel Similarity → Coupling Strengths J(i) ===
J = zeros(1, n);%create J-tensor containing the interactions
for i = 1:n-1
    next = i + 1;%A:removed mod to make it a line segment
    diff = abs(img(i) - img(next));
    J(i) = 1 + exp(-diff/(256)) -exp(diff/(256));  % similarity-based coupling; it scales with the size of the image
    J(i) = 2 + 10*exp(-diff/(256)) -10*exp(diff/(256)); % 2 is a base point that may be adapted
    %J(i)=1;
end

% === 4. Construct Ising-like Hamiltonian ===
H = zeros(2^n);

% (a) Interaction: -J(i) * σz_i * σz_{i+1}
for i = 1:n-1%changed n to n-1
    opX = 1;
    opY = 1;
    opZ = 1;
    for j = 1:n
        if j == i || j == i+1  %A:removed mod to make it a line segment
            X = sx;
            Y = sy;
            Z = sz;
        else
            X = I;
            Y = I;
            Z = I;
        end
        opX = kron(opX, X);
        opY = kron(opY, Y);
        opZ = kron(opZ, Z);
    end
    H = H - (opY + opZ)-  J(i)*opX;
end
%if we set J =1, then the expected value of sz is non-zero
%if we set J=-1, the ground state is gapless meaning that the eigenspace of
%of the lowest eigenvalue is degenerate and, as a result, we obtain
%expected values of sz that are not zero. 

% (b1) Dipole interaction1: S(i).S(j)/|i-j|^3
d=100; %strenth of dipole interaction
for i = 1:n
    for j=1:n
        opX = 1;
        opY = 1;
        opZ = 1;
        for k = 1:n
            if k == i || k == j 
                X = sx;
                Y = sy;
                Z = sz;
            else
                X = I;
                Y = I;
                Z = I;
            end
        opX = kron(opX, X);
        opY = kron(opY, Y);
        opZ = kron(opZ, Z);
        end
        if i ~= j
            H = H  + (1/(d*abs(i-j))^3)*(opX + opY + opZ);
        end
    end
end
%We (should) get a zero expcted value of the x-spin on each site if this is
%the only interaction and the image is constant. This is due to symmetry.
%Actually, the behaviour is a bit more sublte since the ground state is
%gapless, meaning that the eigenspace with the lowest eigenvalue is
%degenerate. There will be an eigenvector that has zero expected value of
%the x-spin for all sites.

% (b2) Dipole interaction2: [S(i).(i-j)][S(j).(i-j)]/|i-j|^5
for i = 1:n
    for j=1:n
        opX = 1;
        for k = 1:n
            if k == i || k == j 
                X = sx;
            else
                X = I;
            end
        opX = kron(opX, X);
        end
        if i ~= j
            H = H  -(3/(d*abs(i-j))^3)*(opX);
        end
    end
end
%This term introduces the geomerty dependence. We assume that all the
%vertexes in the lattice lie in the x-axis, which leads to a simplification
%and only sx terms

%H=-H;%flip the energies?

% (c) Label constraints: pixel n/4 = +1, 3n/4 = –1
label_strength = 1*n;%strength of the magnetic field, n, increases with the size of the image; set label strength to 0 to remove magnetic field
label_indices = [floor(n/4), floor(3*n/4)];
label_targets = [+1, -1];

for k = 1:length(label_indices)
    i = label_indices(k);
    target = label_targets(k);
    op = 1;
    for j = 1:n
        A = (j == i) * sx + (j ~= i) * I;
        op = kron(op, A);
    end
    H = H - label_strength * target * op;
end

%H = sparse(H);%tranform to a sparese matrix

% === 5. Solve for Ground State ===
%[evecs, evals] = eigs(H, 1, 'SA');%use this if the matrix if SPARSE
%ground_state = evecs;%use this if the matrix is SPARSE
[evecs, evals] = eig(H);%use this if the matrix is NOT SPARSE
[~, idx] = min(diag(evals));%use this if the matrix is NOT SPARSE
%idx=5;%index override
ground_state = evecs(:, idx);%use this if the matrix is NOT SPARSE

% === 6. Measure ⟨σx⟩ for Each Pixel ===
expect_vals = zeros(1, n);
tot_sx = 0;%total x-spin magnetization
for i = 1:n
    op = 1;
    for j = 1:n
        A = (j == i) * sx + (j ~= i) * I;
        op = kron(op, A);
    end
    tot_sx = tot_sx + op;
    expect_vals(i) = real(ground_state' * op * ground_state);
end

% === 7. Assign Segments ===
segments = expect_vals >= 0;


% === 9. Plotting ===
figure;

subplot(3,1,1);
bar(img);
title('Input 1D Image (Pixel Intensities)');
ylabel('Intensity');
xticks(1:n);
grid on;

subplot(3,1,2);
bar(expect_vals, 'FaceColor', [0.2 0.6 0.8]);
title('⟨σ_x⟩ Values (Spin State)');
ylabel('⟨σ_x⟩');
xticks(1:n);
yline(0, '--k');
grid on;

subplot(3,1,3);
bar(segments, 'FaceColor', [0.9 0.5 0.2]);
title('Segment Assignment (1 = Foreground, 0 = Background)');
xlabel('Pixel Index');
ylabel('Segment');
xticks(1:n);
ylim([-0.5 1.5]);
grid on;

toc
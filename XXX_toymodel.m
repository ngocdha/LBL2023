clc; clear;

% === 1. Input Image ===
img = [255, 250, 240, 245, 10, 5, 15, 8];
n = length(img);

% === 2. Spin Operators and Identity ===
sx = [0, 1; 1, 0];
sy = [0, 1i; -1i, 0];
sz = [1 0; 0 -1];
I = eye(2);

% === 3. Pixel Similarity → Coupling Strengths J(i) ===
J = zeros(1, n);
for i = 1:n-1
    next = i + 1;%A:removed mod to make it a line segment
    diff = abs(img(i) - img(next));
    J(i) = exp(-diff / 50);  % similarity-based coupling
end

% === 4. Construct Ising-like Hamiltonian ===
H = zeros(2^n);

% (a) Interaction: -J(i) * σz_i * σz_{i+1}
for i = 1:n
    opA = 1;
    opB = 1;
    opC = 1;
    for j = 1:n
        if j == i || j == i + 1 %A:removed mod to make it a line segment
            A = sx;
            B = sy;
            C = sz;
        else
            A = I;
            B = I;
            C = I;
        end
        opA = kron(opA, A);
        opB = kron(opB, B);
        opC = kron(opC, C);
    end
    H = H - J(i) * (opA + opB + opC);
end

% (b) Label constraints: pixel 2 = +1, pixel 6 = –1
label_strength = 2.0;
label_indices = [2, 6];
label_targets = [+1, -1];

for k = 1:length(label_indices)
    i = label_indices(k);
    target = label_targets(k);

    op = 1;
    for j = 1:n
        A = (j == i) * sz + (j ~= i) * I;
        op = kron(op, A);
    end
    H = H - label_strength * target * op;
end

% === 5. Solve for Ground State ===
[evecs, evals] = eig(H);
[~, idx] = min(diag(evals));
ground_state = evecs(:, idx);

% === 6. Measure ⟨σz⟩ for Each Pixel ===
expect_vals = zeros(1, n);
for i = 1:n
    op = 1;
    for j = 1:n
        A = (j == i) * sz + (j ~= i) * I;
        op = kron(op, A);
    end
    expect_vals(i) = real(ground_state' * op * ground_state);
end

% === 7. Assign Segments ===
segments = expect_vals >= 0;

% === 8. Plotting ===
figure;

subplot(3,1,1);
bar(img);
title('Input 1D Image (Pixel Intensities)');
ylabel('Intensity');
xticks(1:n);
grid on;

subplot(3,1,2);
bar(expect_vals, 'FaceColor', [0.2 0.6 0.8]);
title('⟨σ_z⟩ Values (Spin State)');
ylabel('⟨σ_z⟩');
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
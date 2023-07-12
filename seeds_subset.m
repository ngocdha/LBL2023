function subset = seeds_subset(S, label)
    % Input:
    %   S: matrix of pixel location and label
    %      e.g. S(1,:) = [{x-index of pixel}, {y-index of pixel},
    %                      {label}]
    %   label: the desired label to retrieve seeds from

    idx = (S(:,3) == label);
    subset = S(idx, 1:2);
end
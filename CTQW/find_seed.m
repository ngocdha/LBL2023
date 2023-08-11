function k = find_seed(LD, i, j, num_cols)
    % Input:
    %   LD: The limiting distribution of the walk
    %   (i,j): the position of ij-th pixel
    % Output:
    %   k: seed with highest probability of being measured
    %       at the ij-th pixel
    l = size(LD, 2);
    idx = num_cols*(i-1) + j;
    M = -1;
    k = -1;
    for p = 1:l
        if LD(idx,p) > M
            M = LD(idx,p);
            k = p;
        end
    end
end
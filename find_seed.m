function k = find_seed(LD, i, j)
    % Input:
    %   LD: The limiting distribution of the walk
    %   (i,j): the position of ij-th pixel
    % Output:
    %   k: seed with highest probability of being measured
    %       at the ij-th pixel
    l = size(LD, 3);
    max = -1;
    k = -1;
    for p = 1:l
        if LD(i,j,p) > max
            max = LD(i,j,p);
            k = p;
        end
    end
end
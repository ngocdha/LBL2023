function v = connected(i,rows,cols)
% Input:
% i: current index
% rows,cols: length of rows and columns of image
% Output:
% v: boolean vector, true at indices where
%    pixels are connected
MN = rows*cols;
I = eye(MN,MN);
v = logical(I(:,i));
if i <= cols
    if i == 1
        v(i+1) = true;
        v(i+cols) = true;

    elseif i == cols
        v(i-1) = true;
        v(i+cols) = true;
    else
        v(i+1) = true;
        v(i-1) = true;
        v(i+cols) = true;
    end

elseif i > MN-cols
    if i == MN
        v(i-1) = true;
        v(i-cols) = true;
    elseif i == MN -(cols-1)
        v(i+1) = true;
        v(i-cols) = true;
    else
        v(i+1) = true;
        v(i-1) = true;
        v(i-cols) = true;
    end
else
    if mod(i,cols+1) == 0
        v(i+cols) = true;
        v(i-cols) = true;
        v(i+1) = true;
    elseif mod(i,cols) == 0
        v(i-1) = true;
        v(i-cols) = true;
        v(i+cols) = true;
    else
        v(i+1) = true;
        v(i-1) = true;
        v(i-cols) = true;
        v(i+cols) = true;
    end
end
end
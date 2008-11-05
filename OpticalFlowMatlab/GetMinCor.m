function [c1, c2, c3] = GetMinCor(error)
%find the min error and return the coordinate
ind = find(error == min(error(:)));
size1 = size(error, 1);
size2 = size(error, 2);
size3 = size(error, 3);


c3 = floor(ind/(size1*size2))+1;
c_rem = mod(ind, size1*size2);
c2 = floor(c_rem/size1) + 1;
c1 = mod(c_rem, size1);
disp(sprintf('Min Value %d', error(c1, c2, c3)));
disp(sprintf('Coordinate %d, %d, %d', c1, c2, c3));
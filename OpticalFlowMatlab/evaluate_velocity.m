function [error1, error2, error3, std1, std2, std3] = evaluate_velocity(v, v0, mask)
% [PHI, PHI2] = EVALUATE_VELOCITY(V, V0, MASK, C, DENSITIES)
%
% Evaluate velocity estimates, using the average spatiotemporal angular
% error.
%
% V    - Estimated velocity field
% V0   - Correct velocity field
% MASK - Ignore values where mask is zero
%
% PHI  - Angular errors at each pixel, measured in degrees.
% PHI2 - Angular errors at each pixel under MASK, drawn out to a vector.
%
% Author: Gunnar Farnebäck
%         Computer Vision Laboratory
%         Linköping University, Sweden
%         gf@isy.liu.se
% Revised by Zhaoyi Wei
if ~islogical(mask)
    error('mask must be a logical array');
end
densities = [1 0.9 0.7];

phi = angular_error(v0, v);
phi2= phi(mask);
c  = ones(size(v, 1), size(v, 2));
c2 = c(mask);
[tmp, order] = sort(c2);
disp(sprintf('average   std    density'))
disp(sprintf(' error    dev'))
density = 1;
m = mean(phi2(order(1:floor(density*length(phi2)))));
s = std(phi2(order(1:floor(density*length(phi2)))));
error1 = m;
std1 = s;
disp(sprintf('%6.3f   %6.3f  %3d%%', m, s, density*100))

density = 0.9;
m = mean(phi2(order(1:floor(density*length(phi2)))));
s = std(phi2(order(1:floor(density*length(phi2)))));
error2 = m;
std2 = s;
disp(sprintf('%6.3f   %6.3f  %3d%%', m, s, density*100))

density = 0.7;
m = mean(phi2(order(1:floor(density*length(phi2)))));
s = std(phi2(order(1:floor(density*length(phi2)))));
error3 = m;
std3 = s;
disp(sprintf('%6.3f   %6.3f  %3d%%', m, s, density*100))


function [sequence, mask, correct_flow] = read_yosemite(bound)
% [SEQUENCE, MASK, CORRECT_FLOW] = READ_YOSEMITE
%
% Read 15 frames from the Yosemite sequence. These are originally
% numbered yos2--yos16, with the correct flow being known for the middle
% frame yos9.
%
% SEQUENCE     - 252x316x15 array with gray values.
% MASK         - 252x316 logical array which is one everywhere except
%                for the sky.
% CORRECT_FLOW - The correct flow field for yos9, which is available
%                as SEQUENCE(:,:,8).
%

s = which('read_yosemite');
slashes = findstr(s, '\');
% yosemite_dir = [s(1:slashes(end)) 'yosemite_sequence\'];
yosemite_dir = 'images/yosemite/';

% Read a sample frame and allocate space for 15 frames.
% a = imread([yosemite_dir 'new0_yos7.bmp']);
a = imread([yosemite_dir 'yos7.tif']);
sides = size(a);
sequence = zeros([sides 15]);

% Read the relevant part of the sequence.
for i=1:15
    sequence(:,:,i) = double(imread([yosemite_dir 'yos' int2str(i+1) '.tif']));
    %sequence(:,:,i) = double(imread([yosemite_dir 'new0_yos' int2str(i+1) '.bmp']));
end

% Create the mask for the non-sky.
load([yosemite_dir 'correct_flow']);
mask = (correct_flow(:,:,1) ~= 2.0);
mask_bound = zeros(sides(1), sides(2));
mask_bound(bound:sides(1)-bound, bound:sides(2)-bound) = 1;
mask_bound = logical(mask_bound);
mask = mask & mask_bound;
% mask = zeros(sides);

% Permute the directions to agree with our conventions.
correct_flow(:,:,[1 2]) = correct_flow(:,:,[2 1]);
correct_flow(:,:,1) = -correct_flow(:,:,1);

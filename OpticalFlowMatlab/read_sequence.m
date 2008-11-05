function [sequence] = read_sequence(dir, prefix, suffix, append0, idx)
%This function reads out one frame indicated by the
%Dir: directory of the file
%prefix: the prefix of the file name
%suffix: the suffix of the file
%whether to append 0 or not at the beginning of file name, if non-zero,
%will append certain number of 0 before index
%i: index of the file

append0str = [];
for i=1:append0
    append0str = [append0str int2str(0)];
end;

if (append0)    
    if (idx < 10)
        append0str = [append0str int2str(0)];
    end;
    name = [dir prefix append0str int2str(idx) '.' suffix];
else
    name = [dir prefix int2str(idx) '.' suffix];
end;

sequence_raw = (imread(name));

if (size(sequence_raw, 3) > 1)
    sequence = double(rgb2gray(sequence_raw));
else
    sequence = double(sequence_raw);
end;

a = 1;
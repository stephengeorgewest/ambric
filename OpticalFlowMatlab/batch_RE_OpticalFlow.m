%This function is for running simulation result over large amount of image.
%Save the result as video

function batch_RE_OpticalFlow(inputSeqIdx)

saveVideo = 0;
rootDir = 'images/';
temporalLength = 7; %the least length of sequence that we could calculate one field of optical flow

figure

%read image sequence
%%%%%%%%%%%%%%%%%%%%%0-10 synthetic sequence%%%%%%%%%%%%%%%%%%%
%0---Yosemite sequence
%1---Flower Garden sequence
%2---Rubic sequence
%3---Taxi sequence
%4---SRI trees sequence
%5---Mobile calendar

%%%%%%%%%%%%%%%%%%%%11 or above real sequence%%%%%%%%%%%%%%%%%%
%11--BYU corridor sequence
switch inputSeqIdx
    case 0
        startIdx = 2;
        endIdx   = 16;
        seqDir   = 'yosemite/';
        prefix  = 'yos';  %common part of file name
        suffix   = 'tif';  %suffix of the file
        append0  = 0;
    case 1
        startIdx = 0;
        endIdx   = 30;
        seqDir   = 'flower garden/';
        prefix   = 'flowg';
        suffix   = 'bmp';
        append0  = 2;
    case 2
        startIdx = 1;
        endIdx   = 21;
        seqDir   = 'taxi\';
        prefix   = 'taxi';
        suffix   = 'tif';
        append0  = 0;
    case 3
        startIdx = 0;
        endIdx   = 19;
        seqDir   = 'rubic\';
        prefix   = 'rubic';
        suffix   = 'tif';
        append0  = 0;
    case 4
        startIdx = 0;
        endIdx   = 19;
        seqDir   = 'SRI trees\';
        prefix   = 'trees';
        suffix   = 'bmp';
        append0  = 0;
    case 5
        startIdx = 1;
        endIdx   = 19;
        seqDir   = 'mobile&calendar\mobl_400\';
        prefix   = 'frame';
        suffix   = 'bmp';
        append0  = 0;
    case 6
        startIdx = 58280;
        endIdx   = 58400;
        seqDir   = 'byu corridor\';
        prefix   = 'img';
        suffix   = 'bmp';
        append0  = 0;
    otherwise
      disp('Unknown method.')
end



dir = [rootDir seqDir];
correct_flow = load('correct_flow.mat');%[]; %
correct_flow = correct_flow.correct_flow;
%mask = [];
seqLength = endIdx - startIdx + 1;

if saveVideo == 1
    fullfilename = [dir prefix '_result' '.avi']; %reading avi!!!
    aviobj = avifile(fullfilename, 'fps', 5);
end;

if (seqLength <temporalLength)
    error('Image Sequence is too short');
end;

for i=startIdx:startIdx+temporalLength-2
    cSeq(:,:,i-startIdx+1) = read_sequence(dir, prefix, suffix, append0, i);
end;

%mask to filter out the boundary
sides = size(cSeq);
bound = 8;
mask  = logical(ones(sides(1), sides(2)));
mask_bound = zeros(sides(1), sides(2));
mask_bound(bound:sides(1)-bound, bound:sides(2)-bound) = 1;
mask_bound = logical(mask_bound);
mask = mask & mask_bound;

for i=startIdx+temporalLength-1:endIdx
    cSeq(:,:,temporalLength) = read_sequence(dir, prefix, suffix, append0, i);
%    RidgeEstOF_Arch(cSeq, correct_flow, mask);
%    RidgeEstOF_Arch_Fix(cSeq, correct_flow, mask);
    RidgeEstOF_Arch_Fix_HW(cSeq, correct_flow, mask);
    cSeq(:,:,[1:temporalLength-1]) = cSeq(:, :, [2:temporalLength]);  %shift one frame
    if saveVideo == 1
        F = getframe;
        aviobj = addframe(aviobj, F);
    end;
end;

if saveVideo == 1	
	aviobj = close(aviobj);
end;

close all
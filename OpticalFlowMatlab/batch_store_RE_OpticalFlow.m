%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function is used to calculate the optical flow field for video
% sequence and store the calculated optical flow field.
% input:
%   startIdx: 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function batch_store_RE_OpticalFlow(startIdx, inputSeqIdx)

clc
disp('Start generate and store optical flow');
global certaintyFlag;
certaintyFlag = 1;
disp(['certaintyFlag ' int2str(certaintyFlag)]);

seqDir = 'E:\UGV Video\';               %video source directory
resultSeqDir = 'E:\UGV Video\Result\';  %result putting directory


%starting frame and lenght of the clip to be calculated
%inputSeqIdx = 1;
%startIdx = 1;
length = 100;

%algorithm configuration (fixed)
temporalLength = 7; %the least length of sequence that we could calculate one field of optical flow

switch inputSeqIdx
    case 0
        name  = '0obstacle0';  %Video name
        suffix= 'avi';      %Video suffix
    case 1
        name  = '0obstacle1';
        suffix= 'avi';
    case 2
        name  = '0obstacle2';
        suffix= 'avi';
    case 3
        name  = '1obstacle0';
        suffix= 'avi';
    case 4
        name  = '1obstacle1';
        suffix= 'avi';
    case 5
        name  = '2obstacle0';
        suffix= 'avi';
    case 6
        name  = '2obstacle1';
        suffix= 'avi';
    case 7
        name  = '2obstacle2';
        suffix= 'avi';
end;

filename = [seqDir name '.' suffix];
result_filename = [resultSeqDir name '_result_' num2str(startIdx) '_' num2str(startIdx+length) '.mat'];
disp(['Video file:' filename]);

fileinfo = aviinfo(filename);
width = fileinfo.Width;
height= fileinfo.Height;
correct_flow = [];
%mask to filter out the boundary
sides = [height, width];
bound = 8;
mask  = logical(ones(sides(1), sides(2)));
mask_bound = zeros(sides(1), sides(2));
mask_bound(bound:sides(1)-bound, bound:sides(2)-bound) = 1;
mask_bound = logical(mask_bound);
mask = mask & mask_bound;

video_clip = aviread(filename, startIdx:startIdx+temporalLength-2);
imgVolume = uint8(zeros([height width temporalLength-1]));
for i=1:temporalLength-1
    imgVolume(:,:,i) = rgb2gray(video_clip(i).cdata);
end;

for i=startIdx+temporalLength-1:startIdx+length
    try
        video_clip = aviread(filename, i);
    catch
        warning('No more frames');
        return;
    end;
    imgVolume(:,:,temporalLength) = rgb2gray(video_clip.cdata);
    [optical_flow, error1_r, error2_r, error3_r, std1_r, std2_r, std3_r] = RidgeEstOF_Arch_Fix_HW(imgVolume, correct_flow, mask);
    
    %F = getframe;
    %aviobj = addframe(aviobj, F);
    
    %save the motion field
    OF(:, :, :, i-(startIdx+temporalLength-1)+1) = optical_flow;
    imgVolume(:,:,1:end-1) = imgVolume(:,:,2:end);
    if (mod(i,20)==0)
        save(result_filename, 'OF');
    end;
end;

%This function is used to run simulation on the testing video.

function video_RE_OpticalFlow(directory, resultdirectory, filename)

fullfilename = [directory filename '.avi']; %reading avi!!!
temporalLength = 7; %Needs 7 frames to calculate one frame optical flow field
offset = 390;
length = 300;

try
    fileinfo = aviinfo(fullfilename);
catch
    error_message = lasterror;
    warning(error_message.message);
    return;
end;

resultfilename = [resultdirectory filename '_result_s.avi'];
aviobj = avifile(resultfilename, 'fps', 5, 'compression', 'none');

%get video information
width = fileinfo.Width;
height= fileinfo.Height;
nFrm = fileinfo.NumFrames;  %number of frames

correct_flow = [];
%mask to filter out the boundary
sides = [height, width];
bound = 8;
mask  = logical(ones(sides(1), sides(2)));
mask_bound = zeros(sides(1), sides(2));
mask_bound(bound:sides(1)-bound, bound:sides(2)-bound) = 1;
mask_bound = logical(mask_bound);
mask = mask & mask_bound;

video_clip = aviread(fullfilename, 1+offset:temporalLength-1+offset);
V = uint8(zeros([height width temporalLength-1]));
for i=1:temporalLength-1
    V(:,:,i) = rgb2gray(video_clip(i).cdata);
end;

for i=1+offset+1:1+offset+length
    try
        video_clip = aviread(fullfilename, i);
    catch
        warning('No more frames');
        return;
    end;
    V(:,:,temporalLength) = rgb2gray(video_clip.cdata);
    RidgeEstOF_Arch_Fix_HW(V, correct_flow, mask);
    
    F = getframe;
    aviobj = addframe(aviobj, F);
    V(:,:,1:end-1) = V(:,:,2:end);
end;

aviobj = close(aviobj);
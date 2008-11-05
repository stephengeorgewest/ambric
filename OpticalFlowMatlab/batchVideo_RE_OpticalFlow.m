%This function is used to run simulation on the testing video.

function batchVideo_RE_OpticalFlow(index)

directory = 'E:\UGV result\';
resultdirectory = 'E:\UGV result\';
for i=1:size(index, 2)
    filename = fetch_video_name(index(i));
    video_RE_OpticalFlow(directory, resultdirectory, filename);
end;
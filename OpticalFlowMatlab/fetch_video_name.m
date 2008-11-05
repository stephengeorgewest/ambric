%This is the name list of the video file

function [outfilename, totalnum] = fetch_video_name(i)

filename = [];
filename{end+1} = '20071002_1';     %1
filename{end+1} = '20071002_2';     %2
filename{end+1} = 'Landing 1(UAV)_output'; %3
filename{end+1} = 'Landing 2(UAV)_output'; %4
filename{end+1} = 'Landing 3(UAV)_output'; %5
filename{end+1} = 'Landing 4(UAV)_output'; %6
filename{end+1} = 'Landing 5(UAV)_output'; %7
filename{end+1} = 'Near Hit 1(UAV)_output';%8
filename{end+1} = 'Near Hit 2(UAV)_output';%9
filename{end+1} = 'Near Hit 3(UAV)_output';%10
filename{end+1} = 'Pass 1(UAV)_output';    %11
filename{end+1} = 'Pass 2(UAV)_output';    %12
filename{end+1} = 'Pass 3(UAV)_output';    %13
filename{end+1} = 'Pass 4(UAV) 01_output'; %14
filename{end+1} = 'Pass 5(UAV)_output';    %15
filename{end+1} = 'Take Off 2(UAV)_output';%16
filename{end+1} = 'Take Off 3(UAV)_output';%17
filename{end+1} = 'Take Off 4(UAV)_output';%18
filename{end+1} = 'Take Off 5(UAV)_output';%19
filename{end+1} = '0obstacle0';            %20
filename{end+1} = '0obstacle1';            %21
filename{end+1} = '0obstacle2';            %22
filename{end+1} = '1obstacle0';            %23
filename{end+1} = '1obstacle1';            %24
filename{end+1} = '1obstacle2';            %25
filename{end+1} = '2obstacle0';            %26
filename{end+1} = '2obstacle1';            %27 
filename{end+1} = '2obstacle2';            %28 
filename{end+1} = '3obstacle0';            %29
filename{end+1} = '3obstacle1';            %30



if (i==0)
    outfilename = [];
    totalnum = size(filename, 2);
else
    outfilename = filename{i};
    totalnum = size(filename, 2);
end;
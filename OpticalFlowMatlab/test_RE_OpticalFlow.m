%This is the top level function to test OF algorithm under different
%setting. Just for one frame test, is not for a batch processing.
function test_RE_OpticalFlow()

%clc
app1Size = 5;
app2Size = 3;
app3Size = 7;
bound = (app1Size - 1 + app2Size - 1 + app3Size - 1 + 4)/2;
[imageCube, mask, correct_flow] = read_yosemite(bound);
frameLength = 4 + app1Size; %The number of frames for calculating one frame.
%if (size(imageCube, 3)<frameLength)
%    error('Image sequence is not long enough!');
%end;

%for i=1:size(imageCube, 3)-frameLength+1
%    RidgeEstOF_Arch(imageCube(:,:,i:i+frameLength-1), correct_flow, app1Size, app2Size, app3Size);
%end;    
%ind1 = 1;
%ind2 = 1;
%ind3 = 1;
counter = 1;
i = 0.8;
j = 3.5;
k = 3.5;
%for i=0.1:0.1:2
i = 0.8;
%    for j=4.6:0.1:8
%       for k=4.6:0.1:8
            ind1 = int32((i - 0.8) / 0.1 + 1);
            ind2 = int32((j - 3.5) / 0.1 + 1);
            ind3 = int32((k - 3.5) / 0.1 + 1);
            disp(sprintf('***%d: ***', counter));
            disp(sprintf('index: sigma1:%2.3f, sigma2:%2.3f, sigma3:%2.3f', i, j, k));
            %[error1_r, error2_r, error3_r, std1_r, std2_r, std3_r] = RidgeEstOF_Arch(imageCube(:,:,3:15), correct_flow, mask, app1Size, app2Size, app3Size, i, j, k);
            
            %algorithm simulation
            %[error1_r, error2_r, error3_r, std1_r, std2_r, std3_r] = RidgeEstOF_Arch_Fix(imageCube(:,:,5:13), correct_flow, mask, i, j, k);
            
            %hardware simulation
            [V, error1_r, error2_r, error3_r, std1_r, std2_r, std3_r] = RidgeEstOF_Arch_Fix_HW(imageCube(:,:,5:13), correct_flow, mask);
            
            %[error1_r, error2_r, error3_r, std1_r, std2_r, std3_r] = RidgeEstOF_Arch_Fix(imageCube(:,:,3:15), correct_flow, mask);
            
            error1(ind1, ind2, ind3) = error1_r;
            error2(ind1, ind2, ind3) = error2_r;
            error3(ind1, ind2, ind3) = error3_r;
            std1(ind1, ind2, ind3)   = std1_r;
            std2(ind1, ind2, ind3)   = std2_r;
            std3(ind1, ind2, ind3)   = std3_r;
            counter = counter + 1;
            disp(' ');
%        end;
%    end;
%    save test5.mat
%end;

save test5.mat



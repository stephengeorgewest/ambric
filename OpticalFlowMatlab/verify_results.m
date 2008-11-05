%compare results of GPU vs. Matlab
clear all;
% 
% load('MATLAB_results/Gx0.mat');
% load('MATLAB_results/Gx1.mat');
% load('MATLAB_results/Gx2.mat');
% 
% load('GPU_results/x_results0.txt');
% load('GPU_results/x_results1.txt');
% load('GPU_results/x_results2.txt');
% 
% match0 = double(Gx0) - x_results0(3:238,3:350,:);
% match1 = double(Gx1) - x_results1(3:238,3:350,:);
% match2 = double(Gx2) - x_results2(3:238,3:350,:);

% 
% load('MATLAB_results/Gx_smooth.mat');
% load('MATLAB_results/Gy_smooth.mat');
% load('MATLAB_results/Gt_smooth.mat');
% 
% load('GPU_results/t_smoothed0.txt');
% load('GPU_results/t_smoothed1.txt');
% load('GPU_results/t_smoothed2.txt');
% 
% %these should result in arrays w/ values of +/-4
% match0 = double(Gx_smooth) - t_smoothed0(3:238,3:350,:);
% match1 = double(Gy_smooth) - t_smoothed1(3:238,3:350,:);
% match2 = double(Gt_smooth) - t_smoothed2(3:238,3:350,:);
% 
% load('MATLAB_results/conv1.mat');
% load('MATLAB_results/conv2.mat');
% load('MATLAB_results/conv3.mat');
% 
% load('GPU_results/y_conv0.txt');
% load('GPU_results/y_conv1.txt');
% load('GPU_results/y_conv2.txt');
% 
% %these should result in arrays w/ values of +/-16
% match0 = double(conv1) - y_conv0(5:236,5:348);
% match1 = double(conv2) - y_conv1(5:236,5:348);
% match2 = double(conv3) - y_conv2(5:236,5:348);
% 
% load('MATLAB_results/gxgx.mat');
% load('MATLAB_results/gxgy.mat');
% load('MATLAB_results/gxgt.mat');
% load('MATLAB_results/gygy.mat');
% load('MATLAB_results/gygt.mat');
% load('MATLAB_results/gtgt.mat');
% 
% load('GPU_results/smoothed_2nd0.txt');
% load('GPU_results/smoothed_2nd1.txt');
% load('GPU_results/smoothed_2nd2.txt');
% load('GPU_results/smoothed_2nd3.txt');
% load('GPU_results/smoothed_2nd4.txt');
% load('GPU_results/smoothed_2nd5.txt');
% 
% % %these should result in arrays w/ values of +49/-36
% match0 = double(gxgx) - smoothed_2nd0(5:236,5:348);
% match1 = double(gygy) - smoothed_2nd1(5:236,5:348);
% match2 = double(gtgt) - smoothed_2nd2(5:236,5:348);
% match3 = double(gxgy) - smoothed_2nd3(5:236,5:348);
% match4 = double(gxgt) - smoothed_2nd4(5:236,5:348);
% match5 = double(gygt) - smoothed_2nd5(5:236,5:348);


% 
% 
load('MATLAB_results/gxgxs.mat');
load('MATLAB_results/gxgys.mat');
load('MATLAB_results/gxgts.mat');
load('MATLAB_results/gygys.mat');
load('MATLAB_results/gygts.mat');
load('MATLAB_results/gtgts.mat');

load('GPU_results/y_conv2nd0.txt');
load('GPU_results/y_conv2nd1.txt');
load('GPU_results/y_conv2nd2.txt');
load('GPU_results/y_conv2nd3.txt');
load('GPU_results/y_conv2nd4.txt');
load('GPU_results/y_conv2nd5.txt');
 

y_conv2nd0 = y_conv2nd0(6:235,6:347);
y_conv2nd1 = y_conv2nd1(6:235,6:347);
y_conv2nd2 = y_conv2nd2(6:235,6:347);
y_conv2nd3 = y_conv2nd3(6:235,6:347);
y_conv2nd4 = y_conv2nd4(6:235,6:347);
y_conv2nd5 = y_conv2nd5(6:235,6:347);

match0 = double(gxgxs) - y_conv2nd0;
match1 = double(gygys) - y_conv2nd1;
match2 = double(gtgts) - y_conv2nd2;
match3 = double(gxgys) - y_conv2nd3;
match4 = double(gxgts) - y_conv2nd4;
match5 = double(gygts) - y_conv2nd5;


% load('GPU_results/vx.txt');
% load('GPU_results/vy.txt');
% load('MATLAB_results/Vx_m.mat');
% load('MATLAB_results/Vy_m.mat');
% 
% a = vx(140,34);
% b = Vx(135,29);
% 
% vx = vx(6:235,6:347);
% vy = vy(6:235,6:347);
% 
% match0 = Vx - vx;
% match1 = Vy - vy;
% 
% 
% load('GPU_results/vx_sm.txt');
% load('GPU_results/vy_sm.txt');
% load('MATLAB_results/Vx_sm.mat');
% load('MATLAB_results/Vy_sm.mat');
% 
% vx_sm = vx_sm(9:232,9:344);
% vy_sm = vy_sm(9:232,9:344);
% 
% match2 = Vx_s - vx_sm;
% match3 = Vy_s - vy_sm;
% 
% mean0 = mean(mean(match0));
% mean1 = mean(mean(match1));
% 
% 
% mean2 = mean(mean(match2));
% mean3 = mean(mean(match3));



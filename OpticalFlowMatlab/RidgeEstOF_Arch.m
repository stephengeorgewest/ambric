%V.1.0
%This function is the functional simulation of New Optical Flow
%Estimation algorithm.
%Written by: Zhaoyi (Roger) Wei @ ECEN, BYU
%    July. 29, 2007

function [error1_r, error2_r, error3_r, std1_r, std2_r, std3_r] = RidgeEstOF_Arch(sequence, correctFlow, mask)


%%%%%%%%Parameters Setting%%%%%%%%%
dMask = [-1 8 0 -8 1]./12;  %differentiate mask
dMaskSize = size(dMask, 2);
hfDMaskSize = (size(dMask, 2)-1)/2;
%first smoothing mask parameter
app1Size = 5;
app1Sigma= 2.1; 
hfApp1Size = (app1Size-1)/2;
app1Dist = (-hfApp1Size:hfApp1Size).^2;
app1Dist = app1Dist / (hfApp1Size^2);
app1Mask = exp(-app1Dist./(app1Sigma^2));
app1Mask = app1Mask ./ sum(app1Mask(:));
%Second smoothing mask parameter
app2Size = 7;
app2Sigma= 2.5;
hfApp2Size = (app2Size-1)/2;
app2Dist = (-hfApp2Size:hfApp2Size).^2;
app2Dist = app2Dist / (hfApp2Size^2);
app2Mask = exp(-app2Dist./(app2Sigma^2));
app2Mask = app2Mask ./ sum(app2Mask(:));
%Third smoothing mask parameter
app3Size = 7;
app3Sigma= 2.1;
hfApp3Size = (app3Size-1)/2;
app3Dist = (-hfApp3Size:hfApp3Size).^2;
app3Dist = app3Dist / (hfApp3Size^2);
app3Mask = exp(-app3Dist./(app3Sigma^2));
app3Mask = app3Mask ./ sum(app3Mask(:));
%k calculation parameter
p = 2;
n = app2Size^2;
%Optical Flow Field Display Settting
displayFlag = 0; %1; %0 for not display
displayGridSize= 8;%vector field density

%%%%%%%%1. Read image sequence%%%%%%%%
%[sequence, correctFlow] = read_yosemite;
correctFlowFlag = (~ isempty(correctFlow));
sizeX = size(sequence, 2);
sizeY = size(sequence, 1);

%%%%%%%%2. Calculate the Derivatives%%%%%%%%
Gx = zeros(sizeY-2*hfDMaskSize, sizeX-2*hfDMaskSize, app1Size);
Gy = zeros(sizeY-2*hfDMaskSize, sizeX-2*hfDMaskSize, app1Size);
Gt = zeros(sizeY-2*hfDMaskSize, sizeX-2*hfDMaskSize, app1Size);

Gx2 = zeros(sizeY-2*hfDMaskSize, sizeX-2*hfDMaskSize, app1Size);
Gy2 = zeros(sizeY-2*hfDMaskSize, sizeX-2*hfDMaskSize, app1Size);
Gt2 = zeros(sizeY-2*hfDMaskSize, sizeX-2*hfDMaskSize, app1Size);

%for t=-hfApp1Size:hfApp1Size
%     for i=-hfDMaskSize:hfDMaskSize
%         Gx(:,:,t+hfApp1Size+1) = Gx(:,:, t+hfApp1Size+1) + squeeze(sequence(1+hfDMaskSize:sizeY-hfDMaskSize, i+hfDMaskSize+1:sizeX-hfDMaskSize+i, t+hfApp1Size+1)).*dMask(i+hfDMaskSize+1);
%         Gy(:,:,t+hfApp1Size+1) = Gy(:,:, t+hfApp1Size+1) + squeeze(sequence(i+hfDMaskSize+1:sizeY-hfDMaskSize+i, 1+hfDMaskSize:sizeX-hfDMaskSize, t+hfApp1Size+1)).*dMask(i+hfDMaskSize+1);
%         Gt(:,:,t+hfApp1Size+1) = Gt(:,:, t+hfApp1Size+1) + squeeze(sequence(1+hfDMaskSize:sizeY-hfDMaskSize, 1+hfDMaskSize:sizeX-hfDMaskSize, t+hfApp1Size+1+i+hfApp1Size)).*dMask(i+hfDMaskSize+1);
%     end;
% end;
m_frame = round((size(sequence, 3)+1)/2); %middle frame
for t = 1:3%app1Size
    for i=-hfDMaskSize:hfDMaskSize
        Gx(:,:,t) = Gx(:,:,t) + squeeze(sequence(1+hfDMaskSize:sizeY-hfDMaskSize,     i+hfDMaskSize+1:sizeX-hfDMaskSize+i, hfDMaskSize+t))  *dMask(i+hfDMaskSize+1);
        Gy(:,:,t) = Gy(:,:,t) + squeeze(sequence(i+hfDMaskSize+1:sizeY-hfDMaskSize+i, 1+hfDMaskSize:sizeX-hfDMaskSize,     hfDMaskSize+t))  *dMask(i+hfDMaskSize+1);
        Gt(:,:,t) = Gt(:,:,t) + squeeze(sequence(1+hfDMaskSize:sizeY-hfDMaskSize,     1+hfDMaskSize:sizeX-hfDMaskSize,     hfDMaskSize+t+i))*dMask(i+hfDMaskSize+1);
    end;
end;

% for j = 1+hfDMaskSize:sizeX-hfDMaskSize    %frame number
%     for i = 1+hfDMaskSize:sizeY-hfDMaskSize
%         for k = -hfApp1Size:hfApp1Size
%             Gx2(i, j, k+hfApp1Size+1) = (reshape(sequence(i-hfDMaskSize:i+hfDMaskSize, j, k+m_frame), 1, 5)*dMask');
%             Gy2(i, j, k+hfApp1Size+1) = (sequence(i, j-hfDMaskSize:j+hfDMaskSize, k+m_frame)*dMask');
%             Gt2(i, j, k+hfApp1Size+1) = (reshape(sequence(i, j, k-hfDMaskSize+m_frame:k+hfDMaskSize+m_frame), 1, 5)*dMask');
%         end;
%     end;
% end;

%%%%%%%%3. Smooth the derivatives%%%%%%%%
%Using Temporal Smoothing
Gx_s = Fast3DConv(Gx, app1Mask);
Gy_s = Fast3DConv(Gy, app1Mask);
Gt_s = Fast3DConv(Gt, app1Mask);

%%%%%%%%4. Smooth the 2nd order term%%%%%%%%
GxGx = Gx_s.*Gx_s;
GyGy = Gy_s.*Gy_s;
GtGt = Gt_s.*Gt_s;
GxGy = Gx_s.*Gy_s;
GxGt = Gx_s.*Gt_s;
GyGt = Gy_s.*Gt_s;
 
GxGx_s = Fast2DConv(GxGx, app2Mask);
GyGy_s = Fast2DConv(GyGy, app2Mask);
GtGt_s = Fast2DConv(GtGt, app2Mask);
GxGy_s = Fast2DConv(GxGy, app2Mask);
GxGt_s = Fast2DConv(GxGt, app2Mask);
GyGt_s = Fast2DConv(GyGt, app2Mask);

%%%%%%%%5. Get the Ridge Estimator for each pixel%%%%%%%%
sizeVx = size(GxGx_s, 2);
sizeVy = size(GxGx_s, 1);

for i=1:sizeVy
    %for the first pixel one each row, k=0
    gxx = GxGx_s(i,1);
    gyy = GyGy_s(i,1);
    gxy = GxGy_s(i,1);
    gxt = GxGt_s(i,1);
    gyt = GyGt_s(i,1);
    [vx_l, vy_l] = VelocityCalc(gxx, gyy, gxy, gxt, gyt);
    Vx(i, 1) = vx_l;
    Vy(i, 1) = vy_l;
    Kr(i, 1) = 0;
    for j=2:sizeVx
        if (i==5 && j==21)
            a = 1;
        end;
        gxx = GxGx_s(i,j);
        gyy = GyGy_s(i,j);
        gtt = GtGt_s(i,j);
        gxy = GxGy_s(i,j);
        gxt = GxGt_s(i,j);
        gyt = GyGt_s(i,j);
        if ((vx_l^2+vy_l^2)==0)
            a = 1;
        end;
        %k = 0;
        if (gxx*gyy-gxy^2<0.1)
           k = (p/(n-p))*(gtt-2*gxt*vx_l-2*gyt*vy_l+gxx*vx_l*vx_l+2*gxy*vx_l*vy_l+gyy*vy_l*vy_l)/16;
        else
            k = 0;
        end;
        Kr(i,j) = k;
        gxx_n = gxx + k;
        gyy_n = gyy + k;
        [vx_l, vy_l] = VelocityCalc(gxx_n, gyy_n, gxy, gxt, gyt);
        Vx(i, j) = vx_l;
        Vy(i, j) = vy_l;
    end;
end;

%%%%%%%%7. Smooth the velocity field%%%%%%%%
Vx_s = Fast2DConv(Vx, app3Mask);
Vy_s = Fast2DConv(Vy, app3Mask);
V = zeros(sizeY, sizeX, 2);

%save Vx_new.mat Vx_s;
%save Vy_new.mat Vy_s;
%%%%%%%%8. Estimate the accuracy if there's any%%%%%%%%
boundSize = hfDMaskSize+hfApp1Size+hfApp2Size+hfApp3Size;
if (correctFlowFlag)
    %padded with zeros along the boundry
    V(boundSize+1:end-boundSize, boundSize+1:end-boundSize, 1) = -Vy_s;
    V(boundSize+1:end-boundSize, boundSize+1:end-boundSize, 2) = -Vx_s;
    boundMask = zeros(sizeY, sizeX);
    boundMask(boundSize+1:end-boundSize, boundSize+1:end-boundSize) = 1;
    boundMask = logical(boundMask);
    [error1_r, error2_r, error3_r, std1_r, std2_r, std3_r] = evaluate_velocity(V, correctFlow, mask);
end;

%%%%%%%%9. Draw the velocity field if needed%%%%%%%%
if (displayFlag==1)
    figure;
    imshow(sequence(:,:,6)./255);
    [x,y] = meshgrid(1+boundSize:displayGridSize:sizeX-boundSize,1+boundSize:displayGridSize:sizeY-boundSize);
    sizeX_VxVy = size(Vx_s, 2);
    sizeY_VxVy = size(Vy_s, 1);
    xflow = V(1:displayGridSize:sizeY_VxVy,1:displayGridSize:sizeX_VxVy,1);
    yflow = V(1:displayGridSize:sizeY_VxVy,1:displayGridSize:sizeX_VxVy,2);
    hold on, quiver(x, y, yflow, xflow, 3, 'r');
    hold off
end;

% This function calculates the 2D convolution for one frame
% Mask is the 1D profile of the 2D mask
function conv2DImage = Fast2DConv(image, mask)
sizeX = size(image, 2);
sizeY = size(image, 1);
if (size(mask, 2)==1)
    mask = mask';
end;
if (size(mask, 2)>sizeX || size(mask, 2)>sizeY)
    warning('Mask size is too big!');
    exit;
end;
hMaskSize = (size(mask, 2)-1)/2;
maskSize  = (size(mask, 2));
sumTemp1 = zeros(sizeY, sizeX-2*hMaskSize);
sumTemp2 = zeros(sizeY-2*hMaskSize, sizeX-2*hMaskSize);

%Convolution along X
for i=1:maskSize
    sumTemp1 = sumTemp1 + image(1:end, i:i+sizeX-maskSize)*mask(i);
end;
%Convolution along Y
for i=1:maskSize
    sumTemp2 = sumTemp2 + sumTemp1(i:i+sizeY-maskSize, 1:end)*mask(i);
end;
conv2DImage = sumTemp2;

% This function calculates the 3D convolution for one frame
% Mask is the 1D profile of the 3D mask
function conv3DImage = Fast3DConv(imgVolume, mask)
sizeX = size(imgVolume, 2);
sizeY = size(imgVolume, 1);
sizeT = size(imgVolume, 3);
if (size(mask, 2)==1)
    mask = mask';
end;
if (sizeT>size(mask,2))
    warning('Image frames are larger than mask size');
elseif (sizeT<size(mask,2))
    warning('Image frames are smaller than mask size');
    exit;
end;
if (size(mask, 2)>sizeX || size(mask, 2)>sizeY || size(mask, 2)>sizeT)
    warning('Mask size is too big!');
    exit;
end;
maskSize  = size(mask, 2);
hMaskSize = (size(mask, 2)+1)/2;

sumTemp1 = zeros(sizeY, sizeX);
%Convolution along T
for i=1:maskSize
    sumTemp1 = sumTemp1 + imgVolume(1:end, 1:end, i)*mask(i);
end;
conv3DImage = Fast2DConv(sumTemp1, mask);

%The function for calculating velocity
function [vx, vy] = VelocityCalc(gxx, gyy, gxy, gxt, gyt)
vx_dividend = gxt*gyy-gxy*gyt;
vy_dividend = gxx*gyt-gxy*gxt;
if (vx_dividend==0 && vy_dividend==0)
    a = 1;
end;
divisor     = gxx*gyy-gxy*gxy;
vx = vx_dividend/(divisor+0.000001);
vy = vy_dividend/(divisor+0.000001);

if (vx==0 && vy==0)
    a = 1;
end;

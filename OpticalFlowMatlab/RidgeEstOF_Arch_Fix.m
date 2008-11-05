%This function is used to evaluate algorithm performance.
%The parameters here might not be the same as those 
%in the hardware (very likely different...)
%
% Zhaoyi Wei
% 2/12/2008
function [error1_r, error2_r, error3_r, std1_r, std2_r, std3_r] = RidgeEstOF_Arch_Fix(sequence, correctFlow, mask, app1Sigma, app2Sigma, app3Sigma)

displayFlag = 0;

%%%%%%Fixed point format configurations%%%%%%%
%DMASK_INT = 1;
%DMASK_FRAC=15;
MASK_INT = 5;
MASK_FRAC= 11;
%derivative fixed point format
G_INT = 8;
G_FRAC= 0;
%1st smooth fixed point format
S1_INT = 5;
S1_FRAC= 4;
%2nd smooth fixed point format
S2_INT = 5;
S2_FRAC= 6;

%%%%%%Smoothing window configurations%%%%%%%
%Window size is fixed, but the sigma is not
spatialApp1Size = 7;
temporalApp1Size= 3;
app2Size = 5;
app3Size = 3;
app1Sigma= 0.8;
app2Sigma= 3.5;
app3Sigma= 3.5;

%derivative mask setting
Dtemp = [-1 8 0 -8 1]; %eliminate the 1/12
%sizeD = size(Dtemp,2);     %template size
%Dtemp_fix = Convert2FixNum(Dtemp, 3, 13);
dTempSize = size(Dtemp, 2);
hfDMaskSize = (size(Dtemp, 2)-1)/2;
% for i=1:dTempSize
%     Dtemp_f(i) = Convert2FixNum(Dtemp(i), DMASK_INT, DMASK_FRAC);
% end;
Dtemp_f = ConvertMask2FixNum(Dtemp, MASK_INT, MASK_FRAC);
%first spatial smoothing mask parameter
hfSpatialApp1Size = (spatialApp1Size-1)/2;
app1SDist = (-hfSpatialApp1Size:hfSpatialApp1Size).^2;
app1SDist = app1SDist / (hfSpatialApp1Size^2);
app1SpatialMask = exp(-app1SDist./(app1Sigma^2));
app1SpatialMask = app1SpatialMask ./ sum(app1SpatialMask(:));
app1SpatialMask_f = ConvertMask2FixNum(app1SpatialMask, MASK_INT, MASK_FRAC);
%first temporal smoothing mask parameter
hfTemporalApp1Size = (temporalApp1Size-1)/2;
app1TDist = (-hfTemporalApp1Size:hfTemporalApp1Size).^2;
app1TDist = app1TDist / (hfTemporalApp1Size^2);
app1TemporalMask = exp(-app1TDist./(app1Sigma^2));
app1TemporalMask = app1TemporalMask ./ sum(app1TemporalMask(:));
app1TemporalMask_f = ConvertMask2FixNum(app1TemporalMask, MASK_INT, MASK_FRAC);
%app1TemporalMask_f = app1SpatialMask_f;
%second smoothing mask parameter
hfApp2Size = (app2Size-1)/2;
app2Dist = (-hfApp2Size:hfApp2Size).^2;
app2Dist = app2Dist / (hfApp2Size^2);
app2Mask = exp(-app2Dist./(app2Sigma^2));
app2Mask = app2Mask ./ sum(app2Mask(:));
app2Mask_f = ConvertMask2FixNum(app2Mask, MASK_INT, MASK_FRAC);
%Third smoothing mask parameter
%app3Size = 7;
%app3Sigma= 2.1;
hfApp3Size = (app3Size-1)/2;
app3Dist = (-hfApp3Size:hfApp3Size).^2;
app3Dist = app3Dist / (hfApp3Size^2);
app3Mask = exp(-app3Dist./(app3Sigma^2));
app3Mask = app3Mask ./ sum(app3Mask(:));
app3Mask_f = ConvertMask2FixNum(app3Mask, MASK_INT, MASK_FRAC);

%%%%%%%%1. Read image sequence%%%%%%%%
correctFlowFlag = (~ isempty(correctFlow));
sizeX = size(sequence, 2);
sizeY = size(sequence, 1);

%%%%%%%%2. Calculate the Derivatives%%%%%%%%
GxR = int32(zeros(sizeY-2*hfDMaskSize, sizeX-2*hfDMaskSize, temporalApp1Size));
GyR = int32(zeros(sizeY-2*hfDMaskSize, sizeX-2*hfDMaskSize, temporalApp1Size));
GtR = int32(zeros(sizeY-2*hfDMaskSize, sizeX-2*hfDMaskSize, temporalApp1Size));
Gx = int32(zeros(sizeY-2*hfDMaskSize, sizeX-2*hfDMaskSize, temporalApp1Size));
Gy = int32(zeros(sizeY-2*hfDMaskSize, sizeX-2*hfDMaskSize, temporalApp1Size));
Gt = int32(zeros(sizeY-2*hfDMaskSize, sizeX-2*hfDMaskSize, temporalApp1Size));

strG.int_bits = 8;
strG.frac_bits= 0;
m_frame = round((size(sequence, 3)+1)/2); %middle frame
for t = 1:temporalApp1Size
    for i=-hfDMaskSize:hfDMaskSize
        sliceGx = squeeze(sequence(1+hfDMaskSize:sizeY-hfDMaskSize, i+hfDMaskSize+1:sizeX-hfDMaskSize+i, hfDMaskSize+t));
        strG.number = sliceGx;
        rst = FixMultiply(strG, Dtemp_f(i+hfDMaskSize+1), G_INT, G_FRAC);
        GxR(:,:,t) = GxR(:,:,t) + rst.number;
        
        sliceGy = squeeze(sequence(i+hfDMaskSize+1:sizeY-hfDMaskSize+i, 1+hfDMaskSize:sizeX-hfDMaskSize, hfDMaskSize+t));
        strG.number = sliceGy;
        rst = FixMultiply(strG, Dtemp_f(i+hfDMaskSize+1), G_INT, G_FRAC);
        GyR(:,:,t) = GyR(:,:,t) + rst.number;
        
        sliceGt = squeeze(sequence(1+hfDMaskSize:sizeY-hfDMaskSize, 1+hfDMaskSize:sizeX-hfDMaskSize, hfDMaskSize+t+i));
        strG.number = sliceGt;
        rst = FixMultiply(strG, Dtemp_f(i+hfDMaskSize+1), G_INT, G_FRAC);
        GtR(:,:,t) = GtR(:,:,t) + rst.number;
    end;
end;

%shrink the bit width to 8 bits
ScaleFactor = 8;
Gx = int32(GxR./ScaleFactor);
Gy = int32(GyR./ScaleFactor);
Gt = int32(GtR./ScaleFactor);
GxPosInd = find(Gx>=127);
Gx(GxPosInd) = 127;
GxNegInd = find(Gx<=-127);
Gx(GxNegInd) = -127;

GyPosInd = find(Gy>=127);
Gy(GyPosInd) = 127;
GyNegInd = find(Gy<=-127);
Gx(GyNegInd) = -127;

GtPosInd = find(Gt>=127);
Gt(GtPosInd) = 127;
GtNegInd = find(Gt<=-127);
Gt(GtNegInd) = -127;

Gx_f.number = Gx;
Gy_f.number = Gy;
Gt_f.number = Gt;
Gx_f.int_bits = G_INT;
Gy_f.int_bits = G_INT;
Gt_f.int_bits = G_INT;
Gx_f.frac_bits= G_FRAC;
Gy_f.frac_bits= G_FRAC;
Gt_f.frac_bits= G_FRAC;

%%%%%%%%3. Smooth the derivatives%%%%%%%%
%Using Temporal Smoothing
Gx_s = Fast3DConv_f(Gx_f, app1SpatialMask_f, app1TemporalMask_f, S1_INT, S1_FRAC);
Gy_s = Fast3DConv_f(Gy_f, app1SpatialMask_f, app1TemporalMask_f, S1_INT, S1_FRAC);
Gt_s = Fast3DConv_f(Gt_f, app1SpatialMask_f, app1TemporalMask_f, S1_INT, S1_FRAC);

%%%%%%%%4. Smooth the 2nd order term%%%%%%%%
GxGx = FixMultiply(Gx_s, Gx_s, S1_INT, S1_FRAC);
GyGy = FixMultiply(Gy_s, Gy_s, S1_INT, S1_FRAC);
GtGt = FixMultiply(Gt_s, Gt_s, S1_INT, S1_FRAC);
GxGy = FixMultiply(Gx_s, Gy_s, S1_INT, S1_FRAC);
GxGt = FixMultiply(Gx_s, Gt_s, S1_INT, S1_FRAC);
GyGt = FixMultiply(Gy_s, Gt_s, S1_INT, S1_FRAC);

GxGx_s = Fast2DConv_f(GxGx, app2Mask_f, S2_INT, S2_FRAC);
GyGy_s = Fast2DConv_f(GyGy, app2Mask_f, S2_INT, S2_FRAC);
GtGt_s = Fast2DConv_f(GtGt, app2Mask_f, S2_INT, S2_FRAC);
GxGy_s = Fast2DConv_f(GxGy, app2Mask_f, S2_INT, S2_FRAC);
GxGt_s = Fast2DConv_f(GxGt, app2Mask_f, S2_INT, S2_FRAC);
GyGt_s = Fast2DConv_f(GyGt, app2Mask_f, S2_INT, S2_FRAC);

%%%%%%%%5. Get the Ridge Estimator for each pixel%%%%%%%%
sizeVx = size(GxGx_s.number, 2);
sizeVy = size(GxGx_s.number, 1);
scale_fac = 2.0^S2_FRAC;
p = 2;
n = app2Size^2;

for i=1:sizeVy
    %for the first pixel one each row, k=0
    gxx = double(GxGx_s.number(i,1)) / scale_fac;
    gyy = double(GyGy_s.number(i,1)) / scale_fac;
    gxy = double(GxGy_s.number(i,1)) / scale_fac;
    gxt = double(GxGt_s.number(i,1)) / scale_fac;
    gyt = double(GyGt_s.number(i,1)) / scale_fac;
    [vx_l, vy_l] = VelocityCalc(gxx, gyy, gxy, gxt, gyt);
    Vx(i, 1) = vx_l;
    Vy(i, 1) = vy_l;
    Kr(i, 1) = 0;
    for j=2:sizeVx
        % if (i==5 && j==21)
        %    a = 1;
        % end;
        gxx = double(GxGx_s.number(i,j)) / scale_fac;
        gyy = double(GyGy_s.number(i,j)) / scale_fac;
        gxy = double(GxGy_s.number(i,j)) / scale_fac;
        gxt = double(GxGt_s.number(i,j)) / scale_fac;
        gyt = double(GyGt_s.number(i,j)) / scale_fac;
        gtt = double(GtGt_s.number(i,j)) / scale_fac;
        if ((vx_l^2+vy_l^2)==0)
            a = 1;
        end;
        k = 0;
        %if (gxx*gyy-gxy^2<0.1)
        %   k = (p/(n-p))*(gtt-2*gxt*vx_l-2*gyt*vy_l+gxx*vx_l*vx_l+2*gxy*vx_l*vy_l+gyy*vy_l*vy_l)/16;
        %else
        %    k = 0;
        %end;
        Kr(i,j) = k;
        gxx_n = gxx + k;
        gyy_n = gyy + k;
        [vx_l, vy_l] = VelocityCalc(gxx_n, gyy_n, gxy, gxt, gyt);
        if (vx_l>10)
            vx_l = 10;
        elseif (vx_l<-10)
            vx_l = -10;
        end;
        if (vy_l>10) 
            vy_l = 10;
        elseif (vy_l<-10)
            vy_l = -10;
        end;
        Vx(i, j) = vx_l;
        Vy(i, j) = vy_l;
    end;
end;

%%%%%%%%7. Smooth the velocity field%%%%%%%%
Vx_s = Fast2DConv(Vx, app3Mask);
Vy_s = Fast2DConv(Vy, app3Mask);
V = zeros(sizeY, sizeX, 2);

%%%%%%%%8. Estimate the accuracy if there's any%%%%%%%%
boundSize = hfDMaskSize+hfSpatialApp1Size+hfApp2Size+hfApp3Size;
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Sub functions%%%%%%%%%%%%%%%%%%%%%%%%%%
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

% This function calculates the 2D convolution for one frame in fixed point
% Mask is the 1D profile of the 2D mask
function conv2DImage = Fast2DConv_f(image, mask, int_bits, frac_bits)
sizeX = size(image.number, 2);
sizeY = size(image.number, 1);
if (size(mask, 2)==1)
    mask = mask';
end;
if (size(mask, 2)>sizeX || size(mask, 2)>sizeY)
    warning('Mask size is too big!');
    exit;
end;
hMaskSize = (size(mask, 2)-1)/2;
maskSize  = (size(mask, 2));
sumTemp1.number = int32(zeros(sizeY, sizeX-2*hMaskSize));
sumTemp1.int_bits = int_bits;
sumTemp1.frac_bits= frac_bits;
sumTemp2.number = int32(zeros(sizeY-2*hMaskSize, sizeX-2*hMaskSize));
sumTemp2.int_bits = int_bits;
sumTemp2.frac_bits= frac_bits;

%Convolution along X
for i=1:maskSize
    tempImg.number = image.number(1:end, i:i+sizeX-maskSize);
    tempImg.int_bits = image.int_bits;
    tempImg.frac_bits= image.frac_bits;
    %tempMask.number= mask
    rst = FixMultiply(tempImg, mask(i), int_bits, frac_bits);
    sumTemp1.number = sumTemp1.number + rst.number;
end;
%Convolution along Y
for i=1:maskSize
    tempImg.number = sumTemp1.number(i:i+sizeY-maskSize, 1:end);
    tempImg.int_bits = image.int_bits;
    tempImg.frac_bits= image.frac_bits;
    rst = FixMultiply(tempImg, mask(i), int_bits, frac_bits);%*mask(i);
    sumTemp2.number = sumTemp2.number + rst.number;
end;
sumTemp2.int_bits = int_bits;
sumTemp2.frac_bits= frac_bits;
conv2DImage = sumTemp2;

% This function calculates the 3D convolution for one frame in fixed point
% maskS is the spatial smoothing mask
% maskT is the temporal smoothing mask
function conv3DImage = Fast3DConv_f(imgVolume, maskS, maskT, int_bits, frac_bits)
sizeX = size(imgVolume.number, 2);
sizeY = size(imgVolume.number, 1);
sizeT = size(imgVolume.number, 3);
if (size(maskT, 2)==1)
    maskT = maskT';
end;
if (size(maskS, 2)==1)
    maskS = maskS';
end;

if (sizeT>size(maskT,2))
    warning('Image frames are larger than mask size');
elseif (sizeT<size(maskT,2))
    warning('Image frames are smaller than mask size');
    exit;
end;
if (size(maskS, 2)>sizeX || size(maskS, 2)>sizeY)
    warning('Mask size is too big!');
    exit;
end;
maskTSize  = size(maskT, 2);
%hMaskTSize = (size(maskT, 2)+1)/2;

sumTemp1.number = int32(zeros(sizeY, sizeX));
sumTemp1.int_bits = int_bits;
sumTemp1.frac_bits= frac_bits;
%Convolution along T
for i=1:maskTSize
    tempImg.number = imgVolume.number(1:end, 1:end, i);
    tempImg.int_bits = imgVolume.int_bits;
    tempImg.frac_bits= imgVolume.frac_bits;
    rst = FixMultiply(tempImg, maskT(i), int_bits, frac_bits);
    sumTemp1.number = sumTemp1.number + rst.number;
end;
conv3DImage = Fast2DConv_f(sumTemp1, maskS, int_bits, frac_bits);

%The function for calculating velocity
function [vx, vy] = VelocityCalc(gxx, gyy, gxy, gxt, gyt)
vx_dividend = gxt*gyy-gxy*gyt;
vy_dividend = gxx*gyt-gxy*gxt;
if (vx_dividend==0 && vy_dividend==0)
    a = 1;
end;
divisor = gxx*gyy-gxy*gxy;
vx = vx_dividend/(divisor+0.000001);
vy = vy_dividend/(divisor+0.000001);

if (vx==0 && vy==0)
    a = 1;
end;
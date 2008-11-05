%This function is used to evaluate hardware algorithm performance.
%The parameters here are the same as those in the hardware. No matter how
%many frames are there in the sequence. The center frame is grabbed and
%calculated. And the middle frame optical flow is plotted if displayFlag is
%set.
%
% Zhaoyi Wei
% 2/12/2008
function [V, error1_r, error2_r, error3_r, std1_r, std2_r, std3_r] = RidgeEstOF_Arch_Fix_HW(sequence, correctFlow, mask)

john_test = 1; % if this is 1, GPU results used in accuracy calculation.  Otherwise, Matlab results used.
displayFlag = 1;
displayGridSize = 8;
global certaintyFlag;
%%%%%%Fixed point format configurations%%%%%%%
%DMASK_INT = 1;
%DMASK_FRAC=15;
MASK_INT = 5;
MASK_FRAC= 11;
%derivative fixed point format
G_INT = 8;
G_FRAC= 0;
%1st temporal smooth fixed point format
S1T_INT = 8;
S1T_FRAC= 1;
%1st smooth fixed point format
S1S1_INT = 10;
S1S1_FRAC= 2;
S1S2_INT = 10;
S1S2_FRAC= 2;
%scale factor in tensor construction
ST_INT = 8;
ST_FRAC = 10;
%2nd smooth fixed point format
S21_INT = 10;
S21_FRAC= 3;
S22_INT = 10;
S22_FRAC= 3;

%%%%%%Smoothing window configurations%%%%%%%
%Window size is fixed, but the sigma is not
spatialApp1Size = 5;
temporalApp1Size= 3;
app2Size = 3;
app3Size = 7;

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

%%%%%%%%%%%%%%%%%first spatial smoothing mask parameter%%%%%%%%%%%%%%%%%%%
hfSpatialApp1Size = (spatialApp1Size-1)/2;
app1SpatialMask = [3 3 4 3 3];
app1SpatialMask_f = ConvertMask2FixNum(app1SpatialMask, 4, 0);
%%%%%%%%%%%%%%%%%first temporal smoothing mask parameter%%%%%%%%%%%%%%%%%%%
hfTemporalApp1Size = (temporalApp1Size-1)/2;
app1TemporalMask = [2 4 2];
%app1TemporalMask = [0 8 0];  %no temporal smoothing
%app1TemporalMask = 8;
app1TemporalMask_f = ConvertMask2FixNum(app1TemporalMask, 4, 0);


%%%%%%%%%%%%%%%%%%second smoothing mask parameter%%%%%%%%%%%%%%%%%%%%%%%%%%
hfApp2Size = (app2Size-1)/2;
%app2Mask = [3 3 4 3 3];
app2Mask = [5 6 5];
app2Mask_f = ConvertMask2FixNum(app2Mask, 4, 0);

%%%%%%%%%%%%%%%%%%Third smoothing mask parameter%%%%%%%%%%%%%%%%%%%%%%%%%%%
hfApp3Size = (app3Size-1)/2;
app3Mask = [1 1 1 2 1 1 1]/8;
%app3Mask = [3 3 4 3 3]/16;
app3Mask_f = ConvertMask2FixNum(app3Mask, MASK_INT, MASK_FRAC);

%%%%%%%%1. Read image sequence%%%%%%%%
correctFlowFlag = (~ isempty(correctFlow));
maskFlag = ( isempty(mask));
sizeX = size(sequence, 2);
sizeY = size(sequence, 1);
sizeT = size(sequence, 3);

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
GxNegInd = find(Gx<=-128);
Gx(GxNegInd) = -127;

GyPosInd = find(Gy>=127);
Gy(GyPosInd) = 127;
GyNegInd = find(Gy<=-128);
Gy(GyNegInd) = -127;

GtPosInd = find(Gt>=127);
Gt(GtPosInd) = 127;
GtNegInd = find(Gt<=-128);
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
Gx_s = Fast3DConv_f(Gx_f, app1SpatialMask_f, app1TemporalMask_f, S1T_INT, S1T_FRAC, S1S1_INT, S1S1_FRAC, S1S2_INT, S1S2_FRAC);
Gy_s = Fast3DConv_f(Gy_f, app1SpatialMask_f, app1TemporalMask_f, S1T_INT, S1T_FRAC, S1S1_INT, S1S1_FRAC, S1S2_INT, S1S2_FRAC);
Gt_s = Fast3DConv_f(Gt_f, app1SpatialMask_f, app1TemporalMask_f, S1T_INT, S1T_FRAC, S1S1_INT, S1S1_FRAC, S1S2_INT, S1S2_FRAC);

%%%%%%%%4. Smooth the 2nd order term%%%%%%%%
GxGx.number = Gx_s.number.*Gx_s.number; %FixMultiply(Gx_s, Gx_s, S21_INT, S21_FRAC);
GyGy.number = Gy_s.number.*Gy_s.number; %FixMultiply(Gy_s, Gy_s, S21_INT, S21_FRAC);
GtGt.number = Gt_s.number.*Gt_s.number; %FixMultiply(Gt_s, Gt_s, S21_INT, S21_FRAC);
GxGy.number = Gx_s.number.*Gy_s.number; %FixMultiply(Gx_s, Gy_s, S21_INT, S21_FRAC);
GxGt.number = Gx_s.number.*Gt_s.number; %FixMultiply(Gx_s, Gt_s, S21_INT, S21_FRAC);
GyGt.number = Gy_s.number.*Gt_s.number; %FixMultiply(Gy_s, Gt_s, S21_INT, S21_FRAC);

GxGx.int_bits = 13;
GyGy.int_bits = 13;
GtGt.int_bits = 13;
GxGy.int_bits = 13;
GxGt.int_bits = 13;
GyGt.int_bits = 13;

GxGx.frac_bits = 13;
GyGy.frac_bits = 13;
GtGt.frac_bits = 13;
GxGy.frac_bits = 13;
GxGt.frac_bits = 13;
GyGt.frac_bits = 13;

GxGx_sc = GxGx;
GyGy_sc = GyGy;
GtGt_sc = GtGt;
GxGy_sc = GxGy;
GxGt_sc = GxGt;
GyGt_sc = GyGt;
T_scale = 2^ST_FRAC;
MAX = 2^(13)-1;
MIN = -2^(13);
GxGx_sc.number = GxGx_sc.number ./ T_scale;
GyGy_sc.number = GyGy_sc.number ./ T_scale;
GtGt_sc.number = GtGt_sc.number ./ T_scale;
GxGy_sc.number = GxGy_sc.number ./ T_scale;
GxGt_sc.number = GxGt_sc.number ./ T_scale;
GyGt_sc.number = GyGt_sc.number ./ T_scale;
GxGx_sc = GSaturate(GxGx_sc, MAX, MIN);
GyGy_sc = GSaturate(GyGy_sc, MAX, MIN);
GtGt_sc = GSaturate(GtGt_sc, MAX, MIN);
GxGy_sc = GSaturate(GxGy_sc, MAX, MIN);
GxGt_sc = GSaturate(GxGt_sc, MAX, MIN);
GyGt_sc = GSaturate(GyGt_sc, MAX, MIN);


GxGx_s = Fast2DConv_f_mask2(GxGx_sc, app2Mask_f, S21_INT, S21_FRAC, S22_INT, S22_FRAC);
GyGy_s = Fast2DConv_f_mask2(GyGy_sc, app2Mask_f, S21_INT, S21_FRAC, S22_INT, S22_FRAC);
GtGt_s = Fast2DConv_f_mask2(GtGt_sc, app2Mask_f, S21_INT, S21_FRAC, S22_INT, S22_FRAC);
GxGy_s = Fast2DConv_f_mask2(GxGy_sc, app2Mask_f, S21_INT, S21_FRAC, S22_INT, S22_FRAC);
GxGt_s = Fast2DConv_f_mask2(GxGt_sc, app2Mask_f, S21_INT, S21_FRAC, S22_INT, S22_FRAC);
GyGt_s = Fast2DConv_f_mask2(GyGt_sc, app2Mask_f, S21_INT, S21_FRAC, S22_INT, S22_FRAC);

%%%%%%%%5. Get the Ridge Estimator for each pixel%%%%%%%%
sizeVx = size(GxGx_s.number, 2);
sizeVy = size(GxGx_s.number, 1);
scale_fac = 2.0^S22_FRAC;
p = 2;
n = app2Size^2;

ratio = 8;
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
    C(i, 1) = 1;
    Kr(i, 1) = 0;
    for j=1:sizeVx
        % if (i==5 && j==21)
        %    a = 1;
        % end;
        gxx = double(GxGx_s.number(i,j)) / scale_fac;
        gyy = double(GyGy_s.number(i,j)) / scale_fac;
        gxy = double(GxGy_s.number(i,j)) / scale_fac;
        gxt = double(GxGt_s.number(i,j)) / scale_fac;
        gyt = double(GyGt_s.number(i,j)) / scale_fac;
        gtt = double(GtGt_s.number(i,j)) / scale_fac;
        %[vx_l, vy_l] = VelocityCalc(gxx, gyy, gxy, gxt, gyt);
        
        if ((vx_l^2+vy_l^2)==0)
            a = 1;
        end;
        k = 0;
        Thr(i,j) = gxx*gyy-gxy^2;
        if (gxx*gyy-gxy^2<0.5)
            k = (p/(n-p))*(gtt-2*gxt*vx_l-2*gyt*vy_l+gxx*vx_l*vx_l+2*gxy*vx_l*vy_l+gyy*vy_l*vy_l)/ratio;
        else
            k = 0;
        end;
        
%         if (abs(k)>50)
%             k = 0;
%         end;
        Kr(i,j) = k;
        %k = 0;
        gxx_n = gxx + k;
        gyy_n = gyy + k;
        if (certaintyFlag == 1)
            ci = certainty_calc(double([gxx gyy gtt gxy gxt gyt]));
            C(i, j)  = ci;
        end;
        [vx_l, vy_l] = VelocityCalc(gxx_n, gyy_n, gxy, gxt, gyt);
        if (vx_l>7)
            vx_l = 7;
        elseif (vx_l<-8)
            vx_l = -8;
        end;
        if (vy_l>7) 
            vy_l = 7;
        elseif (vy_l<-8)
            vy_l = -8;
        end;
%         if (vx_l>31)
%             vx_l = 31;
%         elseif (vx_l<-32)
%             vx_l = -32;
%         end;
%         if (vy_l>31) 
%             vy_l = 31;
%         elseif (vy_l<-32)
%             vy_l = -32;
%         end;


        Vx(i, j) = vx_l;
        Vy(i, j) = vy_l;
    end;
end;

%figure, imagesc(Kr);

%%%%%%%%6. Smooth the velocity field%%%%%%%%
Vx_s = Fast2DConv(Vx, app3Mask);
Vy_s = Fast2DConv(Vy, app3Mask);
if (certaintyFlag == 1)
    V = zeros(sizeY, sizeX, 3);
else
    V = zeros(sizeY, sizeX, 2);
end;

%%%%%%%%7. Estimate the accuracy if there's any%%%%%%%%
boundSize = hfDMaskSize+hfSpatialApp1Size+hfApp2Size+hfApp3Size;

if( john_test == 1)
    vx_sm = load('GPU_results/vx_sm.txt');
    vy_sm = load('GPU_results/vy_sm.txt');
   
    
    vx_sm = load('\\Ambric\stephen''s documents\workspace\Optical Flow\output\Smooth_v\vx_smooth_300x236x7.tab_delimited');
    vy_sm = load('\\Ambric\stephen''s documents\workspace\Optical Flow\output\Smooth_v\vy_smooth_300x236x7.tab_delimited');
    
    vx_sm = vx_sm(4*236+1:5*236,:);
    vy_sm = vy_sm(4*236+1:5*236,:);
   
    %vx_sm = vx_sm(9:244,9:308);
    %vy_sm = vy_sm(9:244,9:308);
    
    Vx_s = vx_sm;
    Vy_s = vy_sm;
end;

%padded with zeros along the boundry
V(boundSize+1:end-boundSize, boundSize+1:end-boundSize, 1) = -Vy_s;
V(boundSize+1:end-boundSize, boundSize+1:end-boundSize, 2) = -Vx_s;
if (certaintyFlag == 1)
    V(boundSize-2:end-boundSize+3, boundSize-2:end-boundSize+3, 3) = C;
end;
boundMask = zeros(sizeY, sizeX);
boundMask(boundSize+1:end-boundSize, boundSize+1:end-boundSize) = 1;
boundMask = logical(boundMask);
if (maskFlag)
    mask_l = logical(ones(sizeY, sizeX));
else
    mask_l = mask;
end;

if (correctFlowFlag)
    [error1_r, error2_r, error3_r, std1_r, std2_r, std3_r] = evaluate_velocity(V, correctFlow, mask_l);
else
    error1_r = 0;
    error2_r = 0;
    error3_r = 0;
    std1_r = 0;
    std2_r = 0;
    std3_r = 0;
end;

%%%%%%%%9. Draw the velocity field if needed%%%%%%%%
if (displayFlag==1)
    %figure('Name', ['Ratio' int2str(ratio)]);
    imshow(sequence(:,:,(sizeT+1)/2)./255);
    %imshow(sequence(:,:,(sizeT+1)/2));
    [x,y] = meshgrid(1+boundSize:displayGridSize:sizeX-boundSize,1+boundSize:displayGridSize:sizeY-boundSize);
    sizeX_VxVy = size(Vx_s, 2);
    sizeY_VxVy = size(Vy_s, 1);
    xflow = V(1:displayGridSize:sizeY_VxVy,1:displayGridSize:sizeX_VxVy,1);
    yflow = V(1:displayGridSize:sizeY_VxVy,1:displayGridSize:sizeX_VxVy,2);
    
    %For ploting motion field seperately
%     xflow = V(sizeY_VxVy:-displayGridSize:1,1:displayGridSize:sizeX_VxVy,1);
%     yflow = V(sizeY_VxVy:-displayGridSize:1,1:displayGridSize:sizeX_VxVy,2);
    hold on
    %figure, quiver(x, y, yflow, xflow, 3, 'b');
    quiver(x, y, yflow, xflow, 3, 'b');
    
%     %For ploting motion field seperately
%     figure, quiver(x, y, yflow, -xflow, 3, 'b');

    %hold off
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Sub functions%%%%%%%%%%%%%%%%%%%%%%%%%%
function Gout = GSaturate(G, MAX, MIN)
Gout = G;
GPosInd = find(G.number >= MAX);
Gout.number(GPosInd) = MAX;
GNegInd = find(G.number < MIN);
Gout.number(GNegInd) = MIN;

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
function conv2DImage = Fast2DConv_f_mask1(image, mask, int1_bits, frac1_bits, int2_bits, frac2_bits)
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
sumTemp1.int_bits = int1_bits;
sumTemp1.frac_bits= frac1_bits;
sumTemp2.number = int32(zeros(sizeY-2*hMaskSize, sizeX-2*hMaskSize));
sumTemp2.int_bits = int2_bits;
sumTemp2.frac_bits= frac2_bits;
scale = 2^frac1_bits;
MAX_NUM1 =  2^(13-frac1_bits-1)-1;
MIN_NUM1 = -2^(13-frac1_bits-1);
MAX_NUM2 =  2^(17-frac1_bits-frac2_bits)-1;
MIN_NUM2 = -2^(17-frac1_bits-frac2_bits);

%Convolution along X
for i=1:maskSize
    tempImg.number = image.number(1:end, i:i+sizeX-maskSize);
    tempImg.int_bits = image.int_bits;
    tempImg.frac_bits= image.frac_bits;
    %tempMask.number= mask
    rst = tempImg.number .* mask(i).number;
    sumTemp1.number = sumTemp1.number + rst;
end;
sumTemp1.number = int32(double(sumTemp1.number) / scale);
%saturate the number
tempPosInd = find(sumTemp1.number>=MAX_NUM1);
sumTemp1.number(tempPosInd) = MAX_NUM1;
tempNegInd = find(sumTemp1.number<MIN_NUM1);
sumTemp1.number(tempNegInd) = MIN_NUM1;

%Convolution along Y
for i=1:maskSize
    tempImg.number = sumTemp1.number(i:i+sizeY-maskSize, 1:end);
    tempImg.int_bits = image.int_bits;
    tempImg.frac_bits= image.frac_bits;
    %rst = FixMultiply(tempImg, mask(i), int_bits, frac_bits);%*mask(i);
    rst = tempImg.number .* mask(i).number;
    sumTemp2.number = sumTemp2.number + rst;
end;
sumTemp2.number = int32(double(sumTemp2.number) / scale);

tempPosInd = find(sumTemp2.number>=MAX_NUM2);
sumTemp2.number(tempPosInd) = MAX_NUM2;
tempNegInd = find(sumTemp2.number<=MIN_NUM2);
sumTemp2.number(tempNegInd) = MIN_NUM2;

sumTemp2.int_bits = int2_bits;
sumTemp2.frac_bits= frac2_bits;
conv2DImage = sumTemp2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function conv2DImage = Fast2DConv_f_mask2(image, mask, int1_bits, frac1_bits, int2_bits, frac2_bits)
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
sumTemp1.int_bits = int1_bits;
sumTemp1.frac_bits= frac1_bits;
sumTemp2.number = int32(zeros(sizeY-2*hMaskSize, sizeX-2*hMaskSize));
sumTemp2.int_bits = int2_bits;
sumTemp2.frac_bits= frac2_bits;
scale = 2^frac1_bits;
MAX_NUM1 =  2^(17-frac1_bits)-1;
MIN_NUM1 = -2^(17-frac1_bits);
MAX_NUM2 =  2^(21-frac1_bits-frac2_bits)-1;
MIN_NUM2 = -2^(21-frac1_bits-frac2_bits);

%Convolution along X
for i=1:maskSize
    tempImg.number = image.number(1:end, i:i+sizeX-maskSize);
    tempImg.int_bits = image.int_bits;
    tempImg.frac_bits= image.frac_bits;
    %tempMask.number= mask
    rst = tempImg.number .* mask(i).number;
    sumTemp1.number = sumTemp1.number + rst;
end;
sumTemp1.number = int32(double(sumTemp1.number) / scale);
%saturate the number
tempPosInd = find(sumTemp1.number>=MAX_NUM1);
sumTemp1.number(tempPosInd) = MAX_NUM1;
tempNegInd = find(sumTemp1.number<=MIN_NUM1);
sumTemp1.number(tempNegInd) = MIN_NUM1;

%Convolution along Y
for i=1:maskSize
    tempImg.number = sumTemp1.number(i:i+sizeY-maskSize, 1:end);
    tempImg.int_bits = image.int_bits;
    tempImg.frac_bits= image.frac_bits;
    %rst = FixMultiply(tempImg, mask(i), int_bits, frac_bits);%*mask(i);
    rst = tempImg.number .* mask(i).number;
    sumTemp2.number = sumTemp2.number + rst;
end;
sumTemp2.number = int32(double(sumTemp2.number) / scale);

tempPosInd = find(sumTemp2.number>=MAX_NUM2);
sumTemp2.number(tempPosInd) = MAX_NUM2;
tempNegInd = find(sumTemp2.number<=MIN_NUM2);
sumTemp2.number(tempNegInd) = MIN_NUM2;

sumTemp2.int_bits = int2_bits;
sumTemp2.frac_bits= frac2_bits;
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
scale = 2^frac_bits;
%Convolution along X
for i=1:maskSize
    tempImg.number = image.number(1:end, i:i+sizeX-maskSize);
    tempImg.int_bits = image.int_bits;
    tempImg.frac_bits= image.frac_bits;
    %tempMask.number= mask
    rst = tempImg.number .* mask(i).number;
    sumTemp1.number = sumTemp1.number + rst;
end;
sumTemp1.number = int32(double(sumTemp1.number) / scale);

%Convolution along Y
for i=1:maskSize
    tempImg.number = sumTemp1.number(i:i+sizeY-maskSize, 1:end);
    tempImg.int_bits = image.int_bits;
    tempImg.frac_bits= image.frac_bits;
    %rst = FixMultiply(tempImg, mask(i), int_bits, frac_bits);%*mask(i);
    rst = tempImg.number .* mask(i).number;
    sumTemp2.number = sumTemp2.number + rst;
end;
sumTemp2.number = int32(double(sumTemp2.number) / scale);
sumTemp2.int_bits = int_bits;
sumTemp2.frac_bits= frac_bits;
conv2DImage = sumTemp2;

% This function calculates the 3D convolution for one frame in fixed point
% maskS is the spatial smoothing mask
% maskT is the temporal smoothing mask
function conv3DImage = Fast3DConv_f(imgVolume, maskS, maskT, int_t_bits, frac_t_bits, int1_s_bits, frac1_s_bits, int2_s_bits, frac2_s_bits)
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
sumTemp1.int_bits = int_t_bits;
sumTemp1.frac_bits= frac_t_bits;
%Convolution along T
scale = 2^frac_t_bits;
for i=1:maskTSize
    tempImg.number = imgVolume.number(1:end, 1:end, i);
    tempImg.int_bits = imgVolume.int_bits;
    tempImg.frac_bits= imgVolume.frac_bits;
    rst = tempImg.number .* maskT(i).number;
    sumTemp1.number = sumTemp1.number + rst;
end;
sumTemp1.number = int32(double(sumTemp1.number) / scale);
%saturate the number
tempPosInd = find(sumTemp1.number>=255);
sumTemp1.number(tempPosInd) = 255;
tempNegInd = find(sumTemp1.number<=-256);
sumTemp1.number(tempNegInd) = -256;

conv3DImage = Fast2DConv_f_mask1(sumTemp1, maskS, int1_s_bits, frac1_s_bits, int2_s_bits, frac2_s_bits);

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
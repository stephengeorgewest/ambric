%This function is used to calculate the certain for the optical flow vector
%gkk is a 1-by-6 vector which contains [gxx, gyy, gtt, gxy, gxt, gyt] (in
%the same sequence) 

function certainty = certainty_calc(gkk)

warning off;
%gkk = [gxx gyy gtt gxy gxt gyt]
%T = [gxx gxy gxt
%     gxy gyy gyt
%     gxt gyt gtt]
T = [gkk(1) gkk(4) gkk(5);gkk(4) gkk(2) gkk(6); gkk(5) gkk(6) gkk(3)];

Q = T(1:2, 1:2);
q = T(1:2, 3);
if (cond(Q)>10000)
    ci = 1;
else
    ci = (T(3, 3)-q'*inv(Q)*q)/(trace(T)+0.001);
end;

if (ci>1)
    ci = 1;
elseif (ci<0)
    ci = 0;
end;

certainty = 1 - ci;
return;


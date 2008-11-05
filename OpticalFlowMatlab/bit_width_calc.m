function [] = bit_width_calc()
clc;
start = [0 255];
    fprintf(print('start            ', start, 0));
der = [-255 255]*9;
    fprintf(print('dervitive        ', der, 0));
smooth_d = der*4*16*16;
    fprintf(print('smooth_d         ', smooth_d, 0));
smooth_d_shifted = smooth_d/(2^6);
    fprintf(print('smooth_d Shifted ', smooth_d_shifted, 6));
op = smooth_d_shifted.^2;
	fprintf(print('outer Product    ', op, 0));
    
op_shifted = op/(2^4);
	fprintf(print('op shifted       ',op_shifted, 4));
smooth_opx = op_shifted*16;
	fprintf(print('smooth op x      ',smooth_opx, 0));
    
smooth_opx_shifted = smooth_opx/16;
    fprintf(print('smooth op x shift',smooth_opx_shifted, 4));
smooth_opy = smooth_opx_shifted*16;
	fprintf(print('smooth op y      ',smooth_opy, 0));
    
smooth_op_shifted = (smooth_opy/2^(16));
	fprintf(print('smooth_op shifted',smooth_op_shifted, 16));
vel = smooth_op_shifted.^2 + smooth_op_shifted.^2;
    fprintf(print('velocity         ',vel, 0));
k = smooth_op_shifted+4.*smooth_op_shifted.*vel + 4.*smooth_op_shifted.*vel.*vel;
%smooth_op_shifted
%+ 2*smooth_op_shifted.*vel
%+ smooth_op_shifted.*vel.*vel
%+ 2.*smooth_op_shifted.*vel
%+ 2.*smooth_op_shifted.*vel.*vel
%+ smooth_op_shifted.*vel.*vel;
%	fprintf(print('k               ',k, 0));
%%%%%%%%%%%%%%%%%%%%%%
function str = print(name,a,val)
%str1 = ['[' dec2hex(-a(1),8) ' ... ' dec2hex(floor(a(2)),8) ']'];
str1 = [name ' = ['  ' ... ' dec2hex(floor(a(2)),8) '] shiftby = ' int2str(val) '\n'];
str = str1;

%function [] = view_v()
%if(true)
%    x_range = [-8 7];
%    y_range = [-8 7];
%else
    
   
%end;
load '\\Ambric\stephen''s documents\workspace\Optical Flow\Output\Velocity\Vx_306x242x7.tab_delimited'
x_range = [min(min(Vx_306x242x7)) max(max(Vx_306x242x7))];
imtool(Vx_306x242x7, x_range);
load '\\Ambric\stephen''s documents\workspace\Optical Flow\Output\Velocity\Vy_306x242x7.tab_delimited'
y_range = [min(min(Vy_306x242x7)) max(max(Vy_306x242x7))];
imtool(Vy_306x242x7, y_range);
load '\\Ambric\stephen''s documents\workspace\optical Flow\output\Velocity\K_306x242x7.tab_delimited'
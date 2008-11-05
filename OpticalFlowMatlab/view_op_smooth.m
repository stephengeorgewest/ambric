%function [] = view_op_smooth()
load '\\Ambric\stephen''s documents\workspace\Optical Flow\Output\Smooth_op\g_xx_smooth_306x242x7.tab_delimited'
imtool(g_xx_smooth_306x242x7, [min(min(g_xx_smooth_306x242x7))/4 max(max(g_xx_smooth_306x242x7))/4]);
load '\\Ambric\stephen''s documents\workspace\Optical Flow\Output\Smooth_op\g_xy_smooth_306x242x7.tab_delimited'
imtool(g_xy_smooth_306x242x7, [min(min(g_xy_smooth_306x242x7))/4 max(max(g_xy_smooth_306x242x7))/4]);
load '\\Ambric\stephen''s documents\workspace\Optical Flow\Output\Smooth_op\g_xt_smooth_306x242x7.tab_delimited'
imtool(g_xt_smooth_306x242x7, [min(min(g_xt_smooth_306x242x7))/4 max(max(g_xt_smooth_306x242x7))/4]);
load '\\Ambric\stephen''s documents\workspace\Optical Flow\Output\Smooth_op\g_yy_smooth_306x242x7.tab_delimited'
imtool(g_yy_smooth_306x242x7, [min(min(g_yy_smooth_306x242x7))/4 max(max(g_yy_smooth_306x242x7))/4]);
load '\\Ambric\stephen''s documents\workspace\Optical Flow\Output\Smooth_op\g_yt_smooth_306x242x7.tab_delimited'
imtool(g_yt_smooth_306x242x7, [min(min(g_yt_smooth_306x242x7))/4 max(max(g_yt_smooth_306x242x7))/4]);
load '\\Ambric\stephen''s documents\workspace\Optical Flow\Output\Smooth_op\g_tt_smooth_306x242x7.tab_delimited'
imtool(g_tt_smooth_306x242x7, [min(min(g_tt_smooth_306x242x7))/4 max(max(g_tt_smooth_306x242x7))/4]);

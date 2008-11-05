%function [] = view_op()
load '\\Ambric\stephen''s documents\workspace\Optical Flow\Output\Outer_Product\g_xx_308x244x7.tab_delimited'
imtool(g_xx_308x244x7, [min(min(g_xx_308x244x7))/4 max(max(g_xx_308x244x7))/4]);
load '\\Ambric\stephen''s documents\workspace\Optical Flow\Output\Outer_Product\g_xy_308x244x7.tab_delimited'
imtool(g_xy_308x244x7, [min(min(g_xy_308x244x7))/4 max(max(g_xy_308x244x7))/4]);
load '\\Ambric\stephen''s documents\workspace\Optical Flow\Output\Outer_Product\g_xt_308x244x7.tab_delimited'
imtool(g_xt_308x244x7, [min(min(g_xt_308x244x7))/4 max(max(g_xt_308x244x7))/4]);
load '\\Ambric\stephen''s documents\workspace\Optical Flow\Output\Outer_Product\g_yy_308x244x7.tab_delimited'
imtool(g_yy_308x244x7, [min(min(g_yy_308x244x7))/4 max(max(g_yy_308x244x7))/4]);
load '\\Ambric\stephen''s documents\workspace\Optical Flow\Output\Outer_Product\g_yt_308x244x7.tab_delimited'
imtool(g_yt_308x244x7, [min(min(g_yt_308x244x7))/4 max(max(g_yt_308x244x7))/4]);
load '\\Ambric\stephen''s documents\workspace\Optical Flow\Output\Outer_Product\g_tt_308x244x7.tab_delimited'
imtool(g_tt_308x244x7, [min(min(g_tt_308x244x7))/4 max(max(g_tt_308x244x7))/4]);

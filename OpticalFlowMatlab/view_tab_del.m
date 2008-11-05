function []=view_tab_del(name)
%load name
%long_name=['\\Ambric\stephen''s documents\workspace\Optical Flow\Output\Derivitive' name '.tab_delimited']
%load long_name
imtool(name(:,:),[min(min(min(name))) max(max(max(name)))])
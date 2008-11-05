function []=view_tab_del_each(name,height)
%load '\\Ambric\stephen''s documents\workspace\Optical Flow\Output\Derivitive\' name '.tab_delimited'
for i=0:9
    imtool(name(1+i*height:height*(1+i),:),[min(min(min(name))) max(max(max(name)))])
end 
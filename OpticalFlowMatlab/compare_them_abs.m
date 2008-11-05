function []= compare_them_abs ( one , two)

Diff=one-two;
max_diff=max(max(max(Diff)))
min_diff=min(min(min(Diff)))
imtool(Diff,[min([min(min(one)) min(min(two))]) max([max(max(one)) max(max(two))])]);
imtool(Diff,[min_diff max_diff]);
hist(Diff);
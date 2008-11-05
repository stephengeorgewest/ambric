function []= compare_them ( one , two)
Gtb=(one-min(min(min(one))))/(max(max(max(one)))-min(min(min(one))));
Gta=(two-min(min(min(two))))/(max(max(max(two)))-min(min(min(two))));
GtDiff=Gta-Gtb;
max_diff=max(max(max(GtDiff)))
min_diff=min(min(min(GtDiff)))
imtool(GtDiff,[min_diff max_diff]);
hist(GtDiff);
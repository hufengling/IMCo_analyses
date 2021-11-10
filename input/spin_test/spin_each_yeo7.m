left_names = "lh.yeo7_" + string(1:7);
right_names = "rh.yeo7_" + string(1:7);
permno = 2000;
filedir = "~/Documents/IMCo_analyses/input/spin_test/yeo7_regions/"
path_to_wsname = "~/Documents/IMCo_analyses/input/spin_test/yeo7_spins/";
wsname = path_to_wsname + "yeo7_" + string(1:7) + ".mat";

for region = 1:length(left_names)
    disp(region)
    SpinPermuFS(left_names(region), right_names(region), permno, filedir, wsname(region));
end

path(path, "/home/fengling/Documents/IMCo_analyses/input/spin_test");
path(path, "/home/fengling/matlab");

pval_dir = "../output/freesurfer_images/surfaces/pvals/adjusted";
pval_list = dir(fullfile(pval_dir, "*.mgh"));
pval_paths = [];
for i = 1:length(pval_list)
    pval_paths = [pval_paths, erase(pval_list(i, 1).folder + "/" + pval_list(i, 1).name, ".mgh")];
end

mod_dir = "../output/freesurfer_images/surfaces/pvals/modality";
mod_list = dir(fullfile(mod_dir, "*.mgh"));
mod_paths = [];
for i = 1:length(mod_list)
    mod_paths = [mod_paths, erase(mod_list(i, 1).folder + "/" + mod_list(i, 1).name, ".mgh")];
end

yeo7_dir = "~/Documents/IMCo_analyses/input/spin_test/yeo7_regions";
yeo7_list = dir(fullfile(yeo7_dir, "*.mgh"));
yeo7_paths = [];
for i = 1:length(yeo7_list)
    yeo7_paths = [yeo7_paths, erase(yeo7_list(i, 1).folder + "/" + yeo7_list(i, 1).name, ".mgh")];
end

spins_dir = "~/Documents/IMCo_analyses/input/spin_test/yeo7_spins";
spins_list = dir(fullfile(spins_dir, "*.mat"));
spins_paths = [];
for i = 1:length(spins_list)
    spins_paths = [spins_paths, spins_list(i, 1).folder + "/" + spins_list(i, 1).name];
end

pval_array = cell((length(pval_paths) + length(mod_paths))/2 + 1, length(spins_paths) + 1);
for spin_num = 1:length(spins_paths)
    lh_yeo7 = yeo7_paths(spin_num);
    rh_yeo7 = yeo7_paths(spin_num + 7);
    wsname = spins_paths(spin_num);
    spin_name = split(spins_paths(spin_num), "/")
    pval_array{1, spin_num + 1} = erase(spin_name(end), ".mat");
    for pval_num = 1:length(pval_paths)/2
        lh_pval = pval_paths(pval_num);
        rh_pval = pval_paths(pval_num + length(pval_paths)/2);
        pval_name = split(pval_paths(pval_num), "/")
        pval_array{pval_num + 1, 1} = erase(erase(pval_name(end), "lh."), ".mgh")
        pval_array{pval_num + 1, spin_num + 1} = pvals_null_imco(lh_yeo7, rh_yeo7, lh_pval, rh_pval, 2000, wsname);
    end
    for mod_num = 1:length(mod_paths)/2
        lh_mod = mod_paths(mod_num);
        rh_mod = mod_paths(mod_num + length(mod_paths)/2);
        mod_name = split(mod_paths(mod_num), "/")
        pval_array{length(pval_paths)/2 + mod_num + 1, 1} = erase(erase(mod_name(end), "lh."), ".mgh")
        pval_array{length(pval_paths)/2 + mod_num + 1, spin_num + 1} = pvals_null_imco(lh_yeo7, rh_yeo7, lh_mod, rh_mod, 2000, wsname);
    end
end

cell2csv("../output/figures/spin_test.csv", pval_array)

%% script to run spin test on imco maps for feng''s project

% in terminal, first set up FREESURFER_HOME environment variable
% export FREESURFER_HOME=/misc/appl/freesurfer-7.1.1/
% source $FREESURFER_HOME/SetUpFreeSurfer.sh

% in matlab interactive session:
cd /misc/appl/freesurfer-7.1.1/;
fshome = getenv('FREESURFER_HOME'); %  this will only work if you already have FREESURFER_HOME environment variable set up
fsmatlab = sprintf('%s./matlab',fshome);
path(path,fsmatlab);

% loop over the different things being tested

% step 1: SpinPermuFS.m to obtain 'spins' of one set of surfaces

n_modality = {'two', 'three'};

% surf1 - names for the imco surfaces
surf1 = {'unscaled_wcor_fwhm3_gm-mask_sex', 'unscaled_wcor_fwhm3_gm-mask_age', 'global_wcov_fwhm3_gm-mask_sex', 'global_wcov_fwhm3_gm-mask_age'};

% empty tables for output
pval_out = array2table(zeros(7,4)); 
pval_out.Properties.VariableNames = surf1;
pval_out.Properties.RowNames = {'yeo7_1', 'yeo7_2', 'yeo7_3', 'yeo7_4', 'yeo7_5', 'yeo7_6', 'yeo7_7'};

mod2_mod3_pvals = table(pval_out,pval_out);
mod2_mod3_pvals.Properties.VariableNames = {'two_modality','three_modality'};

for net=1:7
	read_left = sprintf('/project/pnc/surfaces_to_spin_test/atlas_surf/lh.yeo7_%d.nii.gz', net);
	read_right = sprintf('/project/pnc/surfaces_to_spin_test/atlas_surf/rh.yeo7_%d.nii.gz', net);

	datal = load_nifti(read_left); datal = datal.vol();
	datar = load_nifti(read_right); datar = datar.vol();

	% remove the medial wall:
	% vertices in the left medial wall:
	[vl,left_labels,ctl] = read_annotation('/misc/appl/freesurfer-7.1.1/subjects/fsaverage5/label/lh.aparc.a2009s.annot');
	% ctl.struct_names(43) for the medial wall; 1644825 is the label of medial
    datal(left_labels==1644825)=NaN; % there are 888 vertices in the right medial wall, now assigned to value NaN

	% vertices in the right medial wall:
	[vr,right_labels,ctr] = read_annotation('/misc/appl/freesurfer-7.1.1/subjects/fsaverage5/label/rh.aparc.a2009s.annot');
	% ctr.struct_names(43) for the medial wall; 1644825 is again the label of medial wall vertices in right_labels
    datar(right_labels==1644825)=NaN; % there are 881 vertices in the right medial wall, now assigned to value NaN

    cd /misc/appl/freesurfer-7.1.1/;
    fshome = getenv('FREESURFER_HOME');
    fsmatlab = sprintf('%s./matlab',fshome);
    path(path,fsmatlab);

    [verticesl, ~] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/lh.sphere'));
    [verticesr, ~] = freesurfer_read_surf(fullfile(fshome,'subjects/fsaverage5/surf/rh.sphere'));

    % spin left and right yeo surfaces
    wsname = sprintf('/project/pnc/surfaces_to_spin_test/spun_atlas_surf/spun_yeo7_%d', net);
    permno = 1000; % number of permutations
    cd /home/smweinst/spin_test_matlab/scripts;
    SpinPermuFS(verticesl, verticesr,datal, datar, permno,wsname)

    % step 2: network vs. two_modality, network vs. three_modality
    for m=1:2 % m = 1 for two_modality, m = 2 for three_modality
    	for S =1:length(surf1) % different file names within two_modality and three_modality folders
    		readleft1 = read_left; % yeo network 
    		readright1 = read_right;

    		readleft2 = sprintf('/project/pnc/surfaces_to_spin_test/pval_surf/%s_modality/lh.%s_fdr05.nii.gz', n_modality{m}, surf1{S});
    		readright2 = sprintf('/project/pnc/surfaces_to_spin_test/pval_surf/%s_modality/rh.%s_fdr05.nii.gz', n_modality{m}, surf1{S});

    		cd /project/pnc/surfaces_to_spin_test % this is where I put pvalsNull_imco_feng.m, which modifies the original spin test code to include jaccard instead of pearson correlation
    		pval = pvalsNull_imco_feng(readleft1,readright1,readleft2,readright2,permno,wsname, fshome);
    		mod2_mod3_pvals{:,m}(net,S) = {pval};

    	end

    end
end

two_modality_out = mod2_mod3_pvals(:,1);
three_modality_out = mod2_mod3_pvals(:,2);

ws_out = '/project/pnc/surfaces_to_spin_test/results/results12142020';
save(ws_out,'two_modality_out', 'three_modality_out')


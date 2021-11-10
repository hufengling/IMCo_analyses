function pval=pvalsNull_imco_feng(readleft1,readright1,readleft2,readright2,permno,wsname, fshome)
% SW edited version of this script to get a separate p-value for each
% hemisphere
% Calculate the p-value of correlation between two surface maps based on
% the null distribution of spins of map 1
% FORMAT pvalvsNull(readleft1,readright1,readleft2,readright2,permno,wsname)
% readleft1     - the filename of the first left surface data to spin 
% readright1    - the filename of the first right surface data to spin 
% readleft2     - the filename of the second left surface data to spin 
% readright2    - the filename of the second right surface data to spin 
% permno       - the number of permutations used in SpinPermuFS/CIVET
% wsname       - the name of a workspace file output from SpinPermuFS/CIVET
% pval         - the calculated p-value
% Example   p=pvalvsNull('../data/depressionFSdataL.csv','../data/depressionFSdataR.csv','../data/ptsdFSdataL.csv','../data/ptsdFSdataR.csv',100,'../data/rotationFS.mat')
% will calculate the pvalue of correlation between prebuilt data, neurosynth map associated with 'depression',
% and 'PTSD' using the null distribution of depression maps spun 100 times
% from the SpinPermuFS.m
% Simiarly, it can be used for CIVET version as well.
% Aaron Alexander-Bloch & Siyuan Liu 
% pvalvsNull.m, 2018-04-22
% SMW -- edited 12/14/2020 for Feng''s imco project


%load the saved workspace from SpinPermu

load(wsname)

%read the data saved in csv and merge left and right surfaces into one
datal1=load_nifti(readleft1); datal1 = datal1.vol();
datar1=load_nifti(readright1); datar1 = datar1.vol();
%data1=cat(1,datal1,datar1);
datal2=load_nifti(readleft2); datal2 = datal2.vol();
datar2=load_nifti(readright2); datar2 = datar2.vol();
%data2=cat(1,datal2,datar2);

% remove the medial wall:
% vertices in the left medial wall:
[vl,left_labels,ctl] = read_annotation(fullfile(fshome,'subjects/fsaverage5/label/lh.aparc.a2009s.annot'));
% ctl.struct_names(43) for the medial wall; 1644825 is the label of medial
% wall vertices in left_labels
datal1(left_labels==1644825)=NaN;
datal2(left_labels==1644825)=NaN;

% vertices in the right medial wall:
[vr,right_labels,ctr] = read_annotation(fullfile(fshome,'subjects/fsaverage5/label/rh.aparc.a2009s.annot'));
% ctr.struct_names(43) for the medial wall; 1644825 is again the label of
% medial wall vertices in right_labels
datar1(right_labels==1644825)=NaN; 
datar2(right_labels==1644825)=NaN; 

% after removing medial wall, combine left and right hemispheres for each modality
data1 = cat(1,datal1,datar1);
data2 = cat(1,datal2,datar2);

data1data2 = [data1,data2];
data1data2(any(isnan(data1data2),2)==1, :) = []; % remove rows with nan (medial wall)

realrho = jaccard(data1data2(:,1), data1data2(:,2));

% test the observed rho against null described by SpinPermu
nullrho = [];

for i=1:permno
	tempdata=cat(2,bigrotl(i,:),bigrotr(i,:))'; % bigrotl and bigrotr are loaded in with the workspace

	tempdata_data2 = [tempdata, data2];
	tempdata_data2(any(isnan(tempdata_data2),2)==1,:) = [];

	nullrho = cat(1, nullrho, jaccard(tempdata_data2(:,1), tempdata_data2(:,2)));

end

pval=length(find(abs(nullrho)>abs(realrho)))/permno;

% H3_extract_rois_AD.m
%
% This script applies CAT12 ROI extraction to data coregistered with sMRI. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

spm('defaults','fmri'); %comment out this line if you want to load in SPM GUI
spm_jobman('initcfg'); %comment out this line if you want to load in SPM GUI

%set batch number
bnum = 1;
sMRI_imgs = {};
dMRI_imgs = {};

for subj = 1:length(cfg.subjects)

    sMRI_img = {[cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'y_sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii']}; 
    dMRI_img = {[cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'esub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi_AD.nii']}; 

    sMRI_imgs = cat(1,sMRI_imgs,sMRI_img);
    dMRI_imgs = cat(1,dMRI_imgs,dMRI_img);
    
end

dMRI_imgs = {cat(1,dMRI_imgs)};

matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.field = sMRI_imgs;
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.images = dMRI_imgs;
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.atlases.neuromorphometrics = 1;
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.atlases.lpba40 = 1;
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.atlases.cobra = 1;
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.atlases.hammers = 1;
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.atlases.thalamus = 1;
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.atlases.suit = 0; %cerebellum atlas seems to cause errors, so excluded
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.atlases.ibsr = 1;
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.atlases.aal3 = 1;
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.atlases.mori = 1;
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.atlases.anatomy3 = 1;
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.atlases.julichbrain = 1;
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.atlases.Schaefer2018_100Parcels_17Networks_order = 1;
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.atlases.Schaefer2018_200Parcels_17Networks_order = 1;
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.atlases.Schaefer2018_400Parcels_17Networks_order = 1;
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.atlases.Schaefer2018_600Parcels_17Networks_order = 1;
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.atlases.ownatlas = {''};
matlabbatch{bnum}.spm.tools.cat.tools.ROIsum.Method.ManySubj.fhandle.fun = '@mean';

bnum = bnum+1;

spm_jobman('run',matlabbatch);

%move roi data to derivatives folders
bnum = 1;
for subj = 1:length(cfg.subjects)

    for atlas = 1:length(cfg.atlas)
        %move roi data to derivatives folders
        temp_in_file = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep cfg.atlas{atlas} '_sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.csv'];
        temp_mv_file = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep cfg.atlas{atlas} '_esub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi_AD.csv'];
        cmd_mvfile = strcat("mv "+temp_in_file+" "+temp_mv_file); %move roi file
        system(cmd_mvfile);
    end
    
    bnum = bnum+1;
    
end

%combine rois to group-level file
for atlas = 1:length(cfg.atlas)

    temp_combined = [];
    for subj = 1 
        %get header info from first subject
        temp_csv = readcell([cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep cfg.atlas{atlas} '_esub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi_AD.csv']);
        temp_combined = [temp_combined; temp_csv(1:3,:)];
    end
    for subj = 1:length(cfg.subjects)
        %combine roi data from derivatives folder
        temp_csv = readcell([cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep cfg.atlas{atlas} '_esub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi_AD.csv']);
        temp_combined = [temp_combined; temp_csv(4:end,:)];
    end
    
    writecell(temp_combined,[cfg.dMRIoutput filesep 'ROI_' cfg.atlas{atlas} '_dwi_AD.csv']);
    bnum = bnum+1;
    
end
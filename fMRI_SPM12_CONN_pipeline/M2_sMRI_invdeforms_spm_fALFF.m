% M2_sMRI_invdeforms_spm_fALFF.m
%
% This script applies CAT12 inverse deformations to coregistered and normalized fMRI data for processing in subject space. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

spm('defaults','fmri'); %comment out this line if you want to load in SPM GUI
spm_jobman('initcfg'); %comment out this line if you want to load in SPM GUI

%set batch number
bnum = 1;

for subj = 1:length(cfg.subjects)

    matlabbatch{bnum}.spm.tools.cat.tools.defs2.field = {[cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'iy_sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii,1']};
    matlabbatch{bnum}.spm.tools.cat.tools.defs2.images = {{[cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_bold_fALFF.nii,1']}};
    matlabbatch{bnum}.spm.tools.cat.tools.defs2.bb = cfg.fMRIbb; %keeping norm bb - if unspecified [NaN NaN NaN;NaN NaN NaN] will match deformations (e.g., T1w)
    matlabbatch{bnum}.spm.tools.cat.tools.defs2.vox = cfg.fMRInormVox; %keeping norm voxel space - if not specified [NaN NaN NaN] will match deformations (e.g., T1w)
    matlabbatch{bnum}.spm.tools.cat.tools.defs2.interp = 4;
    matlabbatch{bnum}.spm.tools.cat.tools.defs2.modulate = 0;

    bnum = bnum+1;
    
end

spm_jobman('run',matlabbatch);

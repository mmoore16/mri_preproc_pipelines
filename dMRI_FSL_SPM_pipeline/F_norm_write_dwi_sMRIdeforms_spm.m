% F_norm_write_dMRI_sMRIdeforms_spm.m
%
% This script applies CAT12 deformations to coregistered dMRI data for normalizing to MNI template space. 
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


    templist = [];
    other = [];
    vols = {};
        
    % Get the full file path and names for each subject
    folder = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi'];
    files = dir([folder filesep 'esub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi_*.nii']); %applying deformations to all dMRI files
    for c = 1:length(files)
        fullpath{c}=[files(c).folder,filesep,files(c).name];
    end
    tempfiles{c} = fullpath';
    templist = [templist,tempfiles];
    templist2 = cat(1,templist{:});
    vols = spm_select('expand', templist2); %select all frames from 4D file
    
    %copy sMRI warp file
    temp_in_file = [cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'y_sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii']; 
    temp_copy_file = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'y_sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii'];
    cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file
    system(cmd_cpfile);

    matlabbatch{bnum}.spm.spatial.normalise.write.subj.def = {[cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'y_sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii']};
    matlabbatch{bnum}.spm.spatial.normalise.write.subj.resample = vols;
    matlabbatch{bnum}.spm.spatial.normalise.write.woptions.bb = cfg.dMRIbb; %cat12 template_0_gs.nii and cat12 subject output seem to have this bb
    matlabbatch{bnum}.spm.spatial.normalise.write.woptions.vox = cfg.dMRInormVox; %resampling to XX mm isotropic
    matlabbatch{bnum}.spm.spatial.normalise.write.woptions.interp = 4; 

    bnum = bnum+1;
    
end

spm_jobman('run',matlabbatch);

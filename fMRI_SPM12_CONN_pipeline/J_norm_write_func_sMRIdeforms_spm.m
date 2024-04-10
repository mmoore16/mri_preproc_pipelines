% J_norm_write_func_sMRIdeforms_spm.m
%
% This script applies CAT12 deformations to coregistered fMRI data for normalizing to MNI template space. 
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

    runs = [];
    templist = [];
    for r=1:cfg.nruns
        vols = {};
        
        % Get the full file path and names for each subject
        folder = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func'];
        files = dir([folder filesep 'a' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',r) '_bold.nii']); %spatially, temporally aligned fmri
        for c = 1:length(files)
            fullpath{c}=[files(c).folder,filesep,files(c).name];
        end
        tempfiles{c} = fullpath';
        templist = [templist,tempfiles];
        templist2 = cat(1,templist{r});
        vols = spm_select('expand', templist2); %select all frames from 4D file
        runs = [runs, vols];
        
    end

    matlabbatch{bnum}.spm.spatial.normalise.write.subj.def = {[cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'y_sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii']};
    matlabbatch{bnum}.spm.spatial.normalise.write.subj.resample = runs;
    matlabbatch{bnum}.spm.spatial.normalise.write.woptions.bb = cfg.fMRIbb; %cat12 template_0_gs.nii and cat12 subject output seem to have this bb
    matlabbatch{bnum}.spm.spatial.normalise.write.woptions.vox = cfg.fMRInormVox; %resampling to XX mm isotropic
    matlabbatch{bnum}.spm.spatial.normalise.write.woptions.interp = 4; 

    bnum = bnum+1;
    
end

spm_jobman('run',matlabbatch);

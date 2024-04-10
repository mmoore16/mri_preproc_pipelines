% C_reorient_anat_acpc_nocom.m
%
% This script reorients sMRI data. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

%set batch number
bnum = 1;

for subj = 1:length(cfg.subjects)

    if ~exist([cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat'], 'dir')
        mkdir([cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat']); %sMRI derivatives folder for subject
    end
    temp_copy_file = [cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii.gz'];
    copyfile([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii.gz'], temp_copy_file, 'f'); %copying original to derivatives folder since acpc orientation will alter file header
    gunzip(temp_copy_file); %gunzip .nii.gz file
    system([strcat("rm -rf "+temp_copy_file)]); %remove zip file
    sMRI_img = {[cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii,1']};
    sMRI_tempimg = {'T1'};
    auto_acpc_reorient(sMRI_img, sMRI_tempimg, [], 'both', 20, [], []);

    bnum = bnum+1;

end


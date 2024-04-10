% M02_copy_conn_data_fALFF.m
%
% This script copies data processed with CONN. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

%set batch number
bnum = 1;

for subj = 1:length(cfg.subjects)

    %copy sMRI warp file
    temp_in_yfile = [cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'y_sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii']; 
    temp_copy_yfile = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'y_sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii'];
    if ~exist(temp_copy_yfile, 'file')
        cmd_cpyfile = strcat("cp "+temp_in_yfile+" "+temp_copy_yfile); %copy file
        system(cmd_cpyfile);
    end
    
    %copy sMRI inverse warp file
    temp_in_ifile = [cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'iy_sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii']; 
    temp_copy_ifile = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'iy_sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii'];
    if ~exist(temp_copy_ifile, 'file')
        cmd_cpifile = strcat("cp "+temp_in_ifile+" "+temp_copy_ifile); %copy inverse file
        system(cmd_cpifile);
    end

    %copy data processed with CONN to derivatives folder
    temp_in_file = [cfg.outputDirBIDSfcr 'fALFF_01' filesep 'BETA_' cfg.subjectsCONN{subj} '_Condition001_Measure001_Component001.nii']; %assuming matching naming convention for .nii
    temp_copy_file = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_bold_fALFF.nii'];
    %if ~exist(temp_copy_file, 'file')
        cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file
        system(cmd_cpfile);
    %end
    
    bnum = bnum+1;
    
end



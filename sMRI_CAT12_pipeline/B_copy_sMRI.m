% B_copy_sMRI.m
%
% This script copies sMRI data to BIDS folders. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

%set batch number
bnum = 1;

for subj = 1:length(cfg.subjects)

    if ~exist([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat'], 'dir')
        mkdir([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat']); %create BIDS format folder
    end
    
    %move sMRI data to BIDS folders - checks for acq and rec
    temp_copy_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii.gz'];
    if any(ismember(fields(cfg),'acq')) && ~isempty(cfg.acq) && any(ismember(fields(cfg),'rec')) && ~isempty(cfg.rec) && exist([cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{subj} '_rec-' cfg.rec{subj} '_T1w.nii.gz'], 'file') %if specific acquisition and rec is targeted
        temp_in_file = [cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{subj} '_rec-' cfg.rec{subj} '_T1w.nii.gz'];
        cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file if exists
        system(cmd_cpfile);
        fprintf(append(cmd_cpfile,'\n'));
    elseif any(ismember(fields(cfg),'acq')) && ~isempty(cfg.acq) && exist([cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{subj} '_T1w.nii.gz'], 'file') %if specific acquisition is targeted
        temp_in_file = [cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{subj} '_T1w.nii.gz'];
        cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file if exists
        system(cmd_cpfile);
        fprintf(append(cmd_cpfile,'\n'));
    elseif any(ismember(fields(cfg),'rec')) && ~isempty(cfg.rec) && exist([cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_rec-' cfg.rec{subj} '_T1w.nii.gz'], 'file') %if specific rec is targeted
        temp_in_file = [cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_rec-' cfg.rec{subj} '_T1w.nii.gz'];
        cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file if exists
        system(cmd_cpfile);
        fprintf(append(cmd_cpfile,'\n'));
    elseif exist([cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii.gz'], 'file')
        temp_in_file = [cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii.gz'];
        cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file if exists
        system(cmd_cpfile);
        fprintf(append(cmd_cpfile,'\n'));
    elseif ~isempty(dir([cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '*_T1w.nii.gz'])) %allow for variability in file name
        temp_file = dir([cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '*_T1w.nii.gz']);
        temp_in_file = [cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep temp_file(1).name]; %taking first file if more than one
        cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file if exists
        system(cmd_cpfile);
        fprintf(append(cmd_cpfile,'\n'));
    else 
        fprintf('Could not find T1w file to copy. Check data!\n');
    end
    
    temp_copy_json = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.json'];
    if any(ismember(fields(cfg),'acq')) && ~isempty(cfg.acq) && any(ismember(fields(cfg),'rec')) && ~isempty(cfg.rec) && exist([cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{subj} '_rec-' cfg.rec{subj} '_T1w.json'], 'file') %if specific acquisition and rec is targeted
        temp_in_json = [cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{subj} '_rec-' cfg.rec{subj} '_T1w.json']; 
        cmd_cpjson = strcat("cp "+temp_in_json+" "+temp_copy_json); %copy json if exists
        system(cmd_cpjson);
        fprintf(append(cmd_cpjson,'\n'));
    elseif any(ismember(fields(cfg),'acq')) && ~isempty(cfg.acq) && exist([cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{subj} '_T1w.json'], 'file') %if specific acquisition is targeted
        temp_in_json = [cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{subj} '_T1w.json']; 
        cmd_cpjson = strcat("cp "+temp_in_json+" "+temp_copy_json); %copy json if exists
        system(cmd_cpjson);
        fprintf(append(cmd_cpjson,'\n'));
    elseif any(ismember(fields(cfg),'rec')) && ~isempty(cfg.rec) && exist([cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_rec-' cfg.rec{subj} '_T1w.json'], 'file') %if specific rec is targeted
        temp_in_json = [cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_rec-' cfg.rec{subj} '_T1w.json']; 
        cmd_cpjson = strcat("cp "+temp_in_json+" "+temp_copy_json); %copy json if exists
        system(cmd_cpjson);
        fprintf(append(cmd_cpjson,'\n'));
    elseif exist([cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.json'], 'file')
        temp_in_json = [cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.json'];
        cmd_cpjson = strcat("cp "+temp_in_json+" "+temp_copy_json); %copy json if exists
        system(cmd_cpjson);
        fprintf(append(cmd_cpjson,'\n'));
    elseif ~isempty(dir([cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '*_T1w.json'])) %allow for variability in json name
        temp_json = dir([cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '*_T1w.json']);
        temp_in_json = [cfg.tempsMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep temp_file(1).name]; %taking first json if more than one
        cmd_cpjson = strcat("cp "+temp_in_json+" "+temp_copy_json); %copy json if exists
        system(cmd_cpjson);
        fprintf(append(cmd_cpjson,'\n'));
    else 
        fprintf('Could not find T1w json file to copy. Check data!\n');
    end
    
    bnum = bnum+1;
    
end



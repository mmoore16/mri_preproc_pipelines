% B_copy_fMRI.m
%
% This script copies fMRI data to BIDS folders. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

%set batch number
bnum = 1;

for subj = 1:length(cfg.subjects)

    if ~exist([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func'], 'dir')
        mkdir([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func']); %create BIDS format folder
    end
    
    %move fMRI data to BIDS folders - checks for acq, run, OR dir     
    if any(ismember(fields(cfg),'acq')) && ~isempty(cfg.acq) && any(ismember(fields(cfg),'ndruns')) && any(gt(cfg.nruns,1)) %if acquisitions AND multiple runs are targeted - not currently supported!
        fprintf('Acquisition field and multiple runs are specified - processing of both not currently supported. Check parameters!\n');
    elseif any(ismember(fields(cfg),'dir')) && ~isempty(cfg.dir) && any(ismember(fields(cfg),'ndruns')) && any(gt(cfg.nruns,1)) %if directions AND multiple runs are targeted - not currently supported!
        fprintf('Direction field and multiple runs are specified - processing of both not currently supported. Check parameters!\n');
    elseif any(ismember(fields(cfg),'acq')) && ~isempty(cfg.acq) && any(ismember(fields(cfg),'dir')) && ~isempty(cfg.dir) %if acquisitions AND directions are targeted - not currently supported!
        fprintf('Acquisition and Direction fields are both specified - processing of both not currently supported. Check parameters!\n'); 
    elseif any(ismember(fields(cfg),'acq')) && ~isempty(cfg.acq) %if acquisitions are targeted
        for rr = 1:length(cfg.acq)
            nb=1; %allow for single run label
            if exist([cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_acq-' cfg.acq{rr} '_bold.nii.gz'], 'file')
                temp_in_file = [cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_acq-' cfg.acq{rr} '_bold.nii.gz'];
                temp_copy_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_acq-' cfg.acq{rr} '_bold.nii.gz'];
                cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file if exists
                system(cmd_cpfile);
                fprintf(append(cmd_cpfile,'\n'));
                %also copy json - assuming consistent file names
                temp_in_json = [cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_acq-' cfg.acq{rr} '_bold.json'];
                temp_copy_json = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_acq-' cfg.acq{rr} '_bold.json'];
                cmd_cpjson = strcat("cp "+temp_in_json+" "+temp_copy_json); %copy json file
                system(cmd_cpjson);
                fprintf(append(cmd_cpjson,'\n'));
            elseif exist([cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_acq-' cfg.acq{rr} '_run-' sprintf('%02d',nb) '_bold.nii.gz'], 'file')
                temp_in_file = [cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_acq-' cfg.acq{rr} '_run-' sprintf('%02d',nb) '_bold.nii.gz'];
                temp_copy_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_acq-' cfg.acq{rr} '_run-' sprintf('%02d',nb) '_bold.nii.gz'];
                cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file if exists
                system(cmd_cpfile);
                fprintf(append(cmd_cpfile,'\n'));
                %also copy json - assuming consistent file names
                temp_in_json = [cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_acq-' cfg.acq{rr} '_run-' sprintf('%02d',nb) '_bold.json'];
                temp_copy_json = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_acq-' cfg.acq{rr} '_run-' sprintf('%02d',nb) '_bold.json'];
                cmd_cpjson = strcat("cp "+temp_in_json+" "+temp_copy_json); %copy json file
                system(cmd_cpjson);
                fprintf(append(cmd_cpjson,'\n'));
            end
        end
    elseif any(ismember(fields(cfg),'dir')) && ~isempty(cfg.dir) %if dirs are targeted
        for r = 1:length(cfg.dir)
            nb=1; %allow for single run label
            if exist([cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_dir-' cfg.dir{r} '_bold.nii.gz'], 'file') 
                temp_in_file = [cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_dir-' cfg.dir{r} '_bold.nii.gz'];
                temp_copy_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_dir-' cfg.dir{r} '_bold.nii.gz'];
                cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file if exists
                system(cmd_cpfile);
                fprintf(append(cmd_cpfile,'\n'));
                %also copy json - assuming consistent file names
                temp_in_json = [cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_dir-' cfg.dir{r} '_bold.json'];
                temp_copy_json = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_dir-' cfg.dir{r} '_bold.json'];
                cmd_cpjson = strcat("cp "+temp_in_json+" "+temp_copy_json); %copy json file
                system(cmd_cpjson);
                fprintf(append(cmd_cpjson,'\n'));
            elseif exist([cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_dir-' cfg.dir{r} '_run-' sprintf('%02d',nb) '_bold.nii.gz'], 'file') 
                temp_in_file = [cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_dir-' cfg.dir{r} '_run-' sprintf('%02d',nb) '_bold.nii.gz'];
                temp_copy_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_dir-' cfg.dir{r} '_run-' sprintf('%02d',nb) '_bold.nii.gz'];
                cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file if exists
                system(cmd_cpfile);
                fprintf(append(cmd_cpfile,'\n'));
                %also copy json - assuming consistent file names
                temp_in_json = [cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_dir-' cfg.dir{r} '_run-' sprintf('%02d',nb) '_bold.json'];
                temp_copy_json = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_dir-' cfg.dir{r} '_run-' sprintf('%02d',nb) '_bold.json'];
                cmd_cpjson = strcat("cp "+temp_in_json+" "+temp_copy_json); %copy json file
                system(cmd_cpjson);
                fprintf(append(cmd_cpjson,'\n'));
            end
        end
    elseif any(ismember(fields(cfg),'nruns')) && ~isempty(cfg.nruns) %if nruns are targeted
        for r = 1:cfg.nruns
            if exist([cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',r) '_bold.nii.gz'], 'file') 
                temp_in_file = [cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',r) '_bold.nii.gz'];
                temp_copy_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',r) '_bold.nii.gz'];
                cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file if exists
                system(cmd_cpfile);
                fprintf(append(cmd_cpfile,'\n'));
                %also copy json - assuming consistent file names
                temp_in_json = [cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',r) '_bold.json'];
                temp_copy_json = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',r) '_bold.json'];
                cmd_cpjson = strcat("cp "+temp_in_json+" "+temp_copy_json); %copy json file
                system(cmd_cpjson);
                fprintf(append(cmd_cpjson,'\n'));
            end
        end
    elseif exist([cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-01_bold.nii.gz'], 'file')
        nb=1; %allow for single run label
        temp_in_file = [cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nb) '_bold.nii.gz'];
        temp_copy_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nb) '_bold.nii.gz'];
        cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file if exists
        system(cmd_cpfile);
        fprintf(append(cmd_cpfile,'\n'));
        %also copy json - assuming consistent file names
        temp_in_json = [cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nb) '_bold.json'];
        temp_copy_json = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nb) '_bold.json'];
        cmd_cpjson = strcat("cp "+temp_in_json+" "+temp_copy_json); %copy json file
        system(cmd_cpjson);
        fprintf(append(cmd_cpjson,'\n'));  
    elseif exist([cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_bold.nii.gz'], 'file')
        temp_in_file = [cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_bold.nii.gz'];
        temp_copy_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_bold.nii.gz'];
        cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file if exists
        system(cmd_cpfile);
        fprintf(append(cmd_cpfile,'\n'));
        %also copy json - assuming consistent file names
        temp_in_json = [cfg.tempfMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_bold.json'];
        temp_copy_json = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_bold.json'];
        cmd_cpjson = strcat("cp "+temp_in_json+" "+temp_copy_json); %copy json file
        system(cmd_cpjson);
        fprintf(append(cmd_cpjson,'\n'));       
    else 
        fprintf('Could not find fMRI file to copy. Check data!\n');
    end
    
    bnum = bnum+1;
    
end



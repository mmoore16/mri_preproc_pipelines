% B_copy_dMRI.m
%
% This script copies dMRI data to BIDS folders. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

%set batch number
bnum = 1;

for subj = 1:length(cfg.subjects)

    if ~exist([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi'], 'dir')
        mkdir([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi']); %create BIDS format folder
    end
    
    %move dMRI data to BIDS folders - checks for acq, run, OR dir     
    if any(ismember(fields(cfg),'acq')) && ~isempty(cfg.acq) && any(ismember(fields(cfg),'ndruns')) && ~isempty(cfg.ndruns) %if acquisitions AND runs are targeted - not currently supported!
        fprintf('Acquisition and Run fields are both specified - processing of both not currently supported. Check parameters!\n');
    elseif any(ismember(fields(cfg),'dir')) && ~isempty(cfg.dir) && any(ismember(fields(cfg),'ndruns')) && ~isempty(cfg.ndruns) %if directions AND runs are targeted - not currently supported!
        fprintf('Direction and Run fields are both specified - processing of both not currently supported. Check parameters!\n');
    elseif any(ismember(fields(cfg),'acq')) && ~isempty(cfg.acq) && any(ismember(fields(cfg),'dir')) && ~isempty(cfg.dir) %if acquisitions AND directions are targeted - not currently supported!
        fprintf('Acquisition and Direction fields are both specified - processing of both not currently supported. Check parameters!\n'); 
    elseif any(ismember(fields(cfg),'acq')) && ~isempty(cfg.acq) %if acquisitions are targeted
        for rr = 1:length(cfg.acq)
            if exist([cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{rr} '_dwi.nii.gz'], 'file')
                temp_in_file = [cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{rr} '_dwi.nii.gz'];
                temp_copy_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{rr} '_dwi.nii.gz'];
                cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file if exists
                system(cmd_cpfile);
                fprintf(append(cmd_cpfile,'\n'));
                %also copy json - assuming consistent file names
                temp_in_json = [cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{rr} '_dwi.json'];
                temp_copy_json = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{rr} '_dwi.json'];
                cmd_cpjson = strcat("cp "+temp_in_json+" "+temp_copy_json); %copy json file
                system(cmd_cpjson);
                fprintf(append(cmd_cpjson,'\n'));
                %also copy bvec - assuming consistent file names
                temp_in_bvec = [cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{rr} '_dwi.bvec'];
                temp_copy_bvec = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{rr} '_dwi.bvec'];
                cmd_cpbvec = strcat("cp "+temp_in_bvec+" "+temp_copy_bvec); %copy bvec file
                system(cmd_cpbvec);
                fprintf(append(cmd_cpbvec,'\n'));
                %also copy bval - assuming consistent file names
                temp_in_bval = [cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{rr} '_dwi.bval'];
                temp_copy_bval = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{rr} '_dwi.bval'];
                cmd_cpbval = strcat("cp "+temp_in_bval+" "+temp_copy_bval); %copy bval file
                system(cmd_cpbval);
                fprintf(append(cmd_cpbval,'\n'));
            end
        end
    elseif any(ismember(fields(cfg),'ndruns')) && ~isempty(cfg.ndruns) %if ndruns are targeted
        for r = 1:cfg.ndruns
            if exist([cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_run-' sprintf('%02d',r) '_dwi.nii.gz'], 'file') 
                temp_in_file = [cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_run-' sprintf('%02d',r) '_dwi.nii.gz'];
                temp_copy_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_run-' sprintf('%02d',r) '_dwi.nii.gz'];
                cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file if exists
                system(cmd_cpfile);
                fprintf(append(cmd_cpfile,'\n'));
                %also copy json - assuming consistent file names
                temp_in_json = [cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_run-' sprintf('%02d',r) '_dwi.json'];
                temp_copy_json = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_run-' sprintf('%02d',r) '_dwi.json'];
                cmd_cpjson = strcat("cp "+temp_in_json+" "+temp_copy_json); %copy json file
                system(cmd_cpjson);
                fprintf(append(cmd_cpjson,'\n'));
                %also copy bvec - assuming consistent file names
                temp_in_bvec = [cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_run-' sprintf('%02d',r) '_dwi.bvec'];
                temp_copy_bvec = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_run-' sprintf('%02d',r) '_dwi.bvec'];
                cmd_cpbvec = strcat("cp "+temp_in_bvec+" "+temp_copy_bvec); %copy bvec file
                system(cmd_cpbvec);
                fprintf(append(cmd_cpbvec,'\n'));
                %also copy bval - assuming consistent file names
                temp_in_bval = [cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_run-' sprintf('%02d',r) '_dwi.bval'];
                temp_copy_bval = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_run-' sprintf('%02d',r) '_dwi.bval'];
                cmd_cpbval = strcat("cp "+temp_in_bval+" "+temp_copy_bval); %copy bval file
                system(cmd_cpbval);
                fprintf(append(cmd_cpbval,'\n'));
            end
        end
    elseif any(ismember(fields(cfg),'dir')) && ~isempty(cfg.dir) %if dirs are targeted
        for r = 1:length(cfg.dir)
            if exist([cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dir-' cfg.dir{r} '_dwi.nii.gz'], 'file') 
                temp_in_file = [cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dir-' cfg.dir{r} '_dwi.nii.gz'];
                temp_copy_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dir-' cfg.dir{r} '_dwi.nii.gz'];
                cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file if exists
                system(cmd_cpfile);
                fprintf(append(cmd_cpfile,'\n'));
                %also copy json - assuming consistent file names
                temp_in_json = [cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dir-' cfg.dir{r} '_dwi.json'];
                temp_copy_json = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dir-' cfg.dir{r} '_dwi.json'];
                cmd_cpjson = strcat("cp "+temp_in_json+" "+temp_copy_json); %copy json file
                system(cmd_cpjson);
                fprintf(append(cmd_cpjson,'\n'));
                %also copy bvec - assuming consistent file names
                temp_in_bvec = [cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dir-' cfg.dir{r} '_dwi.bvec'];
                temp_copy_bvec = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dir-' cfg.dir{r} '_dwi.bvec'];
                cmd_cpbvec = strcat("cp "+temp_in_bvec+" "+temp_copy_bvec); %copy bvec file
                system(cmd_cpbvec);
                fprintf(append(cmd_cpbvec,'\n'));
                %also copy bval - assuming consistent file names
                temp_in_bval = [cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dir-' cfg.dir{r} '_dwi.bval'];
                temp_copy_bval = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dir-' cfg.dir{r} '_dwi.bval'];
                cmd_cpbval = strcat("cp "+temp_in_bval+" "+temp_copy_bval); %copy bvec file
                system(cmd_cpbval);
                fprintf(append(cmd_cpbval,'\n'));
            end
        end
    elseif exist([cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.nii.gz'], 'file')
        temp_in_file = [cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.nii.gz'];
        temp_copy_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.nii.gz'];
        cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file if exists
        system(cmd_cpfile);
        fprintf(append(cmd_cpfile,'\n'));
        %also copy json - assuming consistent file names
        temp_in_json = [cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.json'];
        temp_copy_json = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.json'];
        cmd_cpjson = strcat("cp "+temp_in_json+" "+temp_copy_json); %copy json file
        system(cmd_cpjson);
        fprintf(append(cmd_cpjson,'\n'));
        %also copy bvec - assuming consistent file names
        temp_in_bvec = [cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.bvec'];
        temp_copy_bvec = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.bvec'];
        cmd_cpbvec = strcat("cp "+temp_in_bvec+" "+temp_copy_bvec); %copy bvec file
        system(cmd_cpbvec);
        fprintf(append(cmd_cpbvec,'\n'));
        %also copy bval - assuming consistent file names
        temp_in_bval = [cfg.tempdMRIloc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.bval'];
        temp_copy_bval = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.bval'];
        cmd_cpbval = strcat("cp "+temp_in_bval+" "+temp_copy_bval); %copy bval file
        system(cmd_cpbval);
        fprintf(append(cmd_cpbval,'\n'));        
    else 
        fprintf('Could not find dwi file to copy. Check data!\n');
    end
    
    bnum = bnum+1;
    
end



% C_organize_data.m
%
% This script organizes and/or combines data. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

%set batch number
bnum = 1;

for subj = 1:length(cfg.subjects)

    if ~exist([cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func'], 'dir')
        mkdir([cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func']); %create BIDS format fMRI folder
    end

    runs = {};
    templist = [];
    temp_acqp = {};
    jsontemplist = [];
    %tempfiles = {};
    %jsontempfiles = {};

    if any(ismember(fields(cfg),'acq')) && ~isempty(cfg.acq) && any(ismember(fields(cfg),'nruns')) && any(gt(cfg.nruns,1)) %if acquisitions AND multiple runs are targeted - not currently supported!
        fprintf('Acquisition field and multiple runs are specified - processing of both not currently supported. Check parameters!\n');
    elseif any(ismember(fields(cfg),'dir')) && ~isempty(cfg.dir) && any(ismember(fields(cfg),'nruns')) && any(gt(cfg.nruns,1)) %if directions AND multiple runs are targeted - not currently supported!
        fprintf('Direction field and multiple runs are specified - processing of both not currently supported. Check parameters!\n');
    elseif any(ismember(fields(cfg),'acq')) && ~isempty(cfg.acq) && any(ismember(fields(cfg),'dir')) && ~isempty(cfg.dir) %if acquisitions AND directions are targeted - not currently supported!
        fprintf('Acquisition and Direction fields are both specified - processing of both not currently supported. Check parameters!\n');       
    elseif any(ismember(fields(cfg),'acq')) && ~isempty(cfg.acq) %if acquisitions are targeted
        for acq=1:length(cfg.acq) 
            nb=1; %allow for single run label
            % Get the full file path and names for each subject
            if exist([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_acq-' cfg.acq{acq} '_bold.nii.gz'], 'file');
                tempfiles = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_acq-' cfg.acq{acq} '_bold.nii.gz'];
                jsontempfiles = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_acq-' cfg.acq{acq} '_bold.json'];
            elseif exist([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_acq-' cfg.acq{acq} '_run-' sprintf('%02d',nb) '_bold.nii.gz'], 'file');
                tempfiles = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_acq-' cfg.acq{acq} '_run-' sprintf('%02d',nb) '_bold.nii.gz'];
                jsontempfiles = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_acq-' cfg.acq{acq} '_run-' sprintf('%02d',nb) '_bold.json'];
            end
            templist = [templist,cellstr(tempfiles)];
            temp_in_files = join(cellfun(@string,templist)); %list out all input bold.nii.gz
            temp_in_file = char(templist{acq}); %select specific bold.nii.gz 
            % Get the imaging parameters from the json file
            jsontemplist = [jsontemplist,cellstr(jsontempfiles)];
            jsontemplist2 = cat(1,jsontemplist{acq});
            fid = fopen(jsontemplist2); 
            raw = fread(fid,inf);
            str = char(raw'); 
            fclose(fid); 
            val{acq} = jsondecode(str);
            cellcheck = isequaln(val{1,1}, val{1,acq}); %check if parameters are identical
            if acq>1 && cellcheck ~= 1 %when acq number is greater than 1 and parameters are not identical
                for acqr=2:length(cfg.acq)
                    fprintf('Checking specific parameters in json files.\n');
                    cellcheck1 = isequaln(val{1,1}.PhaseEncodingDirection, val{1,acqr}.PhaseEncodingDirection);
                    if cellcheck1 ~= 1 %when phase encoding parameters are not identical
                        fprintf('Phase encoding does not match! If expecting opposing directions, this check is consistent with that (double-check acq_param.txt to confirm).\n');
                    end  
                    cellcheck2 = isequaln(val{1,1}.TotalReadoutTime, val{1,acqr}.TotalReadoutTime);
                    if cellcheck2 == 1 %when readout time parameters are identical
                        fprintf('Confirmed total readout time matches!\n');
                    end 
                end
            elseif acq>1 && cellcheck == 1 %when parameters are identical (fully matching unlikely if fields with info such as run numbers preserved)
                fprintf('Confirmed json files appear to match! If expecting opposite phase acquisitions, check data!\n');
            end 
        end
        %rename fMRI
        if length(cfg.acq) == 1 || cfg.nacq_specific == 1 %analyze specific acq? 1=yes
            nn=1; %relabel as single run
            %rename bold files
            temp_in_acq = char(templist{cfg.nacq_index}); %select specific bold.nii.gz acq
            temp_out_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nn) '_bold.nii.gz'];
            cmd_cp_bold = strcat("cp "+temp_in_acq+" "+temp_out_file); %rename bold file
            system(cmd_cp_bold);
            %rename json files
            temp_in_jsonacq = char(jsontemplist{cfg.nacq_index}); %select specific bold.json acq
            temp_out_jsonfile = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nn) '_bold.json'];
            cmd_cp_jsonfile = strcat("cp "+temp_in_jsonacq+" "+temp_out_jsonfile); %rename bold.json file
            system(cmd_cp_jsonfile);
            %copy .nii.gz file to derivatives folder and unzip
            temp_cp_gz = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep];
            cmd_cpgz = strcat("cp "+temp_out_file+" "+temp_cp_gz); %copy gz file
            system(cmd_cpgz);
            temp_out_gz_file = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nn) '_bold.nii.gz'];
            gunzip(temp_out_gz_file); %gunzip .nii.gz file
            system([strcat("rm -rf "+temp_out_gz_file)]); %remove zip file 
        elseif cfg.nacq_specific == 0 %analyze specific acq? 0=no->label as multiple runs
            for acq=1:length(cfg.acq)
                %rename bold files
                temp_in_file = char(templist{acq}); %select bold.nii.gz acq 
                temp_out_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',acq) '_bold.nii.gz'];
                cmd_bold = strcat("cp "+temp_in_file+" "+temp_out_file); %rename bold file
                system(cmd_bold);
                %rename json files
                temp_in_jsonacq = char(jsontemplist{acq}); %select bold.json acq
                temp_out_jsonfile = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',acq) '_bold.json'];
                cmd_jsonfile = strcat("cp "+temp_in_jsonacq+" "+temp_out_jsonfile); %rename bold.json file
                system(cmd_jsonfile);
                %copy .nii.gz file to derivatives folder and unzip
                temp_cp_gz = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep];
                cmd_cpgz = strcat("cp "+temp_out_file+" "+temp_cp_gz); %copy gz file
                system(cmd_cpgz);
                temp_out_gz_file = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',acq) '_bold.nii.gz'];
                gunzip(temp_out_gz_file); %gunzip .nii.gz file
                system([strcat("rm -rf "+temp_out_gz_file)]); %remove zip file 
            end
        else
            fprintf('Parameter specifying which fMRI acqs to process/analyze not set correctly. Check cfg!\n');
        end    
    elseif any(ismember(fields(cfg),'dir')) && ~isempty(cfg.dir) %if dirs are targeted
        for d=1:length(cfg.dir) 
            nb=1; %allow for single run label
            % Get the full file path and names for each subject
            if exist([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_dir-' cfg.dir{d} '_bold.nii.gz'], 'file')
                tempfiles = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_dir-' cfg.dir{d} '_bold.nii.gz'];
                jsontempfiles = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_dir-' cfg.dir{d} '_bold.json'];
            elseif exist([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_dir-' cfg.dir{d} '_run-' sprintf('%02d',nb) '_bold.nii.gz'], 'file')
                tempfiles = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_dir-' cfg.dir{d} '_run-' sprintf('%02d',nb) '_bold.nii.gz'];
                jsontempfiles = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_dir-' cfg.dir{d} '_run-' sprintf('%02d',nb) '_bold.json'];
            end
            templist = [templist,cellstr(tempfiles)];
            temp_in_files = join(cellfun(@string,templist)); %list out all input bold.nii.gz
            temp_in_file = char(templist{d}); %select specific bold.nii.gz
            % Get the imaging parameters from the json file
            jsontemplist = [jsontemplist,cellstr(jsontempfiles)];
            jsontemplist2 = cat(1,jsontemplist{d});
            fid = fopen(jsontemplist2); 
            raw = fread(fid,inf); 
            str = char(raw'); 
            fclose(fid); 
            val{d} = jsondecode(str);
            cellcheck = isequaln(val{1,1}, val{1,d}); %check if parameters are identical
            if d>1 && cellcheck ~= 1 %when dir number is greater than 1 and parameters are not identical
                for dd=2:length(cfg.dir)
                    fprintf('Checking specific parameters in json files.\n');
                    cellcheck1 = isequaln(val{1,1}.PhaseEncodingDirection, val{1,dd}.PhaseEncodingDirection);
                    if cellcheck1 ~= 1 %when phase encoding parameters are not identical
                        fprintf('Phase encoding does not match! If expecting opposing directions, this check is consistent with that (double-check acq_param.txt to confirm).\n');
                    end  
                    cellcheck2 = isequaln(val{1,1}.TotalReadoutTime, val{1,dd}.TotalReadoutTime);
                    if cellcheck2 == 1 %when readout time parameters are identical
                        fprintf('Confirmed total readout time matches!\n');
                    end 
                end
            elseif d>1 && cellcheck == 1 %when parameters are identical (fully matching unlikely if fields with info such as run numbers preserved)
                fprintf('Confirmed json files appear to match! If expecting opposite phase acquisitions, check data!\n');
            end       
        end
        %rename fMRI
        if length(cfg.dir) == 1 || cfg.ndir_specific == 1 %analyze specific direction? 1=yes
            nn=1; %relabel as single run
            %rename bold files
            temp_in_dir = char(templist{cfg.ndir_index}); %select specific bold.nii.gz            
            temp_out_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nn) '_bold.nii.gz'];
            cmd_cp_bold = strcat("cp "+temp_in_dir+" "+temp_out_file); %rename bold file
            system(cmd_cp_bold);
            %rename json files
            temp_in_jsondir = char(jsontemplist{cfg.ndir_index}); %select specific bold.json dir
            temp_out_jsonfile = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nn) '_bold.json'];
            cmd_cp_jsonfile = strcat("cp "+temp_in_jsondir+" "+temp_out_jsonfile); %rename bold.json file
            system(cmd_cp_jsonfile);
            %copy .nii.gz file to derivatives folder and unzip
            temp_cp_gz = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep];
            cmd_cpgz = strcat("cp "+temp_out_file+" "+temp_cp_gz); %copy gz file
            system(cmd_cpgz);
            temp_out_gz_file = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nn) '_bold.nii.gz'];
            gunzip(temp_out_gz_file); %gunzip .nii.gz file
            system([strcat("rm -rf "+temp_out_gz_file)]); %remove zip file 
        elseif cfg.ndir_specific == 0 %analyze specific dir? 0=no->label as multiple runs
            for d=1:length(cfg.dir)
                %rename bold files
                temp_in_file = char(templist{d}); %select bold.nii.gz dir
                temp_out_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',d) '_bold.nii.gz'];
                cmd_bold = strcat("cp "+temp_in_file+" "+temp_out_file); %rename bold file
                system(cmd_bold);
                %rename json files
                temp_in_jsondir = char(jsontemplist{acq}); %select bold.json dir
                temp_out_jsonfile = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',d) '_bold.json'];
                cmd_jsonfile = strcat("cp "+temp_in_jsondir+" "+temp_out_jsonfile); %rename bold.json file
                system(cmd_jsonfile);
                %copy .nii.gz file to derivatives folder and unzip
                temp_cp_gz = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep];
                cmd_cpgz = strcat("cp "+temp_out_file+" "+temp_cp_gz); %copy gz file
                system(cmd_cpgz);
                temp_out_gz_file = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',d) '_bold.nii.gz'];
                gunzip(temp_out_gz_file); %gunzip .nii.gz file
                system([strcat("rm -rf "+temp_out_gz_file)]); %remove zip file 
            end
        else
            fprintf('Parameter specifying which fMRI directions to process/analyze not set correctly. Check cfg!\n');
        end
    elseif any(ismember(fields(cfg),'nruns')) && ~isempty(cfg.nruns) %if nruns are targeted
        for run=1:cfg.nruns        
            % Get the full file path and names for each subject
            if exist([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',run) '_bold.nii.gz'], 'file')
                tempfiles = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',run) '_bold.nii.gz'];
                jsontempfiles = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',run) '_bold.json'];
            end
            templist = [templist,cellstr(tempfiles)];
            temp_in_files = join(cellfun(@string,templist)); %list out all input bold.nii.gz
            temp_in_file = char(templist{run}); %select specific bold.nii.gz 
            % Get the imaging parameters from the json file
            jsontemplist = [jsontemplist,cellstr(jsontempfiles)];
            jsontemplist2 = cat(1,jsontemplist{run});
            fid = fopen(jsontemplist2); 
            raw = fread(fid,inf); 
            str = char(raw'); 
            fclose(fid); 
            val{run} = jsondecode(str);
            cellcheck = isequaln(val{1,1}, val{1,run}); %check if parameters are identical
            if run>1 && cellcheck ~= 1 %when run number is greater than 1 and parameters are not identical
                for runr=2:cfg.nruns
                    fprintf('Checking specific parameters in json files.\n');
                    cellcheck1 = isequaln(val{1,1}.PhaseEncodingDirection, val{1,runr}.PhaseEncodingDirection);
                    if cellcheck1 ~= 1 %when phase encoding parameters are not identical
                        fprintf('Phase encoding does not match! If expecting opposing directions, this check is consistent with that (double-check acq_param.txt to confirm).\n');
                    end  
                    cellcheck2 = isequaln(val{1,1}.TotalReadoutTime, val{1,runr}.TotalReadoutTime);
                    if cellcheck2 == 1 %when readout time parameters are identical
                        fprintf('Confirmed total readout time matches!\n');
                    end 
                end
            elseif run>1 && cellcheck == 1 %when parameters are identical (fully matching unlikely if fields with info such as run numbers preserved)
                fprintf('Confirmed json files appear to match! If expecting opposite phase acquisitions, check data!\n');
            end          
        end
        %rename fMRI
        if cfg.nruns == 1 || cfg.nrun_specific == 1 %analyze specific run? 1=yes
            nn=1; %relabel as single run
            %rename bold files
            temp_in_run = char(templist{cfg.nrun_index}); %select specific bold.nii.gz            
            temp_out_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nn) '_bold.nii.gz'];
            if strcmp(temp_in_run,temp_out_file) == 0 %if file needs to be renamed
                cmd_cp_bold = strcat("cp "+temp_in_run+" "+temp_out_file); %rename bold file
                system(cmd_cp_bold);
            end
            %rename json files
            temp_in_jsonrun = char(jsontemplist{cfg.nrun_index}); %select specific bold.json run
            temp_out_jsonfile = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nn) '_bold.json'];
            if strcmp(temp_in_jsonrun,temp_out_jsonfile) == 0 %if file needs to be renamed
                cmd_cp_jsonfile = strcat("cp "+temp_in_jsonrun+" "+temp_out_jsonfile); %rename bold.json file
                system(cmd_cp_jsonfile);
            end
            %copy .nii.gz file to derivatives folder and unzip
            temp_cp_gz = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep];
            cmd_cpgz = strcat("cp "+temp_out_file+" "+temp_cp_gz); %copy gz file
            system(cmd_cpgz);
            temp_out_gz_file = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nn) '_bold.nii.gz'];
            gunzip(temp_out_gz_file); %gunzip .nii.gz file
            system([strcat("rm -rf "+temp_out_gz_file)]); %remove zip file 
        elseif cfg.nrun_specific == 0 %analyze specific run? 0=no->label as multiple runs
            for run=1:cfg.nruns
                %rename bold files
                temp_in_file = char(templist{run}); %select bold.nii.gz run
                temp_out_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',run) '_bold.nii.gz'];
                if strcmp(temp_in_file,temp_out_file) == 0 %if file needs to be renamed
                    cmd_bold = strcat("cp "+temp_in_file+" "+temp_out_file); %rename bold file
                    system(cmd_bold);
                end
                %rename json files
                temp_in_jsonrun = char(jsontemplist{run}); %select bold.json run
                temp_out_jsonfile = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',run) '_bold.json'];
                if strcmp(temp_in_jsonrun,temp_out_jsonfile) == 0 %if file needs to be renamed
                    cmd_jsonfile = strcat("cp "+temp_in_jsonrun+" "+temp_out_jsonfile); %rename bold.json file
                    system(cmd_jsonfile);
                end
                %copy .nii.gz file to derivatives folder and unzip
                temp_cp_gz = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep];
                cmd_cpgz = strcat("cp "+temp_out_file+" "+temp_cp_gz); %copy gz file
                system(cmd_cpgz);
                temp_out_gz_file = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',run) '_bold.nii.gz'];
                gunzip(temp_out_gz_file); %gunzip .nii.gz file
                system([strcat("rm -rf "+temp_out_gz_file)]); %remove zip file 
            end
        else
            fprintf('Parameter specifying which fMRI runs to process/analyze not set correctly. Check cfg!\n');
        end
    elseif exist([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_bold.nii.gz'], 'file') | exist([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-01_bold.nii.gz'], 'file')
        nb=1; %allow for single run label
        % Get the full file path and names for each subject
        if exist([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_bold.nii.gz'], 'file')
            temp_in_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_bold.nii.gz'];
            jsontemp = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_bold.json'];
        elseif exist([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nb) '_bold.nii.gz'], 'file')
            temp_in_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nb) '_bold.nii.gz'];
            jsontemp = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nb) '_bold.json'];
        end
        %rename bold files
        %only single run currently supported!
        temp_out_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nb) '_bold.nii.gz'];        
        temp_in_run = char(temp_in_file); %select specific bold.nii.gz
        if ~exist(temp_out_file, 'file')
            cmd_cp_bold = strcat("cp "+temp_in_run+" "+temp_out_file); %rename bold file
            system(cmd_cp_bold);
        end
        %rename json files
        temp_out_jsonfile = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nb) '_bold.json'];
        temp_in_jsonfile = char(jsontemp); %select specific json
        if ~exist(temp_out_jsonfile, 'file')
            cmd_cp_jsonfile = strcat("cp "+temp_in_jsonfile+" "+temp_out_jsonfile); %rename bold.json file
            system(cmd_cp_jsonfile);
        end
        %copy .nii.gz file to derivatives folder and unzip
        temp_cp_gz = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep];
        cmd_cpgz = strcat("cp "+temp_out_file+" "+temp_cp_gz); %copy gz file
        system(cmd_cpgz);
        temp_out_gz_file = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',nb) '_bold.nii.gz'];
        gunzip(temp_out_gz_file); %gunzip .nii.gz file
        system([strcat("rm -rf "+temp_out_gz_file)]); %remove zip file 
    end 
    
    bnum = bnum+1;
    
end

clearvars -except cfg; % clear variables except for cfg variables

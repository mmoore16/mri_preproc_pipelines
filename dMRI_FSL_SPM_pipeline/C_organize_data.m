% C_organize_data.m
%
% This script calls FSL tools to organize dMRI data. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

%set batch number
bnum = 1;

for subj = 1:length(cfg.subjects)

    if ~exist([cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi'], 'dir')
        mkdir([cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi']); %create BIDS format dMRI folder
    end

    runs = {};
    templist = [];
    temp_acqp = {};
    jsontemplist = [];

    temp_out_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.nii.gz']; %output combined dwi file
    temp_out_file_bvec = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.bvec']; %output combined dwi bvec file
    temp_out_file_bval = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.bval']; %output combined dwi bval file
    temp_out_file_acq = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq_param.txt']; %output acq_param file
    temp_out_file_b0s = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_b0s.nii.gz']; %output b0s file

    if any(ismember(fields(cfg),'acq')) && ~isempty(cfg.acq) && any(ismember(fields(cfg),'ndruns')) && ~isempty(cfg.ndruns) %if acquisitions AND runs are targeted - not currently supported!
        fprintf('Acquisition and Run fields are both specified - processing of both not currently supported. Check parameters!\n');
    elseif any(ismember(fields(cfg),'dir')) && ~isempty(cfg.dir) && any(ismember(fields(cfg),'ndruns')) && ~isempty(cfg.ndruns) %if directions AND runs are targeted - not currently supported!
        fprintf('Direction and Run fields are both specified - processing of both not currently supported. Check parameters!\n');
    elseif any(ismember(fields(cfg),'acq')) && ~isempty(cfg.acq) && any(ismember(fields(cfg),'dir')) && ~isempty(cfg.dir) %if acquisitions AND directions are targeted - not currently supported!
        fprintf('Acquisition and Direction fields are both specified - processing of both not currently supported. Check parameters!\n');        
    elseif any(ismember(fields(cfg),'acq')) && ~isempty(cfg.acq) %if acquisitions are targeted
        for acq=1:length(cfg.acq)        
            % Get the full file path and names for each subject
            folder = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi'];
            files = dir([folder filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{acq} '_dwi.nii.gz']); %dwi files
            for c = 1:length(files)
                fullpath{c}=[files(c).folder,filesep,files(c).name];
            end
            tempfiles{c} = fullpath';
            templist = [templist,tempfiles];
            temp_in_files = join(cellfun(@string,templist)); %list out all input dwi.nii.gz runs
            temp_in_files_bvec = strrep(temp_in_files,'.nii.gz','.bvec'); %assuming matching naming convention for .nii.gz and .bvec
            temp_in_files_bval = strrep(temp_in_files,'.nii.gz','.bval'); %assuming matching naming convention for .nii.gz and .bval
            temp_in_files_b0s = strrep(temp_in_files,'.nii.gz','_b0.nii.gz'); %assuming matching naming convention for .nii.gz and _b0.nii.gz
            temp_in_file = char(templist{acq}); %select specific dwi.nii.gz run for b0 extraction
            temp_b0_file = strrep(temp_in_file,'.nii.gz','_b0.nii.gz'); %assuming matching naming convention for .nii.gz and _b0.nii.gz
            % Get the imaging parameters from the json file
            jsonfolder = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi'];
            jsonfiles = dir([jsonfolder filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq-' cfg.acq{acq} '_dwi.json']);
            for c = 1:length(jsonfiles) 
                jsonfullpath{c}=[jsonfiles(c).folder,filesep,jsonfiles(c).name];
            end
            jsontempfiles{c} = jsonfullpath';
            jsontemplist = [jsontemplist,jsontempfiles];
            jsontemplist2 = cat(1,jsontemplist{acq});
            fid = fopen(jsontemplist2{c}); 
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
            %extract b0s from dMRI
            cmd_b0s = strcat("fslroi "+temp_in_file+" "+temp_b0_file+" 0 1"); %extract b0 from dMRI files
            system(cmd_b0s);
        end
        %combine or rename dMRI, bvecs, and bvals
        if length(cfg.acq) == 1 || cfg.ndacq_specific == 1 %analyze specific acq? 1=yes
            %rename dwi, bvec, and bval files
            temp_in_acq = char(templist{cfg.ndacq_index}); %select specific dwi.nii.gz acq
            temp_in_acq_bvec = strrep(temp_in_acq,'.nii.gz','.bvec'); %assuming matching naming convention for .nii.gz and .bvec
            temp_in_acq_bval = strrep(temp_in_acq,'.nii.gz','.bval'); %assuming matching naming convention for .nii.gz and .bval
            cmd_mv_dwi = strcat("cp "+temp_in_acq+" "+temp_out_file); %rename dwi file
            system(cmd_mv_dwi);
            cmd_mv_bvec = strcat("cp "+temp_in_acq_bvec+" "+temp_out_file_bvec); %rename bvec file
            system(cmd_mv_bvec);
            cmd_mv_bval = strcat("cp "+temp_in_acq_bval+" "+temp_out_file_bval); %rename bval file
            system(cmd_mv_bval);
        elseif cfg.ndacq_specific == 0 %analyze specific acq? 0=no->combined
            cmd_dwi = strcat("fslmerge -t "+temp_out_file+" "+temp_in_files); %use fslmerge to combine multiple dwi acqs
            system(cmd_dwi);
            cmd_bvec = strcat("paste "+temp_in_files_bvec+" > "+temp_out_file_bvec); %use paste to combine multiple dwi acq bvec files
            system(cmd_bvec);
            cmd_bval = strcat("paste "+temp_in_files_bval+" > "+temp_out_file_bval); %use paste to combine multiple dwi acq bval files
            system(cmd_bval);
        else
            fprintf('Parameter specifying which dMRI acqs to process/analyze not set correctly. Check cfg!\n');
        end
        %combine b0s if more than one run
        if length(cfg.acq) > 1 %if more than one acq
            cmd_b0merge = strcat("fslmerge -t "+temp_out_file_b0s+" "+temp_in_files_b0s); %merge b0 files
            system(cmd_b0merge);
        end    
        %use info from acqs to create acq_param file
        for acq=1:length(cfg.acq) 
            if val{1,acq}.PhaseEncodingDirection == 'j' %PhaseEncodingDirection: j means P-->A, 0 1 0
                temp_acqp{acq}=[0 1 0 val{1,acq}.TotalReadoutTime]; %encoding direction and readout time
            elseif val{1,acq}.PhaseEncodingDirection == 'j-' %PhaseEncodingDirection: j- means A-->P, 0 -1 0
                temp_acqp{acq}=[0 -1 0 val{1,acq}.TotalReadoutTime]; %encoding direction and readout time
            elseif val{1,acq}.PhaseEncodingDirection == '-j' %%PhaseEncodingDirection: -j means A-->P, 0 -1 0
                temp_acqp{acq}=[0 -1 0 val{1,acq}.TotalReadoutTime]; %encoding direction and readout time
            else fprintf('Error: Could not determine phase encoding direction from json files. Check data!\n');
            end
        end    
        %save acq_param.txt
        fid = fopen(temp_out_file_acq,'w'); %create acq_param.txt text file to write into
        fprintf(fid,'%d %d %d %1.6f\n',temp_acqp{:}); %print acq parameters into text file - assuming 1 digit before decimal and 6 digits after decimal for readout time
        fclose(fid); %close file
        %move individual b0s to derivatives folder
        for acq=1:length(cfg.acq) 
            %move b0 files to derivatives folder
            temp_in_b0_file = char(templist{acq}); %select specific dwi.nii.gz acq for b0 extraction
            temp_b0_file = strrep(temp_in_b0_file,'.nii.gz','_b0.nii.gz'); %assuming matching naming convention for .nii.gz and _b0.nii.gz
            temp_mv_b0 = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep];
            cmd_mvb0 = strcat("mv "+temp_b0_file+" "+temp_mv_b0); %move b0 file
            system(cmd_mvb0);
        end
    elseif any(ismember(fields(cfg),'ndruns')) && ~isempty(cfg.ndruns) %if ndruns are targeted
        for run=1:cfg.ndruns        
            % Get the full file path and names for each subject
            folder = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi'];
            files = dir([folder filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_run-' sprintf('%02d',run) '_dwi.nii.gz']); %dwi files
            for c = 1:length(files)
                fullpath{c}=[files(c).folder,filesep,files(c).name];
            end
            tempfiles{c} = fullpath';
            templist = [templist,tempfiles];
            temp_in_files = join(cellfun(@string,templist)); %list out all input dwi.nii.gz runs
            temp_in_files_bvec = strrep(temp_in_files,'.nii.gz','.bvec'); %assuming matching naming convention for .nii.gz and .bvec
            temp_in_files_bval = strrep(temp_in_files,'.nii.gz','.bval'); %assuming matching naming convention for .nii.gz and .bval
            temp_in_files_b0s = strrep(temp_in_files,'.nii.gz','_b0.nii.gz'); %assuming matching naming convention for .nii.gz and _b0.nii.gz
            temp_in_file = char(templist{run}); %select specific dwi.nii.gz run for b0 extraction
            temp_b0_file = strrep(temp_in_file,'.nii.gz','_b0.nii.gz'); %assuming matching naming convention for .nii.gz and _b0.nii.gz
            % Get the imaging parameters from the json file
            jsonfolder = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi'];
            jsonfiles = dir([jsonfolder filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_run-' sprintf('%02d',run) '_dwi.json']);
            for c = 1:length(jsonfiles) 
                jsonfullpath{c}=[jsonfiles(c).folder,filesep,jsonfiles(c).name];
            end
            jsontempfiles{c} = jsonfullpath';
            jsontemplist = [jsontemplist,jsontempfiles];
            jsontemplist2 = cat(1,jsontemplist{run});
            fid = fopen(jsontemplist2{c}); 
            raw = fread(fid,inf); 
            str = char(raw'); 
            fclose(fid); 
            val{run} = jsondecode(str);
            cellcheck = isequaln(val{1,1}, val{1,run}); %check if parameters are identical
            if run>1 && cellcheck ~= 1 %when run number is greater than 1 and parameters are not identical
                for runr=2:cfg.ndruns
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
            %extract b0s from dMRI
            cmd_b0s = strcat("fslroi "+temp_in_file+" "+temp_b0_file+" 0 1"); %extract b0 from dMRI files
            system(cmd_b0s);
        end
        %combine or rename dMRI, bvecs, and bvals
        if cfg.ndruns == 1 || cfg.ndrun_specific == 1 %analyze specific run? 1=yes
            %rename dwi, bvec, and bval files
            temp_in_run = char(templist{cfg.ndrun_index}); %select specific dwi.nii.gz run
            temp_in_run_bvec = strrep(temp_in_run,'.nii.gz','.bvec'); %assuming matching naming convention for .nii.gz and .bvec
            temp_in_run_bval = strrep(temp_in_run,'.nii.gz','.bval'); %assuming matching naming convention for .nii.gz and .bval
            cmd_mv_dwi = strcat("cp "+temp_in_run+" "+temp_out_file); %rename dwi file
            system(cmd_mv_dwi);
            cmd_mv_bvec = strcat("cp "+temp_in_run_bvec+" "+temp_out_file_bvec); %rename bvec file
            system(cmd_mv_bvec);
            cmd_mv_bval = strcat("cp "+temp_in_run_bval+" "+temp_out_file_bval); %rename bval file
            system(cmd_mv_bval);
        elseif cfg.ndrun_specific == 0 %analyze specific run? 0=no->combined
            cmd_dwi = strcat("fslmerge -t "+temp_out_file+" "+temp_in_files); %use fslmerge to combine multiple dwi runs
            system(cmd_dwi);
            cmd_bvec = strcat("paste "+temp_in_files_bvec+" > "+temp_out_file_bvec); %use paste to combine multiple dwi run bvec files
            system(cmd_bvec);
            cmd_bval = strcat("paste "+temp_in_files_bval+" > "+temp_out_file_bval); %use paste to combine multiple dwi run bval files
            system(cmd_bval);
        else
            fprintf('Parameter specifying which dMRI runs to process/analyze not set correctly. Check cfg!\n');
        end
        %combine b0s if more than one run
        if cfg.ndruns > 1 %if more than one run
            cmd_b0merge = strcat("fslmerge -t "+temp_out_file_b0s+" "+temp_in_files_b0s); %merge b0 files
            system(cmd_b0merge);
        end    
        %use info from runs to create acq_param file
        for run=1:cfg.ndruns
            if val{1,run}.PhaseEncodingDirection == 'j' %PhaseEncodingDirection: j means P-->A, 0 1 0
                temp_acqp{run}=[0 1 0 val{1,run}.TotalReadoutTime]; %encoding direction and readout time
            elseif val{1,run}.PhaseEncodingDirection == 'j-' %PhaseEncodingDirection: j- means A-->P, 0 -1 0
                temp_acqp{run}=[0 -1 0 val{1,run}.TotalReadoutTime]; %encoding direction and readout time
            elseif val{1,run}.PhaseEncodingDirection == '-j' %%PhaseEncodingDirection: -j means A-->P, 0 -1 0
                temp_acqp{run}=[0 -1 0 val{1,run}.TotalReadoutTime]; %encoding direction and readout time
            else fprintf('Error: Could not determine phase encoding direction from json files. Check data!\n');
            end
        end    
        %save acq_param.txt
        fid = fopen(temp_out_file_acq,'w'); %create acq_param.txt text file to write into
        fprintf(fid,'%d %d %d %1.6f\n',temp_acqp{:}); %print acq parameters into text file - assuming 1 digit before decimal and 6 digits after decimal for readout time
        fclose(fid); %close file
        %move individual b0s to derivatives folder
        for run=1:cfg.ndruns
            %move b0 files to derivatives folder
            temp_in_b0_file = char(templist{run}); %select specific dwi.nii run for b0 extraction
            temp_b0_file = strrep(temp_in_b0_file,'.nii.gz','_b0.nii.gz'); %assuming matching naming convention for .nii.gz and _b0.nii.gz
            temp_mv_b0 = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep];
            cmd_mvb0 = strcat("mv "+temp_b0_file+" "+temp_mv_b0); %move b0 file
            system(cmd_mvb0);
        end
    elseif any(ismember(fields(cfg),'dir')) && ~isempty(cfg.dir) %if dirs are targeted
        for d=1:length(cfg.dir)        
            % Get the full file path and names for each subject
            folder = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi'];
            files = dir([folder filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dir-' cfg.dir{d} '_dwi.nii.gz']); %dwi files
            for c = 1:length(files)
                fullpath{c}=[files(c).folder,filesep,files(c).name];
            end
            tempfiles{c} = fullpath';
            templist = [templist,tempfiles];
            temp_in_files = join(cellfun(@string,templist)); %list out all input dwi.nii.gz runs
            temp_in_files_bvec = strrep(temp_in_files,'.nii.gz','.bvec'); %assuming matching naming convention for .nii.gz and .bvec
            temp_in_files_bval = strrep(temp_in_files,'.nii.gz','.bval'); %assuming matching naming convention for .nii.gz and .bval
            temp_in_files_b0s = strrep(temp_in_files,'.nii.gz','_b0.nii.gz'); %assuming matching naming convention for .nii.gz and _b0.nii.gz
            temp_in_file = char(templist{d}); %select specific dwi.nii.gz dir for b0 extraction
            temp_b0_file = strrep(temp_in_file,'.nii.gz','_b0.nii.gz'); %assuming matching naming convention for .nii.gz and _b0.nii.gz
            % Get the imaging parameters from the json file
            jsonfolder = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi'];
            jsonfiles = dir([jsonfolder filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dir-' cfg.dir{d} '_dwi.json']);
            for c = 1:length(jsonfiles) 
                jsonfullpath{c}=[jsonfiles(c).folder,filesep,jsonfiles(c).name];
            end
            jsontempfiles{c} = jsonfullpath';
            jsontemplist = [jsontemplist,jsontempfiles];
            jsontemplist2 = cat(1,jsontemplist{d});
            fid = fopen(jsontemplist2{c}); 
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
            %extract b0s from dMRI
            cmd_b0s = strcat("fslroi "+temp_in_file+" "+temp_b0_file+" 0 1"); %extract b0 from dMRI files
            system(cmd_b0s);
        end
        %combine or rename dMRI, bvecs, and bvals
        if length(cfg.dir) == 1 || cfg.ndir_specific == 1 %analyze specific direction? 1=yes
            %rename dwi, bvec, and bval files
            temp_in_dir = char(templist{cfg.ndir_index}); %select specific dwi.nii.gz dir
            temp_in_dir_bvec = strrep(temp_in_dir,'.nii.gz','.bvec'); %assuming matching naming convention for .nii.gz and .bvec
            temp_in_dir_bval = strrep(temp_in_dir,'.nii.gz','.bval'); %assuming matching naming convention for .nii.gz and .bval
            cmd_mv_dwi = strcat("cp "+temp_in_dir+" "+temp_out_file); %rename dwi file
            system(cmd_mv_dwi);
            cmd_mv_bvec = strcat("cp "+temp_in_dir_bvec+" "+temp_out_file_bvec); %rename bvec file
            system(cmd_mv_bvec);
            cmd_mv_bval = strcat("cp "+temp_in_dir_bval+" "+temp_out_file_bval); %rename bval file
            system(cmd_mv_bval);
        elseif cfg.ndir_specific == 0 %analyze specific dir? 0=no->combined
            cmd_dwi = strcat("fslmerge -t "+temp_out_file+" "+temp_in_files); %use fslmerge to combine multiple dwi runs
            system(cmd_dwi);
            cmd_bvec = strcat("paste "+temp_in_files_bvec+" > "+temp_out_file_bvec); %use paste to combine multiple dwi run bvec files
            system(cmd_bvec);
            cmd_bval = strcat("paste "+temp_in_files_bval+" > "+temp_out_file_bval); %use paste to combine multiple dwi run bval files
            system(cmd_bval);
        else
            fprintf('Parameter specifying which dMRI directions to process/analyze not set correctly. Check cfg!\n');
        end
        %combine b0s if more than one run
        if length(cfg.dir) > 1 %if more than one dir
            cmd_b0merge = strcat("fslmerge -t "+temp_out_file_b0s+" "+temp_in_files_b0s); %merge b0 files
            system(cmd_b0merge);
        end    
        %use info from directions to create acq_param file
        for d=1:length(cfg.dir)
            if val{1,d}.PhaseEncodingDirection == 'j' %PhaseEncodingDirection: j means P-->A, 0 1 0
                temp_acqp{d}=[0 1 0 val{1,d}.TotalReadoutTime]; %encoding direction and readout time
            elseif val{1,d}.PhaseEncodingDirection == 'j-' %PhaseEncodingDirection: j- means A-->P, 0 -1 0
                temp_acqp{d}=[0 -1 0 val{1,d}.TotalReadoutTime]; %encoding direction and readout time
            elseif val{1,d}.PhaseEncodingDirection == '-j' %%PhaseEncodingDirection: -j means A-->P, 0 -1 0
                temp_acqp{d}=[0 -1 0 val{1,d}.TotalReadoutTime]; %encoding direction and readout time
            else fprintf('Error: Could not determine phase encoding direction from json files. Check data!\n');
            end
        end    
        %save acq_param.txt
        fid = fopen(temp_out_file_acq,'w'); %create acq_param.txt text file to write into
        fprintf(fid,'%d %d %d %1.6f\n',temp_acqp{:}); %print acq parameters into text file - assuming 1 digit before decimal and 6 digits after decimal for readout time
        fclose(fid); %close file
        %move individual b0s to derivatives folder
        for d=1:length(cfg.dir)
            %move b0 files to derivatives folder
            temp_in_b0_file = char(templist{d}); %select specific dwi.nii.gz dir for b0 extraction
            temp_b0_file = strrep(temp_in_b0_file,'.nii.gz','_b0.nii.gz'); %assuming matching naming convention for .nii.gz and _b0.nii.gz
            temp_mv_b0 = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep];
            cmd_mvb0 = strcat("mv "+temp_b0_file+" "+temp_mv_b0); %move b0 file
            system(cmd_mvb0);
        end
    elseif exist([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.nii.gz'], 'file')
        % Get the full file path and names for each subject        
        temp_in_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.nii.gz'];
        temp_in_files_bvec = strrep(temp_in_file,'.nii.gz','.bvec'); %assuming matching naming convention for .nii.gz and .bvec
        temp_in_files_bval = strrep(temp_in_file,'.nii.gz','.bval'); %assuming matching naming convention for .nii.gz and .bval
        temp_in_files_b0s = strrep(temp_in_file,'.nii.gz','_b0.nii.gz'); %assuming matching naming convention for .nii.gz and _b0.nii.gz
        temp_b0_file = strrep(temp_in_file,'.nii.gz','_b0.nii.gz'); %assuming matching naming convention for .nii.gz and _b0.nii.gz
        % Get the imaging parameters from the json file
        jsontemp = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.json'];
        fid = fopen(jsontemp); 
        raw = fread(fid,inf); 
        str = char(raw'); 
        fclose(fid); 
        val{1} = jsondecode(str);
        %extract b0s from dMRI
        cmd_b0s = strcat("fslroi "+temp_in_file+" "+temp_b0_file+" 0 1"); %extract b0 from dMRI files
        system(cmd_b0s);
        %rename dwi, bvec, and bval files
        temp_in_run = char(temp_in_file); %select specific dwi.nii.gz run
        temp_in_run_bvec = strrep(temp_in_run,'.nii.gz','.bvec'); %assuming matching naming convention for .nii.gz and .bvec
        temp_in_run_bval = strrep(temp_in_run,'.nii.gz','.bval'); %assuming matching naming convention for .nii.gz and .bval
        if ~exist(temp_out_file, 'file')
            cmd_mv_dwi = strcat("cp "+temp_in_run+" "+temp_out_file); %rename dwi file
            system(cmd_mv_dwi);
        end
        if ~exist(temp_out_file_bvec, 'file')
            cmd_mv_bvec = strcat("cp "+temp_in_run_bvec+" "+temp_out_file_bvec); %rename bvec file
            system(cmd_mv_bvec);
        end
        if ~exist(temp_out_file_bval, 'file')
            cmd_mv_bval = strcat("cp "+temp_in_run_bval+" "+temp_out_file_bval); %rename bval file
            system(cmd_mv_bval);
        end
        %use info from runs to create acq_param file
        if val{1,1}.PhaseEncodingDirection == 'j' %PhaseEncodingDirection: j means P-->A, 0 1 0
            temp_acqp{1}=[0 1 0 val{1,1}.TotalReadoutTime]; %encoding direction and readout time
        elseif val{1,1}.PhaseEncodingDirection == 'j-' %PhaseEncodingDirection: j- means A-->P, 0 -1 0
            temp_acqp{1}=[0 -1 0 val{1,1}.TotalReadoutTime]; %encoding direction and readout time
        elseif val{1,1}.PhaseEncodingDirection == '-j' %%PhaseEncodingDirection: -j means A-->P, 0 -1 0
            temp_acqp{1}=[0 -1 0 val{1,1}.TotalReadoutTime]; %encoding direction and readout time
        else fprintf('Error: Could not determine phase encoding direction from json files. Check data!\n');
        end
        %save acq_param.txt
        fid = fopen(temp_out_file_acq,'w'); %create acq_param.txt text file to write into
        fprintf(fid,'%d %d %d %1.6f\n',temp_acqp{:}); %print acq parameters into text file - assuming 1 digit before decimal and 6 digits after decimal for readout time
        fclose(fid); %close file
        %move b0 file to derivatives folder
        temp_in_b0_file = char(temp_in_file); %select dwi.nii for b0 extraction
        temp_b0_file = strrep(temp_in_b0_file,'.nii.gz','_b0.nii.gz'); %assuming matching naming convention for .nii.gz and _b0.nii.gz
        temp_mv_b0 = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep];
        cmd_mvb0 = strcat("mv "+temp_b0_file+" "+temp_mv_b0); %move b0 file
        system(cmd_mvb0);
    end 
    
    bnum = bnum+1;
    
end

clearvars -except cfg; % clear variables except for cfg variables

% H_art_outliers.m
%
% This script performs outlier detection and motion scrubbing using art toolbox. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

%set batch number
bnum = 1;

for subj = 1:length(cfg.subjects)

    runs = {};
    templist = [];
    mottemplist = [];
    for r=1:cfg.nruns
        vols = {};
        
        % Get the full file path and names for each subject
        folder = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func'];
        files = dir([folder filesep 'a' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',r) '_bold.nii']); %inputs are spatially and temporally realigned files
        for c = 1:length(files)
            if c >1
                fprintf('more than one nii file found matching run, check that files are correct!');
            end            
            fullpath{c}=[files(c).folder,filesep,files(c).name];
        end
        tempfiles{c} = fullpath';
        templist = [templist,tempfiles];
        templist2 = cat(1,templist{r});
        vols = spm_select('expand', templist2); %select all frames from 4D file
        runs{r} = vols;
        
        % Get the motion parameters from the spm .txt file
        motfolder = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func'];
        motfiles = dir([folder filesep 'rp_dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',r) '_bold.txt']); %inputs are spaital realignment files from spm
        for c = 1:length(motfiles)
            if c >1
                fprintf('more than one txt file found matching run, check that files are correct!');
            end            
            motfullpath{c}=[motfiles(c).folder,filesep,motfiles(c).name];
        end
        mottempfiles{c} = motfullpath';
        mottemplist = [mottemplist,mottempfiles];
        mottemplist2 = cat(1,mottemplist{r});
        motruns{r} = mottemplist2;       
        
    end
    
    for r=1:cfg.nruns
        %batch.P                   : batch.P{nses} [char] functional filename(s) for session nses
        batch.P{r} = char(runs{r});
        %batch.M                   : batch.M{nses} [char] realignment filename for session nses
        batch.M{r} = char(motruns{r});
        %batch.global_threshold    : global BOLD signal threshold (z-score)
        batch.global_threshold = cfg.artg;
        %batch.motion_threshold    : motion threshold(s)
        batch.motion_threshold = cfg.artm;
        %batch.use_diff_motion     : 1/0 use scan-to-scan differences in motion parameters
        batch.use_diff_motion = cfg.artdiffm;
        %batch.use_diff_global     : 1/0 use scan-to-scan differences in global BOLD signal
        batch.use_diff_global = cfg.artdiffg;
        %batch.use_norms           : 1/0 use motion composite measure
        batch.use_norms = cfg.artn;
        %batch.drop_flag           : number of initial scans to flag as outliers (removal of initial scans)
        batch.drop_flag = 0;
        %batch.motion_file_type    : indicates type of realignment file (0: SPM rp_*.txt file; 1: FSL .par file; 2: Siemens .txt file; 3: .txt SPM-format but rotation parameters in degrees)
        batch.motion_file_type = 0;
        %batch.close               : 1/0 close gui
        batch.close = 0; %seems to throw error if set to 1, using fclose/close all instead
        %batch.print               : 1/0 print gui
        batch.print = 0; %usually print the gui, but for permissions issue skipping this
        %batch.output_dir          : directory for output files (default same folder as first-session functional files)
        %batch.output_dir = char([cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func']);
        batch.output_dir = char([cfg.outputDirTemp]); %temporary location for files with appropriate permissions - not sure what the permission issue is here?
        %art('sess_file','filename.cfg');
        art('sess_file',batch);
        % close all opened windows, because art toolbox is opening a new one everytime
        fclose all; %close all open files
        close all; %close all open figures
    end
    
    bnum = bnum+1;
    
end

%On some systems the art code seems to have permission issues that other tools do not? For now creating files to temp location and then moving them.
for subj = 1:length(cfg.subjects)
    for r=1:cfg.nruns
        [status,msg,msgID] = movefile([cfg.outputDirTemp 'art_mask_a' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-rest_run-' sprintf('%02d',r) '_bold.nii'], [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func']);
        [status,msg,msgID] = movefile([cfg.outputDirTemp 'art_mean_a' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-rest_run-' sprintf('%02d',r) '_bold.nii'], [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func']);
    end    
end


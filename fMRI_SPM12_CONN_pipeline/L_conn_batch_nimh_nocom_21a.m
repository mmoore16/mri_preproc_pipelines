% L_conn_batch_wriisc_21a.m
%
% This script runs the conn toolbox on preprocessed fMRI data. 
% Some sections developed from code originally created by Alfonso Nieto-Castanon and adapted by Andrew Jahn.
%
% load a cfg.mat that has relevant parameters for data processing
[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
load([filepath filesep filename]);

%update subject list if some subjects removed (e.g., incomplete data, errors)
cfg.subjects = {}; %subjects following BIDS format
cfg.sessions = {}; %time points following BIDS format - must match/correspond with subject list!
cfg.outputDirBIDSfc  = [filesep 'path_to' filesep 'user' filesep 'Data' filesep 'nimh' filesep 'bids' filesep 'derivatives' filesep 'conn_21a' filesep]; % subfolder where preprocessed fMRI data are separated by subjects for connectivity analysis
if ~exist([cfg.outputDirBIDSfc], 'dir')
       mkdir([cfg.outputDirBIDSfc]); %BIDS format fMRI 
end

%Add relevant paths for spm12 and toolboxes
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'spm12']);
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'spm12' filesep 'matlabbatch']);
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'spm12' filesep 'config']);
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'spm12' filesep 'toolbox' filesep 'DARTEL']);
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'spm12' filesep 'toolbox' filesep 'DAiSS']);
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'spm12' filesep 'toolbox' filesep 'FieldMap']);
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'spm12' filesep 'toolbox' filesep 'Longitudinal']);
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'spm12' filesep 'toolbox' filesep 'OldNorm']);
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'spm12' filesep 'toolbox' filesep 'OldSeg']);
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'spm12' filesep 'toolbox' filesep 'SRender']);
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'spm12' filesep 'toolbox' filesep 'TSSS']);
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'spm12' filesep 'toolbox' filesep 'cat12']);
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'spm12' filesep 'toolbox' filesep 'Shoot']);
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'spm12' filesep 'matlabbatch' filesep 'cfg_basicio']);
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'spm12' filesep 'toolbox' filesep 'DEM']);
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'auto_acpc_reorient']); %tools for automatically aligning images/coregistering between modalities
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'spmScripts']); %tools for setting center of mass for images, note that these are modified!
addpath([filesep 'home' filesep 'user' filesep 'Software' filesep 'spm12' filesep 'toolbox' filesep 'conn']);

clearvars -except cfg; % clear variables except for cfg variables

%set up TR from json files
temp_TR=[];
for subj = 1:length(cfg.subjects)
    runs = {};
    val = {};
    jsontemplist = [];
    for r=1:cfg.nruns
        % Get the imaging parameters from the json file
        jsonfolder = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func'];
        jsonfiles = dir([jsonfolder filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-rest_run-' sprintf('%02d',r) '_bold.json']);
        for c = 1:length(jsonfiles)
            if c >1
                fprintf('more than one json file found matching run, check that files are correct!');
            end  
            jsonfullpath{c}=[jsonfiles(c).folder,filesep,jsonfiles(c).name];
        end
        jsontempfiles{c} = jsonfullpath';
        jsontemplist = [jsontemplist,jsontempfiles];
        jsontemplist2 = cat(1,jsontemplist{r});
        fid = fopen(jsontemplist2{c}); 
        raw = fread(fid,inf); 
        str = char(raw'); 
        fclose(fid); 
        val{r} = jsondecode(str);
        cellcheck = isequaln(val{1,1}, val{1,r});
        if cellcheck ~= 1
            fprintf('json files do not match, check files!');
        end        
    end
    temp_TR = [temp_TR; val{1,r}.RepetitionTime];
end

%copy fMRI to CONN folder
for subj = 1:length(cfg.subjects)    
    for r=1:cfg.nruns
        if ~exist([cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func'], 'dir')
            mkdir([cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func']); %BIDS format fMRI 
        end
        %copy smoothed data from spm12 processing to conn derivatives folder
        temp_cp_file = [cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'swa' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-rest_run-' sprintf('%02d',r) '_bold.nii'];
        if ~exist(temp_cp_file, 'file')
            temp_in_file = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'swa' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-rest_run-' sprintf('%02d',r) '_bold.nii'];
            cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_cp_file); %copy file
            system(cmd_cpfile);
        end
        %copy unsmoothed data from spm12 processing to conn derivatives folder
        temp_cp_ufile = [cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'wa' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-rest_run-' sprintf('%02d',r) '_bold.nii'];
        if ~exist(temp_cp_ufile, 'file')
            temp_in_ufile = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'wa' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-rest_run-' sprintf('%02d',r) '_bold.nii'];
            cmd_cpufile = strcat("cp "+temp_in_ufile+" "+temp_cp_ufile); %copy file
            system(cmd_cpufile); 
        end
        %copy realignment files from spm12 processing to conn derivatives folder
        temp_cp_rfile = [cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'rp_dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-rest_run-' sprintf('%02d',r) '_bold.txt'];
        if ~exist(temp_cp_rfile, 'file')
            temp_in_rfile = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'rp_dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-rest_run-' sprintf('%02d',r) '_bold.txt'];
            cmd_cprfile = strcat("cp "+temp_in_rfile+" "+temp_cp_rfile); %copy file
            system(cmd_cprfile);
        end
        %copy art timeseries data from spm12 processing to conn derivatives folder
        temp_cp_tfile = [cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'art_regression_timeseries_a' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-rest_run-' sprintf('%02d',r) '_bold.mat'];
        if ~exist(temp_cp_tfile, 'file')
            temp_in_tfile = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'art_regression_timeseries_a' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-rest_run-' sprintf('%02d',r) '_bold.mat'];
            cmd_cptfile = strcat("cp "+temp_in_tfile+" "+temp_cp_tfile); %copy file
            system(cmd_cptfile);  
        end
        %copy art outlier data from spm12 processing to conn derivatives folder
        temp_cp_ofile = [cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'art_regression_outliers_a' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-rest_run-' sprintf('%02d',r) '_bold.mat'];
        if ~exist(temp_cp_ofile, 'file')
            temp_in_ofile = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'art_regression_outliers_a' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-rest_run-' sprintf('%02d',r) '_bold.mat'];
            cmd_cpofile = strcat("cp "+temp_in_ofile+" "+temp_cp_ofile); %copy file
            system(cmd_cpofile); 
        end
    end
end

%copy sMRI to CONN folder
for subj = 1:length(cfg.subjects)  
    if ~exist([cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat'], 'dir')
        mkdir([cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat']); %BIDS format fMRI 
    end
    %copy smri data from spm12 processing to conn derivatives folder
    temp_cp_sfile = [cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'wmsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii'];
    if ~exist(temp_cp_sfile, 'file')
        temp_in_sfile = [cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'wmsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii'];
        cmd_cpsfile = strcat("cp "+temp_in_sfile+" "+temp_cp_sfile); %copy file
        system(cmd_cpsfile);
    end
    %copy gm data from spm12 processing to conn derivatives folder
    temp_cp_gfile = [cfg.outputDirBIDSfc  'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'mwp1sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii'];
    if ~exist(temp_cp_gfile, 'file')        
        temp_in_gfile = [cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'mwp1sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii'];
        cmd_cpgfile = strcat("cp "+temp_in_gfile+" "+temp_cp_gfile); %copy file
        system(cmd_cpgfile);
    end
    %copy wm data from spm12 processing to conn derivatives folder
    temp_cp_wfile = [cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'mwp2sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii'];
    if ~exist(temp_cp_wfile, 'file')    
        temp_in_wfile = [cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'mwp2sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii'];
        cmd_cpwfile = strcat("cp "+temp_in_wfile+" "+temp_cp_wfile); %copy file
        system(cmd_cpwfile);
    end
    %copy csf data from spm12 processing to conn derivatives folder
    temp_cp_cfile = [cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'mwp3sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii'];
    if ~exist(temp_cp_cfile, 'file')    
        temp_in_cfile = [cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'mwp3sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii'];
        cmd_cpcfile = strcat("cp "+temp_in_cfile+" "+temp_cp_cfile); %copy file
        system(cmd_cpcfile);
    end
end

% CONN-SPECIFIC SECTION: RUNS PREPROCESSING/SETUP/DENOISING/ANALYSIS STEPS
% Prepares batch structure
clear batch;
batch.filename=fullfile(cfg.outputDirBIDSfc,'conn_analysis1.mat');            % New conn_*.mat experiment name

batch.parallel.N=0; %not using parallel processing

% SETUP step (using default values for most parameters, see help conn_batch to define non-default values - skipping preprocessing and assuming done with SPM12 scripts!)
% CONN Setup                                            % Default options (uses all ROIs in conn/rois/ directory); see conn_batch for additional options 
batch.Setup.isnew=1; % is this a new conn project
batch.Setup.done=1;
batch.Setup.overwrite='Yes';
%batch.Setup.overwrite='No';
batch.Setup.nsubjects=length(cfg.subjects); % number of subjects
batch.Setup.RT=temp_TR;                                        % TR (seconds)
batch.Setup.acquisitiontype=1; %continuous acquisition of functional volumes %default 1

%specify fMRI data (smoothed)
for subj = 1:length(cfg.subjects)
    for r=1:cfg.nruns
        batch.Setup.functionals{subj}{r}=char([cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'swa' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-rest_run-' sprintf('%02d',r) '_bold.nii']);
    end
end

%specify sMRI data
for subj = 1:length(cfg.subjects)
    batch.Setup.structurals{subj} = char([cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'wmsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii']); %bias and noise corrected T1 from CAT12
    batch.Setup.masks.Grey{subj} = char([cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'mwp1sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii']); %grey matter seg from CAT12
    batch.Setup.masks.White{subj} = char([cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'mwp2sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii']); %white matter seg from CAT12
    batch.Setup.masks.CSF{subj} = char([cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'mwp3sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii']); %csf seg from CAT12
end

%specify secondary fMRI data (unsmoothed data)
batch.Setup.secondarydatasets.functionals_type(1)=2; %location of secondary functional dataset. 2: same files as Primary dataset field after removing leading 's' from filename

batch.Setup.add=0; %use 0 (default) to define the full set of subjects in your experiment; use 1 to define an additional set of subjects

%specify ROIs
batch.Setup.rois.add=0; %(default) to define the full set of ROIs to be used in your analyses; use 1 to define an additional set of ROIs (to be added to any already-existing ROIs in your project) [0]

batch.Setup.rois.files{1}=[filesep 'home' filesep 'user' filesep 'Software' filesep 'spm12' filesep 'toolbox' filesep 'cat12' filesep 'templates_MNI152NLin2009cAsym' filesep 'Schaefer2018_200Parcels_17Networks_order.nii']; %Schaefer2018 atlas, 200 roi version, 17 network 
batch.Setup.rois.multiplelabels(1) = 1;
batch.Setup.rois.dimensions{1} = 1; %number of ROI dimensions - 1 is average time series
batch.Setup.rois.weighted(1)=0; %1/0 to use weighted average/PCA computation when extracting temporal components 
batch.Setup.rois.mask(1)=0; %1/0 to mask with grey matter voxels %default 0 
batch.Setup.rois.regresscovariates(1)=0; %1/0 to regress known first-level covariates before computing PCA decomposition of BOLD signal within ROI [1 if dimensions>1; 0 otherwise] 
batch.Setup.rois.dataset(1)=1; %index n to Secondary Dataset #n 

%set up conditions
if cfg.condmodel==1
    batch.Setup.conditions.names={'rest'};
    for ncond=1
        for subj = 1:length(cfg.subjects)
            for run=1:cfg.nruns             
                batch.Setup.conditions.onsets{ncond}{subj}{run}=0; 
                batch.Setup.conditions.durations{ncond}{subj}{run}=inf;
            end
        end
    end     % rest condition (all sessions)
else
    batch.Setup.conditions.names=[{'rest'}, arrayfun(@(n)sprintf('Session%d',n),1:nconditions,'uni',0)];
    for ncond=1
        for subj = 1:length(cfg.subjects)
            for run=1:cfg.nruns             
                batch.Setup.conditions.onsets{ncond}{subj}{run}=0; 
                batch.Setup.conditions.durations{ncond}{subj}{run}=inf;
            end
        end
    end     % rest condition (all sessions)
    for ncond=1:cfg.condmodel
        for subj = 1:length(cfg.subjects)
            for run=1:cfg.nruns   
                batch.Setup.conditions.onsets{1+ncond}{subj}{run}=[];
                batch.Setup.conditions.durations{1+ncond}{subj}{run}=[]; 
            end
        end
    end
    for ncond=1:cfg.condmodel
        for subj = 1:length(cfg.subjects)
            for run=ncond        
                batch.Setup.conditions.onsets{1+ncond}{subj}{run}=0; 
                batch.Setup.conditions.durations{1+ncond}{subj}{run}=inf;
            end
        end
    end % session-specific conditions
end

%specify covariates
%realignment, qc timeseries, scrubbing
%ncovariate, nsub, nses
%covariate for realignment - spm motion realignment file 
batch.Setup.covariates.names{1}= char('realignment');%         : covariates.names{ncovariate} char array of first-level covariate name
for ncov=1
    for subj = 1:length(cfg.subjects)
        for run=1:cfg.nruns             
            batch.Setup.covariates.files{ncov}{subj}{run}=char([cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'rp_dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-rest_run-' sprintf('%02d',run) '_bold.txt']);; 
        end
    end
end  

%covariate for qc timeseries, art regression timeseries
batch.Setup.covariates.names{2}= char('QC_timeseries');%         : covariates.names{ncovariate} char array of first-level covariate name
for ncov=2
    for subj = 1:length(cfg.subjects)
        for run=1:cfg.nruns             
            batch.Setup.covariates.files{ncov}{subj}{run}=char([cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'art_regression_timeseries_a' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-rest_run-' sprintf('%02d',run) '_bold.mat']);; 
        end
    end
end     

%covariate for scrubbing, art outlier matrix
batch.Setup.covariates.names{3}= char('scrubbing');%         : covariates.names{ncovariate} char array of first-level covariate name
for ncov=3
    for subj = 1:length(cfg.subjects)
        for run=1:cfg.nruns             
            batch.Setup.covariates.files{ncov}{subj}{run}=char([cfg.outputDirBIDSfc 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'art_regression_outliers_a' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-rest_run-' sprintf('%02d',run) '_bold.mat']);; 
        end
    end
end 

batch.Setup.covariates.add=0; %           : 1/0; use 0 (default) to define the full set of covariates to be used in your analyses; use 1 to define an additional set of covariates (to be added to any already-existing covariates in your project) [0]

batch.Setup.subjects.effect_names{1}=char('AllSubjects');
batch.Setup.subjects.effects{1}=ones(length(cfg.subjects),1);
batch.Setup.subjects.add=0;

batch.Setup.voxelmask=1; %       : Analysis mask (voxel-level analyses): 1: Explicit mask (brainmask.nii); 2: Implicit mask (subject-specific) [1] 
%batch.Setup.voxelmask=2; %       : Analysis mask (voxel-level analyses): 1: Explicit mask (brainmask.nii); 2: Implicit mask (subject-specific) [1] 
%batch.Setup.voxelmaskfile=[fullfile(fileparts(which('spm')),'toolbox','conn','utils','surf','mask.volume.brainmask.nii')]; %   : Explicit mask file (only when voxelmask=1) [fullfile(fileparts(which('spm')),'apriori','brainmask.nii')] 
batch.Setup.voxelmaskfile=[fullfile(fileparts(which('spm')),'toolbox','cat12','templates_MNI152NLin2009cAsym','rbrainmask_T1.nii')]; %   : Explicit mask file (only when voxelmask=1) [fullfile(fileparts(which('spm')),'apriori','brainmask.nii')] 
batch.Setup.voxelresolution=3; % : Analysis space (voxel-level analyses): 1: Volume-based template (SPM; default 2mm isotropic or same as explicit mask if specified); 2: Same as structurals; 3: Same as functionals; 4: Surface-based template (Freesurfer) [1] 
batch.Setup.analysisunits=1; %   : BOLD signal units: 1: PSC units (percent signal change); 2: raw units [1] 
batch.Setup.outputfiles= [0,0,0,0,0,0]; %     : Optional output files (outputfiles(1): 1/0 creates confound beta-maps; outputfiles(2): 1/0 creates confound-corrected timeseries; outputfiles(3): 1/0 creates seed-to-voxel r-maps) ;outputfiles(4): 1/0 creates seed-to-voxel p-maps) ;outputfiles(5): 1/0 creates seed-to-voxel FDR-p-maps); outputfiles(6): 1/0 creates ROI-extraction REX files; [0,0,0,0,0,0] 
%batch.Setup.localcopy=1; %       : (for Setup.structural, Setup.functional, Setup.secondarydatasets, and Setup.rois) 1/0 : copies structural/functional files into conn_*/data/BIDS folder before importing into CONN [0]
batch.Setup.localcopy=0; %       : (for Setup.structural, Setup.functional, Setup.secondarydatasets, and Setup.rois) 1/0 : copies structural/functional files into conn_*/data/BIDS folder before importing into CONN [0]
batch.Setup.binary_threshold=[.5 .5 .5]; %: (for BOLD extraction from Grey/White/CSF ROIs) Threshold value # for binarizing Grey/White/CSF masks [.5 .5 .5] 
batch.Setup.binary_threshold_type=[1 1 1]; %: (for BOLD extraction from Grey/White/CSF ROIs) 1: absolute threshold (keep voxels with values above x); 2: percentile threshold (keep x% of voxels with the highest values) [1 1 1] 
batch.Setup.exclude_grey_matter=[nan nan nan]; %: (for BOLD extration from White/CSF ROIs) threhsold for excluding Grey matter voxels (nan for no threshold) [nan nan nan]
batch.Setup.erosion_steps=[0 1 1]; %   : (for BOLD extraction from Grey/White/CSF ROIs) integer numbers are interpreted as erosion kernel size for Grey/White/CSF mask erosion after binarization; non-integer numbers are interpreted as percentile voxels kept after erosion [0 1 1]
batch.Setup.erosion_neighb=[1 1 1]; %  : (for BOLD extraction from Grey/White/CSF ROIs; only when using integer erosion_steps/ kernel sizes, this field is disregarded otherwise) Neighborhood size for Grey/White/CSF mask erosion after binarization (a voxel is eroded if there are more than masks_erosion_neighb zeros within the (2*masks_erosionsteps+1)^3-neighborhood of each voxel) [1 1 1]

% DENOISING step
% CONN Denoising                                    % Default options (uses White Matter+CSF+realignment+scrubbing+conditions as confound regressors); see conn_batch for additional options 
batch.Denoising.filter=[0.008, 0.09];                 % frequency filter (band-pass values, in Hz) (e.g., [0.01, 0.1]) %using default values
batch.Denoising.done=1;
batch.Denoising.overwrite='Yes';
%batch.Denoising.overwrite='No';
batch.Denoising.detrending=1; %BOLD times-series polynomial detrending order (0: no detrending; 1: linear detrending; 3: cubic detrending) %default linear detrending
batch.Denoising.despiking=0; %temporal despiking with a hyperbolic tangent squashing function (1:before regression; 2:after regression) %default 0  
batch.Denoising.regbp=1; %order of band-pass filtering step (1 = RegBP: regression followed by band-pass; 2 = Simult: simultaneous regression&band-pass) %default 1 

%set up analysis
% PERFORMS FIRST-LEVEL ANALYSES (voxel-to-voxel)
batch.vvAnalysis.done=1; %0 defines fields only; 1 runs ANALYSIS processing steps [0]
batch.vvAnalysis.overwrite=1; %1/0: overwrites target files if they exist [1]
batch.vvAnalysis.name='ALFF_01'; %analysis name (identifying each set of independent analysis) (alternatively sequential index identifying each set of independent analyses [1])
batch.vvAnalysis.measures={'ALFF'}; %voxel-to-voxel measure name (type 'conn_v2v measurenames' for a list of default measures) (if this variable does not exist the toolbox will perform the analysis for all of the default v2v measures)

% Run all analyses
conn_batch(batch);

% CONN Display
% launches conn gui to explore results
conn
conn('load',fullfile(cfg.outputDirBIDSfc,'conn_analysis1.mat'));
%conn gui_results



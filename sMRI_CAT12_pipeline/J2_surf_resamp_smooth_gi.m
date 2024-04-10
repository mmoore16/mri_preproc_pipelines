% J2_surf_resamp_smooth_gi.m
%
% This script resamples and smooths surface data for gi. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

spm('defaults','fmri'); %comment out this line if you want to load in SPM GUI
spm_jobman('initcfg'); %comment out this line if you want to load in SPM GUI

%set batch number
bnum = 1;

templist = [];

%list of thickness files
for subj = 1:length(cfg.subjects)

    % Get the full file path and names for each subject
    folder = [cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat'];
    files = dir([folder filesep 'lh.gyrification.sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w']);
    for c = 1:length(files)
        fullpath{c}=[files(c).folder,filesep,files(c).name];
    end

    tempfiles{c} = fullpath';
    templist = [templist,tempfiles];

end

templist2 = cat(1,templist{:});

%surface resample and smooth data
matlabbatch{bnum}.spm.tools.cat.stools.surfresamp.sample{bnum}.data_surf = templist2;
matlabbatch{bnum}.spm.tools.cat.stools.surfresamp.merge_hemi = 1;
matlabbatch{bnum}.spm.tools.cat.stools.surfresamp.mesh32k = 1;
matlabbatch{bnum}.spm.tools.cat.stools.surfresamp.fwhm_surf = 20; %12 mm starting point for thickness, 20 mm for gyrification, complexity
matlabbatch{bnum}.spm.tools.cat.stools.surfresamp.lazy = 0;
matlabbatch{bnum}.spm.tools.cat.stools.surfresamp.nproc = 0;

bnum = bnum+1;

spm_jobman('run',matlabbatch); %comment out this line if you want to load in SPM GUI

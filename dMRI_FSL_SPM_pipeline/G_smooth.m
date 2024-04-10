% G_smooth.m
%
% This script smooths dMRI data. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

spm('defaults','fmri'); %comment out this line if you want to load in SPM GUI
spm_jobman('initcfg'); %comment out this line if you want to load in SPM GUI

%set batch number
bnum = 1;

for subj = 1:length(cfg.subjects)

    runs = {};
    templist = [];
        
    % Get the full file path and names for each subject
    folder = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi'];
    files = dir([folder filesep 'wesub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi_*.nii']); %applying deformations to all dMRI files
    for c = 1:length(files)
        fullpath{c}=[files(c).folder,filesep,files(c).name];
    end
    tempfiles{c} = fullpath';
    templist = [templist,tempfiles];
    templist2 = cat(1,templist{:});
    runs = spm_select('expand', templist2); %select all frames from 4D file

    matlabbatch{bnum}.spm.spatial.smooth.data = runs;
    matlabbatch{bnum}.spm.spatial.smooth.fwhm = cfg.dMRInormSmooth;
    matlabbatch{bnum}.spm.spatial.smooth.dtype = 0;
    matlabbatch{bnum}.spm.spatial.smooth.im = 0;
    matlabbatch{bnum}.spm.spatial.smooth.prefix = 's';
    
    bnum = bnum + 1;
    
end

spm_jobman('run',matlabbatch);

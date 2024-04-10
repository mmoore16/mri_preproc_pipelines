% K_smooth.m
%
% This script smooths fMRI data. 
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
    for r=1:cfg.nruns
        vols = {};
        
        % Get the full file path and names for each subject
        folder = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func'];
        files = dir([folder filesep 'wa' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',r) '_bold.nii']); %spatially, temporally aligned, normalized fmri
        for c = 1:length(files)
            fullpath{c}=[files(c).folder,filesep,files(c).name];
        end
        tempfiles{c} = fullpath';
        templist = [templist,tempfiles];
        templist2 = cat(1,templist{r});
        vols = spm_select('expand', templist2); %select all frames from 4D file
        runs = cat(1,runs,vols);
        
    end

    matlabbatch{bnum}.spm.spatial.smooth.data = runs;
    matlabbatch{bnum}.spm.spatial.smooth.fwhm = cfg.fMRInormSmooth;
    matlabbatch{bnum}.spm.spatial.smooth.dtype = 0;
    matlabbatch{bnum}.spm.spatial.smooth.im = 0;
    matlabbatch{bnum}.spm.spatial.smooth.prefix = 's';
    
    bnum = bnum + 1;
    
end

spm_jobman('run',matlabbatch);

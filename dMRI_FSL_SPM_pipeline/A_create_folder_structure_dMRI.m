% A_create_folder_structure_dMRI.m
%
% This script creates folders for dMRI data using BIDS formatting. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

for subj = 1:length(cfg.subjects)
    clearvars -except cfg subj; % clear variables except for cfg variables    
    if ~exist([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi'], 'dir')
        mkdir([cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi']); %BIDS format dMRI 
    end
end

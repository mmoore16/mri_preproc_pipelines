% O1_extract_rois_ALFF.m
%
% This script applies CAT12 ROI extraction to data coregistered with sMRI. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

%set batch number
bnum = 1;

%combine rois to group-level file
for atlas = 1:length(cfg.atlas)

    temp_combined = [];
    for subj = 1 %get header info from first subject
        %combine roi data from derivatives folder
        temp_csv = readcell([cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep cfg.atlas{atlas} '_wsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_bold_ALFF.csv']);
        temp_combined = [temp_combined; temp_csv(1:3,:)];
    end
    for subj = 1:length(cfg.subjects)
        %combine roi data from derivatives folder
        temp_csv = readcell([cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep cfg.atlas{atlas} '_wsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_bold_ALFF.csv']);
        temp_combined = [temp_combined; temp_csv(4:end,:)];
    end
    
    writecell(temp_combined,[cfg.spm12output filesep 'ROI_' cfg.atlas{atlas} '_task-' cfg.fMRITask '_bold_ALFF.csv']);
    bnum = bnum+1;
    
end
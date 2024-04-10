% L_extract_surf_rois.m
%
% This script extracts surface roi data. 
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

%list of segmentations
for subj = 1:length(cfg.subjects)

    % Get the full file path and names for each subject
    folder = [cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat'];
    files = dir([folder filesep 'catROIs_sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.xml']);
    for c = 1:length(files)
        fullpath{c}=[files(c).folder,filesep,files(c).name];
    end

    tempfiles{c} = fullpath';
    templist = [templist,tempfiles];

end

templist2 = cat(1,templist{:});

%smooth data
matlabbatch{bnum}.spm.tools.cat.tools.calcroi.roi_xml = templist2;
matlabbatch{bnum}.spm.tools.cat.tools.calcroi.point = '.';
matlabbatch{bnum}.spm.tools.cat.tools.calcroi.outdir = {cfg.CAT12output};
matlabbatch{bnum}.spm.tools.cat.tools.calcroi.calcroi_name = 'ROI';

bnum = bnum+1;

spm_jobman('run',matlabbatch); %comment out this line if you want to load in SPM GUI

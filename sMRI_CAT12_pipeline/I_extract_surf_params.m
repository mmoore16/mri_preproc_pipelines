% I_extract_surf_params.m
%
% This script extracts surface parameters from CAT12 output. 
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
    files = dir([folder filesep 'lh.central.sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.gii']);
    for c = 1:length(files)
        fullpath{c}=[files(c).folder,filesep,files(c).name];
    end

    tempfiles{c} = fullpath';
    templist = [templist,tempfiles];

end

templist2 = cat(1,templist{:});

%surface resample and smooth data
matlabbatch{bnum}.spm.tools.cat.stools.surfextract.data_surf = templist2;
matlabbatch{bnum}.spm.tools.cat.stools.surfextract.area = 0;
matlabbatch{bnum}.spm.tools.cat.stools.surfextract.gmv = 0;
matlabbatch{bnum}.spm.tools.cat.stools.surfextract.GI = 1;
matlabbatch{bnum}.spm.tools.cat.stools.surfextract.SD = 1;
matlabbatch{bnum}.spm.tools.cat.stools.surfextract.FD = 1;
matlabbatch{bnum}.spm.tools.cat.stools.surfextract.tGI = 1;
matlabbatch{bnum}.spm.tools.cat.stools.surfextract.lGI = 0;
matlabbatch{bnum}.spm.tools.cat.stools.surfextract.GIL = 0;
matlabbatch{bnum}.spm.tools.cat.stools.surfextract.surfaces.IS = 1;
matlabbatch{bnum}.spm.tools.cat.stools.surfextract.surfaces.OS = 1;
matlabbatch{bnum}.spm.tools.cat.stools.surfextract.norm = 1;
matlabbatch{bnum}.spm.tools.cat.stools.surfextract.FS_HOME = '<UNDEFINED>';
matlabbatch{bnum}.spm.tools.cat.stools.surfextract.nproc = 8;
matlabbatch{bnum}.spm.tools.cat.stools.surfextract.lazy = 0;

bnum = bnum+1;

spm_jobman('run',matlabbatch); %comment out this line if you want to load in SPM GUI

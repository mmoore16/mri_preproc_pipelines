% I_reorient_acpc_coreg.m
%
% This script reorients to MNI EPI template and coregisters fMRI data with subject sMRI. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

%set batch number
bnum = 1;

for subj = 1:length(cfg.subjects)
    
    sMRI_img = {[cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'bmsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii']}; %registering to skull stripped, bias corrected anatomical
    fMRI_img = {[cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'meana' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_runs_bold.nii,1']}; %registering average spatially and temporally realigned file to anatomical

    runs = {};
    templist = [];
    other = [];
    %finding runs contributing to mean image
    for r=1:cfg.nruns
        vols = {};
        
        % Get the full file path and names for each subject
        folder = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func'];
        files = dir([folder filesep 'a' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',r) '_bold.nii']); %applying coreg to spatially and temporally realigned files
        for c = 1:length(files)
            fullpath{c}=[files(c).folder,filesep,files(c).name];
        end
        tempfiles{c} = fullpath';
        templist = [templist,tempfiles];
        templist2 = cat(1,templist{r});
        vols = {[templist2{1,1},',1']}; %select only the first frame from 4D file
        runs{r} = vols;
        other = [other; runs{r}];
        
    end

    all_img = [fMRI_img;other]; 
    nii_setOrigin12x(all_img); %set center of mass as origin for fmri (based on mean image [fMRI_img], applied to 4D files [other]) to account for possible major translation differences that can cause coreg to fail
    auto_acpc_coreg(sMRI_img, fMRI_img, other, 'mi', 'epi');

    bnum = bnum+1;

end


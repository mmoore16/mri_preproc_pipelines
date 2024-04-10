% D_eddy_dtifit.m
%
% This script calls FSL tools to perform eddy correction and DTIFIT procedures on dMRI data. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

%set batch number
bnum = 1;

%templist = [];

for subj = 1:length(cfg.subjects)

    temp_in_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.nii.gz']; %input dwi file
    temp_out_file_ecc = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'esub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.nii.gz']; %output dwi file
    temp_in_file_bvec = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.bvec']; %input bvec file
    temp_out_file_bvec = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'esub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.bvec']; %rotated bvec file
    temp_in_file_ecclog = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'esub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.ecclog']; %ecclog file
    temp_in_file_bval = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.bval']; %input bval file
    temp_out_file_bval = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.bval']; %copied bval file
    temp_in_file_ecc = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'esub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.nii.gz']; %input eddy corrected dwi file
    temp_out_file_eccbet = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'besub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi']; %bet file
    temp_out_file_dtifit = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'esub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi']; %dtifit files

    %eddy correct dMRI
    fprintf('Performing eddy correction.\n');
    cmd_eddy = strcat("eddy_correct "+temp_in_file+" "+temp_out_file_ecc+" 0"); %eddy correct dwi files
    system(cmd_eddy);
    
    %rotate bvecs
    fprintf('Rotating bvecs to account for eddy correction.\n');
    cmd_rotbvec = strcat(cfg.rotate+" "+temp_in_file_bvec+" "+temp_out_file_bvec+" "+temp_in_file_ecclog); %rotate eddy correct bvec files
    system(cmd_rotbvec);

    %copy bval file to derivatives folder
    cmd_bval = strcat("cp "+temp_in_file_bval+" "+temp_out_file_bval); %copy bval files
    system(cmd_bval);

    %extract brain mask
    fprintf('Extracting brain mask from eddy corrected data.\n');
    cmd_bet = strcat("bet "+temp_in_file_ecc+" "+temp_out_file_eccbet+" -m -f "+cfg.betf+" -g "+cfg.betg); %bet eddy correct files - might need to adjust -f
    system(cmd_bet);

    %dtifit
    fprintf('Performing dtifit on eddy corrected data.\n');
    cmd_dtifit = strcat("dtifit --data="+temp_in_file_ecc+" --out="+temp_out_file_dtifit+" --mask="+temp_out_file_eccbet+"_mask.nii.gz --bvecs="+temp_out_file_bvec+" --bvals="+temp_out_file_bval+" --save_tensor"); %run dtifit on eddy corrected data
    system(cmd_dtifit);
    
    %rename AD file
    fprintf('Renaming AD data.\n');
    cmd_adfile = strcat("cp "+[temp_out_file_dtifit,'_L1.nii.gz']+" "+[temp_out_file_dtifit,'_AD.nii.gz']); %copy file with new name
    system(cmd_adfile);
    
    %caculate RD
    fprintf('Calculating RD.\n');
    cmd_rdfile = strcat("fslmaths "+[temp_out_file_dtifit,'_L2.nii.gz']+" -add "+[temp_out_file_dtifit,'_L3.nii.gz']+" -div 2 "+[temp_out_file_dtifit,'_RD.nii.gz']); %calculate rd
    system(cmd_rdfile);
    
    bnum = bnum+1;
    
end

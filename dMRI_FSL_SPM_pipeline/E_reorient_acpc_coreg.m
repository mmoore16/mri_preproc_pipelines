% E_reorient_acpc_coreg.m
%
% This script reorients to MNI T2 template and coregisters dMRI data with subject sMRI. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

%set batch number
bnum = 1;

for subj = 1:length(cfg.subjects)

    temp_out_file_dtifit = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'esub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi']; %dtifit files
    %gunzip dtifit files
    gunzip([temp_out_file_dtifit,'_V1.nii.gz']); %gunzip fsl .nii.gz file
    system([strcat("rm -rf "+[temp_out_file_dtifit,'_V1.nii.gz'])]); %remove zip file   
    gunzip([temp_out_file_dtifit,'_V2.nii.gz']); %gunzip fsl .nii.gz file
    system([strcat("rm -rf "+[temp_out_file_dtifit,'_V2.nii.gz'])]); %remove zip file  
    gunzip([temp_out_file_dtifit,'_V3.nii.gz']); %gunzip fsl .nii.gz file
    system([strcat("rm -rf "+[temp_out_file_dtifit,'_V3.nii.gz'])]); %remove zip file  
    gunzip([temp_out_file_dtifit,'_L1.nii.gz']); %gunzip fsl .nii.gz file
    system([strcat("rm -rf "+[temp_out_file_dtifit,'_L1.nii.gz'])]); %remove zip file  
    gunzip([temp_out_file_dtifit,'_L2.nii.gz']); %gunzip fsl .nii.gz file
    system([strcat("rm -rf "+[temp_out_file_dtifit,'_L2.nii.gz'])]); %remove zip file  
    gunzip([temp_out_file_dtifit,'_L3.nii.gz']); %gunzip fsl .nii.gz file
    system([strcat("rm -rf "+[temp_out_file_dtifit,'_L3.nii.gz'])]); %remove zip file  
    gunzip([temp_out_file_dtifit,'_MD.nii.gz']); %gunzip fsl .nii.gz file
    system([strcat("rm -rf "+[temp_out_file_dtifit,'_MD.nii.gz'])]); %remove zip file  
    gunzip([temp_out_file_dtifit,'_FA.nii.gz']); %gunzip fsl .nii.gz file
    system([strcat("rm -rf "+[temp_out_file_dtifit,'_FA.nii.gz'])]); %remove zip file  
    gunzip([temp_out_file_dtifit,'_MO.nii.gz']); %gunzip fsl .nii.gz file
    system([strcat("rm -rf "+[temp_out_file_dtifit,'_MO.nii.gz'])]); %remove zip file  
    gunzip([temp_out_file_dtifit,'_S0.nii.gz']); %gunzip fsl .nii.gz file
    system([strcat("rm -rf "+[temp_out_file_dtifit,'_S0.nii.gz'])]); %remove zip file  
    gunzip([temp_out_file_dtifit,'_tensor.nii.gz']); %gunzip fsl .nii.gz file
    system([strcat("rm -rf "+[temp_out_file_dtifit,'_tensor.nii.gz'])]); %remove zip file
    gunzip([temp_out_file_dtifit,'_AD.nii.gz']); %gunzip fsl .nii.gz file
    system([strcat("rm -rf "+[temp_out_file_dtifit,'_AD.nii.gz'])]); %remove zip filename
    gunzip([temp_out_file_dtifit,'_RD.nii.gz']); %gunzip fsl .nii.gz file
    system([strcat("rm -rf "+[temp_out_file_dtifit,'_RD.nii.gz'])]); %remove zip file
    
    %copy sMRI skull stripped, bias corrected anatomical
    temp_in_file = [cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'bmsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii']; 
    temp_copy_file = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'bmsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii'];
    cmd_cpfile = strcat("cp "+temp_in_file+" "+temp_copy_file); %copy file
    system(cmd_cpfile);

    sMRI_img = {[cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'bmsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii']}; %registering to skull stripped, bias corrected anatomical
    dMRI_img = {[cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'esub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi_S0.nii']}; %registering raw T2 file to anatomical

    templist = [];
    all_img = [];
        
    % Get the full file path and names for each subject
    folder = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi'];
    files = dir([folder filesep 'esub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi_*.nii']); %applying coreg to other dMRI files
    for c = 1:length(files)
        fullpath{c}=[files(c).folder,filesep,files(c).name];
    end
    tempfiles{c} = fullpath';
    templist = [templist,tempfiles];
    templist2 = cat(1,templist{:});
    templist2(ismember(templist2,dMRI_img)) = []; %remove raw T2 file from list if present
    all_img = [dMRI_img;templist2];
    nii_setOrigin12x(all_img); %set center of mass as origin for dmri processed in subject space to account for possible major translation differences that can cause coreg to fail
    auto_acpc_coreg(sMRI_img, dMRI_img, templist2, 'mi', 'T2'); %align dmri S0 with T2 template and coreg with subject T1, then apply to all other dtifit output files

    bnum = bnum+1;

end


% D_topup_eddy_dtifit.m
%
% This script calls FSL tools to perform topup, eddy correction, and DTIFIT procedures on dMRI data. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

%set batch number
bnum = 1;

for subj = 1:length(cfg.subjects)

    temp_in_file_bvec = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.bvec']; %input bvec file
    temp_out_file_bvec = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.bvec']; %copied bvec file
    temp_in_file_bval = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.bval']; %input bval file
    temp_out_file_bval = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.bval']; %copied bval file
    temp_out_file_b0s = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_b0s.nii.gz']; %output b0s file
    temp_out_file_acq = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_acq_param.txt']; %output acq_param file
    temp_topup_file = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_topup']; %output topup file
    temp_topup_field = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_field']; %output topup field file
    temp_topup_unwarp = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'usub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_b0']; %output topup unwarp b0 file
    temp_dwi_file = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.nii.gz']; %renamed/combined dwi file
    temp_applytopup_file = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi_topup']; %topup corrected dwi file
    temp_topup_unwarp_avg = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'musub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_b0']; %output topup unwarp b0 file avg
    temp_out_file_bet = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'busub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_b0']; %bet file
    temp_index_file = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_index.txt']; %index file
    temp_out_file_ecc = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'esub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi.nii.gz']; %output eddy corrected dwi file
    temp_out_file_eccbet = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'besub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi']; %bet file
    temp_out_file_dtifit = [cfg.outputDirBIDSd 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi' filesep 'esub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_dwi']; %dtifit files

    %topup dMRI
    fprintf('Performing topup procedure.\n');
    cmd_topup = strcat("topup --imain="+temp_out_file_b0s+" --datain="+temp_out_file_acq+" --config="+cfg.cnf+" --out="+temp_topup_file+" --fout="+temp_topup_field+" --iout="+temp_topup_unwarp); %topup dwi files
    system(cmd_topup);
        
    %apply topup dMRI
    fprintf('Applying topup to dMRI.\n');
    cmd_applytopup = strcat("applytopup --imain="+temp_dwi_file+" --inindex="+cfg.ndrun_t+" --datain="+temp_out_file_acq+" --topup="+temp_topup_file+" --method=jac --out="+temp_applytopup_file); %apply topup dwi files
    system(cmd_applytopup);
    
    %average unwarped b0s
    fprintf('Averaging unwarped b0s.\n');
    cmd_avgb0 = strcat("fslmaths "+temp_topup_unwarp+" -Tmean "+temp_topup_unwarp_avg); %average topup corrected files
    system(cmd_avgb0);
    
    %extract brain mask
    fprintf('Extracting brain mask from unwarped b0s.\n');
    cmd_bet = strcat("bet "+temp_topup_unwarp_avg+" "+temp_out_file_bet+" -m -f "+cfg.betf+" -g "+cfg.betg); %bet topup corrected files - might need to adjust -f
    system(cmd_bet);

    %copy bvec file to derivatives folder
    cmd_bvec = strcat("cp "+temp_in_file_bvec+" "+temp_out_file_bvec); %copy bvec files
    system(cmd_bvec);

    %copy bval file to derivatives folder
    cmd_bval = strcat("cp "+temp_in_file_bval+" "+temp_out_file_bval); %copy bval files
    system(cmd_bval);
    
    %create index file
    fprintf('Creating index file.\n');
    cmd_indx = strcat("indx="+'""'+" && for ((i=1; i<="+cfg.nvols+"; i+=1)); do indx="+'"'+"$indx 1"+'"'+"; done && echo $indx > "+temp_index_file); %set dwi index
    system(cmd_indx);

    if cfg.eddy_rep == 1
        fprintf('Performing eddy correction with outlier replacement.\n');
        %eddy correct dMRI - includes outlier replacement using Gaussian Process predictions
        cmd_eddy = strcat("eddy --imain="+temp_applytopup_file+" --mask="+temp_out_file_bet+" --acqp="+temp_out_file_acq+" --index="+temp_index_file+" --bvecs="+temp_out_file_bvec+" --bvals="+temp_out_file_bval+" --topup="+temp_topup_file+" --repol --out="+temp_out_file_ecc); %eddy correct dwi files
        system(cmd_eddy);
    else %cfg.eddy_rep ~= 1
        fprintf('Performing eddy correction without outlier replacement.\n');
        %eddy correct dMRI - without outlier replacement
        cmd_eddy = strcat("eddy --imain="+temp_applytopup_file+" --mask="+temp_out_file_bet+" --acqp="+temp_out_file_acq+" --index="+temp_index_file+" --bvecs="+temp_out_file_bvec+" --bvals="+temp_out_file_bval+" --topup="+temp_topup_file+" --out="+temp_out_file_ecc); %eddy correct dwi files
        system(cmd_eddy);
    end

    %extract brain mask
    fprintf('Extracting brain mask from eddy corrected data.\n');
    cmd_bet = strcat("bet "+temp_out_file_ecc+" "+temp_out_file_eccbet+" -m -f "+cfg.betf+" -g "+cfg.betg); %bet eddy correct files - might need to adjust -f
    system(cmd_bet);

    %dtifit
    fprintf('Performing dtifit on eddy corrected data.\n');
    cmd_dtifit = strcat("dtifit --data="+temp_out_file_ecc+" --out="+temp_out_file_dtifit+" --mask="+temp_out_file_eccbet+"_mask.nii.gz --bvecs="+temp_out_file_ecc+".eddy_rotated_bvecs --bvals="+temp_out_file_bval+" --save_tensor"); %run dtifit on topup and eddy corrected data
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

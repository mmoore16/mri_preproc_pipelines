% B_dcm2niix_sMRI.m
%
% This script uses dcm2niix to convert dicoms to nifti. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

%set batch number
bnum = 1;

for subj = 1:length(cfg.subjects)
    
    % Get the full file path and names for each subject
    tempfolder = dir([cfg.rootDir cfg.subjectsSOURCE{subj} '_' cfg.sessions{subj} cfg.imageDir cfg.subjectsSOURCE{subj} cfg.dicomDir cfg.sMRIDir]); %allow for variability in imaging protocol order/folder numbers
    folder = [cfg.rootDir cfg.subjectsSOURCE{subj} '_' cfg.sessions{subj} cfg.imageDir cfg.subjectsSOURCE{subj} cfg.dicomDir tempfolder.name];
    zip_files = dir([folder filesep '*.zip']); %anonymized files are compressed to .zip
    for k = 1:length(zip_files)
        unzip([folder filesep zip_files(k).name],folder); %unzip all compressed .zip files
    end
    files = dir([folder filesep '**' filesep '*.dcm']);
    inloc = strcat(files(1).folder); %assuming final folder path with dicoms is one location that corresponds to first detected dicom
    temp_in_dir = inloc;
    temp_out_dir = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat'];
    temp_filename = ['sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w'];
	
    %convert sMRI
    cmd = strcat(cfg.dcm2niix+" "+'-b y -f '+""+temp_filename+' -o '+""+'"'+temp_out_dir+'"'+' -s n -z y '+""+'"'+temp_in_dir+'"');
    system(cmd);
    
    bnum = bnum+1;

end



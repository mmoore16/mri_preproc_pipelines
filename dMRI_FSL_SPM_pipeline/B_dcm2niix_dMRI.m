% B_dcm2niix_dMRI.m
%
% This script uses dcm2niix to convert dicoms to nifti. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

%set batch number
bnum = 1;

for subj = 1:length(cfg.subjects)
    
    for r = 1:cfg.ndruns
        % Get the full file path and names for each subject
        tempfolder = dir([cfg.rootDir cfg.subjectsSOURCE{subj} '_' cfg.sessions{subj} cfg.imageDir cfg.subjectsSOURCE{subj} cfg.dicomDir cfg.dMRIDir]); %allow for variability in imaging protocol order/folder numbers
        folder{r} = [cfg.rootDir cfg.subjectsSOURCE{subj} '_' cfg.sessions{subj} cfg.imageDir cfg.subjectsSOURCE{subj} cfg.dicomDir getfield(tempfolder,{r},'name')];   
        zip_files{r} = dir([folder{r} filesep '*.zip']); %anonymized files are compressed to .zip
        for k = 1:length(zip_files{r})
            unzip([folder{r} filesep zip_files{r}(k).name],folder{r}); %unzip all compressed .zip files
        end
        files{r} = dir([folder{r} filesep '**' filesep '*.dcm']);
        inloc{r} = getfield(files{r},'folder'); %assuming final folder path with dicoms is one location that corresponds to first detected dicom
        temp_in_dir{r} = inloc{r};
        temp_out_dir{r} = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'dwi'];
        temp_filename{r} = ['sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_run-' sprintf('%02d',r) '_dwi']; %creating multiple files for different dwi runs; to be combined in later steps.
        %convert dMRI
        cmd = strcat(cfg.dcm2niix+" "+'-b y -f '+""+temp_filename{r}+' -o '+""+'"'+temp_out_dir{r}+'"'+' -s n -z y '+""+'"'+temp_in_dir{r}+'"');
        system(cmd);
    end
    
bnum = bnum+1;

end



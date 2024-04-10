% F_slice_timing.m
%
% This script performs STC for fMRI data using timings from json file. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

spm('defaults','fmri'); %comment out this line if you want to load in SPM GUI
spm_jobman('initcfg'); %comment out this line if you want to load in SPM GUI

%set batch number
bnum = 1;

for subj = 1:length(cfg.subjects)

    runs = {};
    val = {};
    templist = [];
    jsontemplist = [];
    for r=1:cfg.nruns
        vols = {};
        
        % Get the full file path and names for each subject
        folder = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func'];
        files = dir([folder filesep cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',r) '_bold.nii']); %inputs are spatially realigned files
        for c = 1:length(files)
            if c >1
                fprintf('more than one nii file found matching run, check that files are correct!');
            end            
            fullpath{c}=[files(c).folder,filesep,files(c).name];
        end
        tempfiles{c} = fullpath';
        templist = [templist,tempfiles];
        templist2 = cat(1,templist{r});
        vols = spm_select('expand', templist2); %select all frames from 4D file
        runs{r} = vols;

        % Get the imaging parameters from the json file
        jsonfolder = [cfg.outputDir 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func'];
        jsonfiles = dir([jsonfolder filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',r) '_bold.json']);
        for c = 1:length(jsonfiles)
            if c >1
                fprintf('more than one json file found matching run, check that files are correct!');
            end  
            jsonfullpath{c}=[jsonfiles(c).folder,filesep,jsonfiles(c).name];
        end
        jsontempfiles{c} = jsonfullpath';
        jsontemplist = [jsontemplist,jsontempfiles];
        jsontemplist2 = cat(1,jsontemplist{r});
        fid = fopen(jsontemplist2{c}); 
        raw = fread(fid,inf); 
        str = char(raw'); 
        fclose(fid); 
        val{r} = jsondecode(str);
        cellcheck = isequaln(val{1,1}, val{1,r});
        if cellcheck ~= 1
            fprintf('json files do not match, check files!');
        end        
    end
    
    matlabbatch{bnum}.spm.temporal.st.scans = runs;
    matlabbatch{bnum}.spm.temporal.st.nslices = length(val{1,r}.SliceTiming);
    matlabbatch{bnum}.spm.temporal.st.tr = val{1,r}.RepetitionTime;
    
    % Note that for SMS sequences, the formula for calculating TA might not apply anymore and set to 0.
    % https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=spm;1cc250dd.1407
    matlabbatch{bnum}.spm.temporal.st.ta = 0;
    
    % Slice timing (in ms) read from the json file (code shown above) - check if correct by comparing with dicom header!
    % The acquisition time for each slice can also be detected using the following code:
    % hdr = spm_dicom_headers('sub.dcm');
    % slice_times = hdr{1}.Private_0019_1029;
    matlabbatch{bnum}.spm.temporal.st.so = ([val{1,r}.SliceTiming']*1000); %dcm2niix appears to convert to sec, converting back to msec  
    matlabbatch{bnum}.spm.temporal.st.refslice = 0; % setting the reference as the first slice (acquisition time = 0 ms)
    matlabbatch{bnum}.spm.temporal.st.prefix = 'a';
    
    bnum = bnum+1;
    
end

spm_jobman('run',matlabbatch);

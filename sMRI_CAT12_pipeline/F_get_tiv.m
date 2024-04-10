% F_get_tiv.m
%
% This script extracts tiv estimates from CAT12 output. 
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

for subj = 1:length(cfg.subjects)

    % Get the full file path and names for each subject
    folder = [cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat'];
    files = dir([folder filesep 'cat_sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.xml']);
    for c = 1:length(files)
        fullpath{c}=[files(c).folder,filesep,files(c).name];
    end

    tempfiles{c} = fullpath';
    templist = [templist,tempfiles];

end

templist2 = cat(1,templist{:});

%get tiv
matlabbatch{bnum}.spm.tools.cat.tools.calcvol.data_xml = templist2;
matlabbatch{bnum}.spm.tools.cat.tools.calcvol.calcvol_TIV = 1;
matlabbatch{bnum}.spm.tools.cat.tools.calcvol.calcvol_name = 'TIV.txt';

bnum = bnum+1;

spm_jobman('run',matlabbatch); %comment out this line if you want to load in SPM GUI

%move tiv file to derivatives folder
temp_in_tiv = [pwd filesep 'TIV.txt'];
temp_out_tiv = [cfg.CAT12output filesep];
cmd_tiv = strcat("mv "+temp_in_tiv+" "+temp_out_tiv); %move tiv file
system(cmd_tiv);

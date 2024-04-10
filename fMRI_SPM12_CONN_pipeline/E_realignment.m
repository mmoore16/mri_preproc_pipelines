% E_realignment.m
%
% This script realigns fMRI data to correct for motion. 
%
% load a cfg.mat that has relevant parameters for data processing
%[filename,filepath] = uigetfile('*.mat*','Select an cfg.mat file');
%load([filepath filesep filename]);

clearvars -except cfg; % clear variables except for cfg variables

spm('defaults','fmri'); %comment out this line if you want to load in SPM GUI
spm_jobman('initcfg'); %comment out this line if you want to load in SPM GUI
spm_figure('GetWin','Graphics'); %this step required to get the graphics to print

%set batch number
bnum = 1;

for subj = 1:length(cfg.subjects)

    runs = {};
    templist = [];
    for r=1:cfg.nruns
        vols = {};
        
	% Get the full file path and names for each subject
	folder = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func'];
	files = dir([folder filesep 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',r) '_bold.nii']);
        for c = 1:length(files)
            fullpath{c}=[files(c).folder,filesep,files(c).name];
        end
        tempfiles{c} = fullpath';
        templist = [templist,tempfiles];
        templist2 = cat(1,templist{r});
	vols = spm_select('expand', templist2); %select all frames from 4D file
        runs{r} = vols;
        
    end

    matlabbatch{bnum}.spm.spatial.realign.estwrite.data = runs;

    % params for estimation and writing
    matlabbatch{bnum}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
    matlabbatch{bnum}.spm.spatial.realign.estwrite.eoptions.sep = 4;
    matlabbatch{bnum}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
    matlabbatch{bnum}.spm.spatial.realign.estwrite.eoptions.rtm = 1; % register to mean volume
    matlabbatch{bnum}.spm.spatial.realign.estwrite.eoptions.interp = 4; 
    matlabbatch{bnum}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
    matlabbatch{bnum}.spm.spatial.realign.estwrite.eoptions.weight = '';
    matlabbatch{bnum}.spm.spatial.realign.estwrite.roptions.which = [2 1];
    matlabbatch{bnum}.spm.spatial.realign.estwrite.roptions.interp = 4;
    matlabbatch{bnum}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
    matlabbatch{bnum}.spm.spatial.realign.estwrite.roptions.mask = 1;
    matlabbatch{bnum}.spm.spatial.realign.estwrite.roptions.prefix = 'r';
    
    bnum = bnum + 1;
    
    % print SPM graphics    
    matlabbatch{bnum}.spm.util.print.fname = [cfg.subjects{subj} '_motion'];
    matlabbatch{bnum}.spm.util.print.fig.figname = 'Graphics';
    matlabbatch{bnum}.spm.util.print.opts = 'pdf';
    
    bnum = bnum + 1;
    
end

spm_jobman('run',matlabbatch);
close all %close all graphic windows

for subj = 1:length(cfg.subjects)
    for r=1:cfg.nruns
        n_pad = sprintf('%03d',r); %spm12 appears to zero pad output files
        %move motion file to derivatives folder
        temp_in_mot = [cfg.subjects{subj} '_motion_' n_pad '.pdf'];
        temp_out_mot = [cfg.spm12output filesep];
        cmd_mot = strcat("mv "+temp_in_mot+" "+temp_out_mot); %move motion file
        system(cmd_mot);
    end
end

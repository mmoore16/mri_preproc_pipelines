% E_realign_unwarp.m
%
% This script realigns and unwarps fMRI data to correct for motion. 
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
        
        matlabbatch{bnum}.spm.spatial.realignunwarp.data(r).scans = runs{r};
        matlabbatch{bnum}.spm.spatial.realignunwarp.data(r).pmscan = ''; %pre-calculated vdm file empty = no phase correction
        
    end

    % params for estimation, unwarping, and writing
    matlabbatch{bnum}.spm.spatial.realignunwarp.eoptions.quality = 0.9;
    matlabbatch{bnum}.spm.spatial.realignunwarp.eoptions.sep = 4;
    matlabbatch{bnum}.spm.spatial.realignunwarp.eoptions.fwhm = 5;
    matlabbatch{bnum}.spm.spatial.realignunwarp.eoptions.rtm = 1; % register to mean volume
    matlabbatch{bnum}.spm.spatial.realignunwarp.eoptions.einterp = 4;
    matlabbatch{bnum}.spm.spatial.realignunwarp.eoptions.ewrap = [0 0 0];
    matlabbatch{bnum}.spm.spatial.realignunwarp.eoptions.weight = '';

    matlabbatch{bnum}.spm.spatial.realignunwarp.uweoptions.basfcn = [12 12]; %default
    matlabbatch{bnum}.spm.spatial.realignunwarp.uweoptions.regorder = 1; %default
    matlabbatch{bnum}.spm.spatial.realignunwarp.uweoptions.lambda = 100000; %medium regularization factor
    matlabbatch{bnum}.spm.spatial.realignunwarp.uweoptions.jm = 0;
    matlabbatch{bnum}.spm.spatial.realignunwarp.uweoptions.fot = [4 5]; %first order effects
    matlabbatch{bnum}.spm.spatial.realignunwarp.uweoptions.sot = []; %second order effects
    matlabbatch{bnum}.spm.spatial.realignunwarp.uweoptions.uwfwhm = 4; %default
    matlabbatch{bnum}.spm.spatial.realignunwarp.uweoptions.rem = 1; %default yes re-estimate movement parameters
    matlabbatch{bnum}.spm.spatial.realignunwarp.uweoptions.noi = 5; %default maximum number of iterations
    matlabbatch{bnum}.spm.spatial.realignunwarp.uweoptions.expround = 'Average'; %Taylor expansion point

    matlabbatch{bnum}.spm.spatial.realignunwarp.uwroptions.uwwhich = [2 1];
    matlabbatch{bnum}.spm.spatial.realignunwarp.uwroptions.rinterp = 4;
    matlabbatch{bnum}.spm.spatial.realignunwarp.uwroptions.wrap = [0 0 0];
    matlabbatch{bnum}.spm.spatial.realignunwarp.uwroptions.mask = 1;
    matlabbatch{bnum}.spm.spatial.realignunwarp.uwroptions.prefix = cfg.realign_pref; %default is 'u'
    
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

% G_avg_func.m
%
% This script averages fMRI data. 
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
    templist = [];
    for r=1:cfg.nruns
        vols = {};
        
	% Get the full file path and names for each subject
	folder = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func'];
	files = dir([folder filesep 'a' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_run-' sprintf('%02d',r) '_bold.nii']); %inputs are spatially and temporally realigned files
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
        runs = cat(1,runs,vols);
		
    end

    matlabbatch{bnum}.spm.util.imcalc.input = runs;
    matlabbatch{bnum}.spm.util.imcalc.output = [cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func' filesep 'meana' cfg.realign_pref 'dsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_task-' cfg.fMRITask '_runs_bold.nii,1']; %labeling as runs
    matlabbatch{bnum}.spm.util.imcalc.outdir = {[cfg.outputDirBIDSf 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'func']};
    matlabbatch{bnum}.spm.util.imcalc.expression = 'mean(X)';
    matlabbatch{bnum}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{bnum}.spm.util.imcalc.options.dmtx = 1; %read data into matrix X
    matlabbatch{bnum}.spm.util.imcalc.options.mask = 0; %no implicit mask
    matlabbatch{bnum}.spm.util.imcalc.options.interp = -4; %4th degree sinc
    matlabbatch{bnum}.spm.util.imcalc.options.dtype = 4; %int16
    
    bnum = bnum+1;
    
end

spm_jobman('run',matlabbatch);

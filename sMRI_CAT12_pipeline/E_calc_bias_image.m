% E_calc_bias_image.m
%
% This script takes label map (p0*) from CAT12 and masks bias corrected T1 (m*) with it for use in other steps that require skull-stripped bias corrected image in subject space (e.g., coregistering other modalities). 
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

    matlabbatch{bnum}.spm.util.imcalc.input = {[cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'p0sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii,1']
    [cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'msub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii,1']};
    matlabbatch{bnum}.spm.util.imcalc.output = [cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'bmsub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii,1']; %labeling brain extracted (b)
    matlabbatch{bnum}.spm.util.imcalc.outdir = {[cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat']};
    matlabbatch{bnum}.spm.util.imcalc.expression = 'i2.*(i1>0)'; %taking any values greater than 0 in label map (i1) and using the binary mask to strip skull from bias corrected T1 in subject space (i2)
    matlabbatch{bnum}.spm.util.imcalc.var = struct('name', {}, 'value', {});
    matlabbatch{bnum}.spm.util.imcalc.options.dmtx = 0; %do not read data into matrix
    matlabbatch{bnum}.spm.util.imcalc.options.mask = 0; %no implicit mask
    matlabbatch{bnum}.spm.util.imcalc.options.interp = -4; %4th degree sinc - might prefer nearest neighbor (0) for masks - for this particular image, testing indicated no difference
    matlabbatch{bnum}.spm.util.imcalc.options.dtype = 4; %int16
    
    bnum = bnum+1;
    
end

spm_jobman('run',matlabbatch);

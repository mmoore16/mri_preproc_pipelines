% D_segment_anat_adv_nocom.m
%
% This script segments MRI data for VBM, SBM, DBM, and RBM. 
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
    
matlabbatch{bnum}.spm.tools.cat.estwrite.data = {[cfg.outputDirBIDSs 'sub-' cfg.subjects{subj} filesep 'ses-' cfg.sessions{subj} filesep 'anat' filesep 'sub-' cfg.subjects{subj} '_ses-' cfg.sessions{subj} '_T1w.nii,1']};
matlabbatch{bnum}.spm.tools.cat.estwrite.data_wmh = {''};
matlabbatch{bnum}.spm.tools.cat.estwrite.nproc = cfg.nproc;
matlabbatch{bnum}.spm.tools.cat.estwrite.useprior = '';
matlabbatch{bnum}.spm.tools.cat.estwrite.opts.tpm = {cfg.TPM};
matlabbatch{bnum}.spm.tools.cat.estwrite.opts.affreg = 'mni';
matlabbatch{bnum}.spm.tools.cat.estwrite.opts.biasstr = 0.5;
matlabbatch{bnum}.spm.tools.cat.estwrite.opts.accstr = 0.5;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.segmentation.restypes.optimal = [1 0.3];
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.segmentation.setCOM = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.segmentation.APP = 1070;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.segmentation.affmod = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.segmentation.NCstr = -Inf;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.segmentation.spm_kamap = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.segmentation.LASstr = 0.5;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.segmentation.LASmyostr = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.segmentation.gcutstr = 2;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.segmentation.cleanupstr = 0.5;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.segmentation.BVCstr = 0.5;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.segmentation.WMHC = 2;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.segmentation.SLC = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.segmentation.mrf = 1;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.registration.regmethod.shooting.shootingtpm = {cfg.shootingTemp};
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.registration.regmethod.shooting.regstr = 0.5;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.registration.vox = cfg.sMRInormVox; %default 1.5 
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.registration.bb = 12;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.surface.pbtres = 0.5;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.surface.pbtmethod = 'pbt2x';
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.surface.SRP = 22;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.surface.reduce_mesh = 1;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.surface.vdist = 2;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.surface.scale_cortex = 0.7;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.surface.add_parahipp = 0.1;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.surface.close_parahipp = 1;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.admin.experimental = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.admin.new_release = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.admin.lazy = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.admin.ignoreErrors = 1;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.admin.verb = 2;
matlabbatch{bnum}.spm.tools.cat.estwrite.extopts.admin.print = 2;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.BIDS.BIDSyes.BIDSfolder = cfg.CAT12BIDS;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.surface = cfg.surfs;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.surf_measures = cfg.surfs;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ROImenu.atlases.neuromorphometrics = cfg.atlases;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ROImenu.atlases.lpba40 = cfg.atlases;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ROImenu.atlases.cobra = cfg.atlases;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ROImenu.atlases.hammers = cfg.atlases;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ROImenu.atlases.thalamus = cfg.atlases;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ROImenu.atlases.suit = cfg.atlases;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ROImenu.atlases.ibsr = cfg.atlases;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ROImenu.atlases.aal3 = cfg.atlases;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ROImenu.atlases.mori = cfg.atlases;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ROImenu.atlases.anatomy3 = cfg.atlases;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ROImenu.atlases.julichbrain = cfg.atlases;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ROImenu.atlases.Schaefer2018_100Parcels_17Networks_order = cfg.atlases;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ROImenu.atlases.Schaefer2018_200Parcels_17Networks_order = cfg.atlases;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ROImenu.atlases.Schaefer2018_400Parcels_17Networks_order = cfg.atlases;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ROImenu.atlases.Schaefer2018_600Parcels_17Networks_order = cfg.atlases;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ROImenu.atlases.ownatlas = {''};
matlabbatch{bnum}.spm.tools.cat.estwrite.output.GM.native = cfg.nat;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.GM.warped = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.GM.mod = 1;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.GM.dartel = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.WM.native = cfg.nat;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.WM.warped = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.WM.mod = 1;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.WM.dartel = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.CSF.native = cfg.nat;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.CSF.warped = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.CSF.mod = 1;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.CSF.dartel = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ct.native = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ct.warped = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.ct.dartel = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.pp.native = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.pp.warped = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.pp.dartel = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.WMH.native = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.WMH.warped = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.WMH.mod = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.WMH.dartel = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.SL.native = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.SL.warped = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.SL.mod = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.SL.dartel = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.TPMC.native = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.TPMC.warped = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.TPMC.mod = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.TPMC.dartel = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.atlas.native = cfg.atlasnative;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.label.native = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.label.warped = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.label.dartel = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.labelnative = cfg.labelnative;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.bias.native = cfg.gbiasmap;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.bias.warped = cfg.gbiasmap;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.bias.dartel = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.las.native = cfg.lbiasmap;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.las.warped = cfg.lbiasmap;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.las.dartel = 0;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.jacobianwarped = cfg.jac;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.warps = cfg.warps;
matlabbatch{bnum}.spm.tools.cat.estwrite.output.rmat = cfg.rmat;

bnum = bnum+1;

end

spm_jobman('run',matlabbatch); %comment out this line if you want to load in SPM GUI

# mri_preproc_pipelines
This is a pipeline for multimodal integration versions of sMRI, dMRI, and fMRI preprocessing pipelines.
Some parameters are adjusted for integrating across modalities that might otherwise differ for separate analyses (e.g., final voxel size, smoothing).

Developed and tested primarily in CENTOS 7.

Note that depending on computer setup, some tools might need admin privileges (e.g., su/sudo on Linux).
If errors are encountered, check that appropriate permissions are available for relevant directories and run pipeline with appropriate permissions.

Necessary tools include:

MATLAB (R2020 and above) - https://www.mathworks.com/

dcm2niix - https://github.com/rordenlab/dcm2niix/releases

Natural sort - https://mathworks.com/matlabcentral/fileexchange/47434-natural-order-filename-sort

SPM12 -  https://www.fil.ion.ucl.ac.uk/spm/software/spm12/

auto reorient code (github) - https://github.com/lrq3000/auto_acpc_reorient
Note that the following line in auto_acpc_reorient.m might need to be commented out to work with Linux, as case sensitivity seems to cause errors:
%img_type = lower(img_type);

spmScripts (github) - https://github.com/rordenlab/spmScripts
Specifically, a modified version of the nii_setOrigin12x.m is used to set the center of mass as the origin.

CAT12 (12.8+) - https://neuro-jena.github.io/cat/
Note that the defaults should be edited to use expert settings by default.

CONN - https://web.conn-toolbox.org/

FSL - https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/


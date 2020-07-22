# dwipre-NDWR

Preprocessing pipeline with FSL 5.0.11 eddy, specific to NDW_ROCKLAND DTI dataset.


## Assumptions

- Only a single entry is allowed in acq_params file. It is applied to all DWI volumes.

- b=0 volumes are indicated with a value of exactly 0 in the bval files.


## Pipeline

1. For the DWI run ("DIFF_137_AP"):

    a. A mean b=0 image is computed from all available b=0 volumes.
    
    b. BET is used to find a brain mask for the run.
    
4. EDDY is run on the series, using the mask from the previous step.


## Inputs

    --dwi_niigz <dwi.nii.gz>      DWI image set
    --dwi_bvals <dwi.bvals>
    --dwi_bvecs <dwi.bvecs>

    --bet_opts "-f 0.3 -R"            BET options (default shown)
    --acq_params "0 -1 0 0.05"        EDDY acq_params (default shown)

    --project <project_label>         Label information from XNAT
    --subject <subject_label>
    --session <session_label>

    --outdir <output_directory>       Results are stored here


## Outputs

    PDF                 QC report
	
    EDDY_NIFTI          Eddy-corrected DW images
    EDDY_BVALS
    EDDY_BVECS
    
    EDDY_OUT            Rest of EDDY output files
    
    B0_MEAN             Mean of b=0 images
    
    B0_MASK             Brain mask found by BET applied to B0_MEAN
    
    DTIFIT              Basic dtifit results from eddy corrected data

## Code info

Code authored by Suzanne Avery and edited by Baxter P. Rogers.

    xwrapper.sh                    Entry point for singularity container - sets up xvfb
     \- pipeline.sh                Entry to processing pipeline - parses inputs and calls processing code
         \- dwipre.sh              Workhorse
            functions.sh           Support functions for dwipre.sh
            qcplots.sh             QC images for PDF    
            organize_outputs.sh    Arranges outputs for DAX
    
    localtest.sh                   To run the pipeline outside the container (for testing)
    test_sing.sh                   Test the singularity container
    


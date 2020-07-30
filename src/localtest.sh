#!/bin/bash

export PATH=$(pwd):$PATH

pipeline.sh \
    --dwi_niigz ../INPUTS/dwi.nii.gz \
    --dwi_bvals ../INPUTS/dwi.bval \
    --dwi_bvecs ../INPUTS/dwi.bvec \
    --bet_opts "-f 0.3 -R" \
    --acq_params "0 -1 0 0.05" \
    --b0_thresh 10 \
    --project TESTPROJ \
    --subject TESTSUBJ \
    --session TESTSESS \
    --outdir ../OUTPUTS

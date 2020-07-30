#!/bin/bash

# Functions we will need
#      get_mask_from_b0
source functions.sh


# Copy input files to working directory, with specified filenames
cp "${dwi_niigz}" "${outdir}"/dwmri.nii.gz
cp "${dwi_bvals}" "${outdir}"/dwmri.bvals
cp "${dwi_bvecs}" "${outdir}"/dwmri.bvecs


# Work in outputs directory
cd "${outdir}"

## acqparams file
echo "Using acq_params ${acq_params}"
printf "${acq_params}\n" > acqparams.txt

## Brain mask on average b=0 of combined image set
get_mask_from_b0 dwmri.nii.gz dwmri.bvals "${b0_thresh}" b0

## Index file (one value for each volume of the final combined dwi image set)
# Assume all volumes had the same acq params, the first entry in acq_params.txt
dim4=$(fslval dwmri.nii.gz dim4)
if [ -e index.txt ] ; then rm -f index.txt ; fi
for i in $(seq 1 ${dim4}) ; do echo '1' >> index.txt ; done

## eddy correction
echo "EDDY"
eddy_openmp \
  --imain=dwmri.nii.gz \
  --mask=b0_mask.nii.gz \
  --acqp=acqparams.txt \
  --index=index.txt \
  --bvecs=dwmri.bvecs \
  --bvals=dwmri.bvals \
  --out=eddy \
  --verbose \
  --cnr_maps

# Capture the input bvals with the outputs
cp dwmri.bvals eddy.bvals

# Quick DTI fit for data check
echo "DTIFIT"
dtifit \
  --data=eddy.nii.gz \
  --bvecs=eddy.eddy_rotated_bvecs \
  --bvals=eddy.bvals \
  --mask=b0_mask.nii.gz \
  --save_tensor \
  --out=dtifit


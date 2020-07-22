#!/bin/bash

# Default BET options (note, -n -m are already hard-coded later, for pipeline 
# to work correctly)
export bet_opts="-f 0.3 -R"

# Default acquisition params. Only one line / one entry is accommodated
export acq_params="0 -1 0 0.05"

# Parse command line options
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --dwi_niigz)
        export dwi_niigz="$2" ; shift; shift;;
    --dwi_bvals)
        export dwi_bvals="$2" ; shift; shift;;
    --dwi_bvecs)
        export dwi_bvecs="$2" ; shift; shift;;
    --bet_opts)
        export bet_opts="$2"    ; shift; shift;;
    --acq_params)
        export acq_params="$2"  ; shift; shift;;
    --project)
        export project="$2"     ; shift; shift;;
    --subject)
        export subject="$2"     ; shift; shift;;
    --session)
        export session="$2"     ; shift; shift;;
    --outdir)
        export outdir="$2"      ; shift; shift;;
    *)
        echo "Ignoring unknown option ${1}"
        shift ;;
  esac
done

# Report inputs
echo "${project} ${subject} ${session}"
echo "    ${dwi_niigz}"
echo "       ${dwi_bvals}"
echo "       ${dwi_bvecs}"
echo "outdir: $outdir"
echo "bet_opts: $bet_opts"
echo "acq_params: $acq_params"

# Run eddy pipeline
dwipre.sh

# QC and PDF
qcplots.sh

# Organize outputs
organize_outputs.sh


#!/bin/bash

function get_nifti_geom {
  
  local nii_file="${1}"
  
  local val vals
  for field in dim1 dim2 dim3 sform_xorient sform_yorient sform_zorient ; do
    val=$(fslval "${nii_file}" $field)
    vals="${vals} ${val}"
  done
  vals="${vals} $(fslorient -getsform ${nii_file})"
  
  echo "${vals}"

}


function find_zero_bvals {

  local bval_file="${1}"  # Input bval file
  local thresh="${2}"     # b0 threshold value

  # Load bvals from file to array
  local bvals
  read -a bvals <<< "$(cat ${bval_file})"

  # Find 0-based index of volumes with b=0
  local zinds=()
  for i in "${!bvals[@]}"; do
    if (( $(echo "${bvals[i]} <= ${thresh}" |bc -l) )) ; then
      zinds+=($i)
    fi
  done

  echo ${zinds[@]}

}


function get_mask_from_b0 {

  local dwi_file="${1}"       # Input DWI file
  local bval_file="${2}"      # Matching bvals
  local thresh="${3}"         # Threshold for b=0
  local out_pfx="${4}"        # Prefix for outputs
                              #    ${out_pfx}.nii.gz        Masked mean b=0
                              #    ${out_pfx}_mean.nii.gz   Mean b=0
                              #    ${out_pfx}_mask.nii.gz   Brain mask
  
  # Find the volumes with b=0. FSL and bash both use 0-based indexing
  local zinds
  read -a zinds <<< "$(find_zero_bvals ${bval_file} ${thresh})"
  echo "Found b=0 volumes in ${dwi_file},${bval_file} at ${zinds[@]}"

  # Extract the b=0 volumes to temporary files
  local b0_files=()
  for ind in "${zinds[@]}" ; do
    local thisb0_file=$(printf 'tmp_b0_%04d.nii.gz' ${ind})
    b0_files+=("${thisb0_file}")
    fslroi "${dwi_file}" "${thisb0_file}" $ind 1 
  done
  
  # Register all b=0 volumes to the first one
  for b0_file in "${b0_files[@]}" ; do

    # No need to register the first one to itself
    if [[ "${b0_file}" == "${b0_files[0]}" ]] ; then continue; fi

    # FLIRT to register the others, overwriting the input image each time
    echo "Registering ${b0_file} to ${b0_files[0]}"
    flirt_opts="-bins 256 -cost corratio -searchrx -45 45 -searchry -45 45 -searchrz -45 45 -dof 6 -interp trilinear"
    flirt -in ${b0_file} -out ${b0_file} -ref ${b0_files[0]} ${flirt_opts}

  done

  # Average the registered b=0 volumes
  echo "Averaging b=0 images"
  fslmerge -t tmp_b0.nii.gz $(echo "${b0_files[@]}")
  fslmaths tmp_b0.nii.gz -Tmean "${out_pfx}_mean.nii.gz"
  
  # Compute brain mask
  echo "BET options -n -m ${bet_opts}"
  bet "${out_pfx}_mean.nii.gz" "${out_pfx}" -n -m ${bet_opts}

  # Clean up temp files
  rm -f ${b0_files[@]} tmp_b0.nii.gz
  
}



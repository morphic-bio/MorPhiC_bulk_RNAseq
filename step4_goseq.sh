#!/bin/bash

log_dir=step4_goseq_log
Rout_dir=step4_goseq_knit_Rout
html_dir=step4_goseq

mkdir ${log_dir}
mkdir ${Rout_dir}
mkdir ${html_dir}

ml fhR/4.1.2-foss-2021b

declare -a releases=(
  "2023_12_JAX_RNAseq_ExtraEmbryonic"
  "2024_05_JAX_RNAseq2_ExtraEmbryonic"
  "2024_06_JAX_RNAseq_Neuroectoderm"
  "2024_06_JAX_RNAseq4_ExEm_brain"
  "2024_09_JAX_RNAseq5_ExE_CBO"
  "2024_09_JAX_RNAseq6_Diverse"
  "2024_09_JAX_RNAseq7_Reversion"
)

for release_name in "${releases[@]}"; do

     R CMD BATCH --quiet --no-save \
     "--args release_name='${release_name}'" \
     step4_goseq_knit.R \
     ${Rout_dir}/step4_goseq_knit_${release_name}.Rout

done

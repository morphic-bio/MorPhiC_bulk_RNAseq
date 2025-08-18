#!/bin/bash

log_dir=step4_goseq_log
Rout_dir=step4_goseq_knit_Rout
html_dir=step4_goseq

ml fhR/4.1.2-foss-2021b

declare -a releases=(
  "2025_06_JAX_RNAseq08"
  "2025_06_JAX_RNAseq09"
  "2025_06_JAX_RNAseq10"
  "2025_06_JAX_RNAseq11"
)

for release_name in "${releases[@]}"; do

     R CMD BATCH --quiet --no-save \
     "--args release_name='${release_name}'" \
     step4_goseq_knit.R \
     ${Rout_dir}/step4_goseq_knit_${release_name}.Rout

done

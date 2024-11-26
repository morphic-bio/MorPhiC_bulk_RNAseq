
Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc")

render_report = function(release_name) {

  rmarkdown::render(
    "step5_draw_goseq.Rmd", 
    params = list(release_name = release_name),
    output_file = paste0("step5_draw_goseq/step5_draw_goseq_", release_name, ".html")
  )
}

rs = c("2023_12_JAX_RNAseq_ExtraEmbryonic"
       # "2024_05_JAX_RNAseq2_ExtraEmbryonic",
       # "2024_06_JAX_RNAseq_Neuroectoderm",
       # "2024_06_JAX_RNAseq4_ExEm_brain", 
       # "2024_09_JAX_RNAseq5_ExE_CBO",
       # "2024_09_JAX_RNAseq6_Diverse",
       # "2024_09_JAX_RNAseq7_Reversion",
       # "2024_09_UCSF_Bulk_EB_Timecourse"
       )


for(r1 in rs){
  render_report(r1)
}


sessionInfo()

q(save = "no")


Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc")

render_report = function(release_name) {

  rmarkdown::render(
    "step5_draw_goseq_2025_06_JAX_RNAseq.Rmd", 
    params = list(release_name = release_name),
    output_file = paste0("step5_draw_goseq/step5_draw_goseq_", release_name, ".html")
  )
}

rs = c("2025_06_JAX_RNAseq08",
       "2025_06_JAX_RNAseq09",
       "2025_06_JAX_RNAseq10",
       "2025_06_JAX_RNAseq11"
       )


for(r1 in rs){
  render_report(r1)
}


sessionInfo()

q(save = "no")


Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc")

render_report = function(release_name) {

  rmarkdown::render(
    "step5_draw_goseq_2026_01_MSK_bulkRNAseq_ISL1_OE.Rmd", 
    params = list(release_name = release_name),
    output_file = paste0("step5_draw_goseq_", release_name, ".html")
  )
}

rs = c("2026_01_MSK_bulkRNAseq_ISL1_OE")


for(r1 in rs){
  render_report(r1)
}


sessionInfo()

q(save = "no")

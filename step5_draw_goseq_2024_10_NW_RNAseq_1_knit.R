
Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc")

render_report = function(release_name) {

  rmarkdown::render(
    "step5_draw_goseq.Rmd", 
    params = list(release_name = release_name),
    output_file = paste0("step5_draw_goseq/step5_draw_goseq_", release_name, ".html")
  )
}

rs = c(
       "2024_10_NW_RNAseq_1"
       )


for(r1 in rs){
  render_report(r1)
}


sessionInfo()

q(save = "no")

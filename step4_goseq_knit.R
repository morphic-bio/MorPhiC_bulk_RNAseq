
Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/MacOS/pandoc")

render_report = function(release) {

  rmarkdown::render(
    "step4_goseq.Rmd", 
    params = list(release = release),
    output_file = paste0("step4_goseq_", release, ".html")
  )
}

rs = c("2023_12", "2024_05")
for(r1 in rs){
  render_report(r1)
}


sessionInfo()

q(save = "no")

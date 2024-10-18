args = commandArgs(trailingOnly=TRUE)
args

if (length(args) != 1) {
  message("One argument is expected.\n")
  quit(save="no")
}else{
  eval(parse(text=args[[1]]))
}

release_name

Sys.setenv(RSTUDIO_PANDOC="/app/software/RStudio-Server/1.4.1717-foss-2021b-Java-11-R-4.1.2/bin/pandoc")

library(rmarkdown)

render_report = function(release_name){

  output_filepath = paste0("step4_goseq/step4_goseq_", release_name, ".html")
  
  rmarkdown::render(
    "step4_goseq.Rmd", 
    params = list(release_name = release_name),
    output_file = output_filepath
  )
}

render_report(release_name)



sessionInfo()

q(save = "no")

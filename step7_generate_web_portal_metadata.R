# Format guide
# Each rows corresponds to a figure to show in the web portal.
# For each figure, specify the location of the tsv file corresponding to the plot.
# For GOPlot, currently .rds file is used instead of .tsv file, it's not attached to the figure for now, in consistent with release 1.

library(stringr)
library(tidyverse)
library(openxlsx)

columns = c(
  'DAV',
  'Dataset',
  'Gene Symbol',
  'DRACC Matrix',
  "Analysis Type",
  "Assay Type",	
  "DAV Matrix Name",
  "DAV Matrix Location",
  "Output Image Object",
  "Output Image Location",
  "Plot Title",
  "Script"	
)

DAV = 'Fred-Hutch'
datasets = paste0('JAX_RNAseq', c('08', '09', '10', '11'))

# List Volcano plots
data1 = NULL
for (dataset in datasets) {
  Dataset = dataset
  # Specify Gene Symbol later
  DRACC_Matrix = paste0(dataset, '.xlsx')
  Analysis_Type = 'VolcanoPlot'
  Assay_Type = 'Bulk RNAseq'
  # Specify DAV Matrix Name later
  DAV_Matrix_Location = paste0('MorPhiC_bulk_RNAseq/results/2025_06_', dataset, '/processed')
  # Specify Output Image Object later
  Output_Image_Location = paste0('MorPhiC_bulk_RNAseq/figures/2025_06_', dataset, '/volcano_plots')
  Output_Image_Object = list.files(paste0('figures/2025_06_', dataset, '/volcano_plots'), pattern = '.png')
  Plot_Title = sapply(Output_Image_Object, \(image) {
    title = strsplit(image, '\\.png')[[1]][1]
    if (dataset == 'JAX_RNAseq11') {
      tmp = strsplit(title, '_')[[1]]
      title = paste0(tmp[-4], collapse = '_')
    }
    title = str_replace_all(title, '_', ' ')
    paste0(title, ' vs WT')
  })
  Gene_Symbol = sapply(Plot_Title, \(title) {
    tmp = strsplit(title, ' ')[[1]]
    tmp[length(tmp) - 3]
  })
  DAV_Matrix_Name = sapply(Output_Image_Object, \(image) {
    image_name = strsplit(image, '\\.png')[[1]][1]
    if (dataset %in% c('JAX_RNAseq08', 'JAX_RNAseq09', 'JAX_RNAseq10')) {
      tmp = strsplit(image_name, '_(PTC|KO)')[[1]][1]
    } else if (dataset == 'JAX_RNAseq11') {
      tmp = strsplit(image_name, '_')[[1]]
      tmp = paste0(tmp[-length(tmp)], collapse = '_')
    }
    if (grepl('PrS', tmp)) {
      tmp1 = strsplit(tmp, '_')[[1]]
      stopifnot(length(tmp1) %in% c(4, 5))
      if (length(tmp1) == 4) {
        tmp1 = c(tmp1[1:3], 'nor', tmp1[4])
        tmp = paste0(tmp1, collapse = '_')
      }
    }
    file = paste0('2025_06_', dataset, '_', tmp, '_DEseq2.tsv')
    stopifnot(file.exists(paste0('results/2025_06_', dataset, '/processed/', file)))
    file
  })
  Script = paste0('step3_check_DE_2025_06_release_', dataset, '.Rmd')
  data1 = rbind(data1, tibble(
    'DAV' = DAV,
    'Dataset' = Dataset,
    'Gene Symbol' = Gene_Symbol,
    'DRACC Matrix' = DRACC_Matrix,
    'Analysis Type' = Analysis_Type,
    'Assay Type' = Assay_Type,
    'DAV Matrix Name' = DAV_Matrix_Name,
    'DAV Matrix Location' = DAV_Matrix_Location,
    'Output Image Object' = Output_Image_Object,
    'Output Image Location' = Output_Image_Location,
    'Plot Title' = Plot_Title,
    'Script' = Script
  ))
}

# List GOPlot figures
data2 = NULL
for (dataset in datasets) {
  Dataset = dataset
  # Specify Gene Symbol later
  DRACC_Matrix = paste0(dataset, '.xlsx')
  Analysis_Type = 'GOPlot'
  Assay_Type = 'Bulk RNAseq'
  DAV_Matrix_Name = paste0('2025_06_', dataset, '_enrichment.rds')
  DAV_Matrix_Location = paste0('MorPhiC_bulk_RNAseq/results/2025_06_', dataset, '/enrichment')
  stopifnot(file.exists(paste0('results/2025_06_', dataset, '/enrichment/', DAV_Matrix_Name)))
  # Specify Output Image Object later
  Output_Image_Location = paste0('MorPhiC_bulk_RNAseq/figures/2025_06_', dataset, '/goseq_plots')
  Output_Image_Object = list.files(paste0('figures/2025_06_', dataset, '/goseq_plots'), pattern = '.png')
  Plot_Title = sapply(Output_Image_Object, \(image) {
    title = strsplit(image, '\\.png')[[1]][1]
    if (dataset == 'JAX_RNAseq11') {
      tmp = strsplit(title, '_')[[1]]
      stopifnot(length(tmp) %in% c(5, 7))
      if (length(tmp) == 5) tmp = c(tmp[1:3], 'PTC', tmp[4], 'PTC', tmp[5])
      title = paste0(tmp[-4], collapse = '_')
    }
    str_replace_all(title, '_', ' ')
  })
  Gene_Symbol = sapply(Plot_Title, \(title) {
    tmp = strsplit(title, ' ')[[1]]
    tmp = tmp[!(tmp %in% c('PTC', 'KO', 'CE'))]
    tmp[length(tmp) - 1]
  })
  Script = 'step4_goseq_2025_06_JAX_RNAseq.sh'
  data2 = rbind(data2, tibble(
    'DAV' = DAV,
    'Dataset' = Dataset,
    'Gene Symbol' = Gene_Symbol,
    'DRACC Matrix' = DRACC_Matrix,
    'Analysis Type' = Analysis_Type,
    'Assay Type' = Assay_Type,
    'DAV Matrix Name' = DAV_Matrix_Name,
    'DAV Matrix Location' = DAV_Matrix_Location,
    'Output Image Object' = Output_Image_Object,
    'Output Image Location' = Output_Image_Location,
    'Plot Title' = Plot_Title,
    'Script' = Script
  ))
}

# Combine & write
data = rbind(data1, data2)
write.xlsx(data, file = 'meta_data_web_portal/JAX_bulk_RNAseq_release2.xlsx', overwrite = TRUE)

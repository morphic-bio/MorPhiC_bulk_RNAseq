# Generate DAV web-portal metadata (new template format) for JAX_RNAseq12 + 13.
#
# This script reads `experiment.rds` produced by the stage Rmd workflow and
# fills the first sheet of the current DAV input template.
#
# Output: an .xlsx with two types of rows:
#   - Analysis Type = "DGE": per-contrast DESeq2 matrices (and volcano PNG paths).
#   - Analysis Type = "Enrichment": enrichment PNG paths (up/down).
#
# Notes:
# - The template may change per release; keep templates versioned under
#   `meta_data_web_portal/templates/`.
# - Paths written are relative to the repo root, prefixed by `repo_prefix`
#   (consistent with prior `meta_data_web_portal/JAX_bulk_RNAseq_release2.xlsx`).

suppressPackageStartupMessages({
  library(openxlsx)
})

`%||%` <- function(x, y) if (is.null(x)) y else x

template_file <- "meta_data_web_portal/templates/DAV_input_template_filled_example.xlsx"
out_file <- "meta_data_web_portal/DAV_input_2025_12_JAX_RNAseq12_13.xlsx"

expt_files <- c(
  "experiments/JAX_RNAseq12/outputs/experiment.rds",
  "experiments/JAX_RNAseq13/outputs/experiment.rds"
)

stopifnot(file.exists(template_file))
stopifnot(all(file.exists(expt_files)))

path_join <- function(...) {
  p <- file.path(...)
  gsub("/+", "/", p)
}

parse_de_group <- function(de_group) {
  m <- regexec("^([^_]+)_day([0-9]+(?:\\.[0-9]+)?)_([^_]+)_(.+)$", de_group)
  mm <- regmatches(de_group, m)[[1]]
  if (length(mm) == 0) {
    stop("Cannot parse de_group label: ", de_group, call. = FALSE)
  }
  list(
    model_system = mm[2],
    day = mm[3],
    condition = mm[4],
    gene_group = mm[5]
  )
}

condition_to_annotation <- function(cond) {
  cond <- as.character(cond)
  cond[is.na(cond)] <- ""
  ifelse(tolower(cond) %in% c("hyp", "hypoxia"), "hypoxia", "normoxia")
}

direction_label <- function(direction) {
  direction <- tolower(as.character(direction))
  ifelse(direction == "up", "Up-regulated", "Down-regulated")
}

build_dge_rows <- function(expt, expt_dir) {
  DAV <- "Fred-Hutch"
  dataset <- expt$de$stage4$output_prefix %||% expt$config$output_prefix
  if (is.null(dataset) || !nzchar(dataset)) stop("Missing output_prefix in experiment object.", call. = FALSE)

  dataset_short <- gsub("^JAX_", "", expt$dataset_name %||% "")
  if (!nzchar(dataset_short)) dataset_short <- dataset

  counts_name <- basename(expt$paths$counts_file %||% "genesCounts.csv")
  assay <- "Bulk RNAseq"
  analysis <- "DGE"

  processed_dir <- expt$de$stage4$processed_dir %||% "outputs/processed"
  processed_dir <- gsub("/+$", "", processed_dir)

  script <- path_join(expt_dir, "stage4_deseq2_de.Rmd")

  cs <- expt$de$stage4$contrast_summary
  if (is.null(cs) || nrow(cs) == 0) return(NULL)

  # Volcano file map: {de_group}_{gene}_{strategy}.png -> relative path under expt.
  vol_files <- expt$plots$stage5$volcano$files %||% character(0)
  vol_map <- setNames(vol_files, basename(vol_files))

  rows <- lapply(seq_len(nrow(cs)), function(i) {
    de_group <- as.character(cs$de_group[i])
    ko_gene <- as.character(cs$ko_gene[i])
    ko_strategy <- as.character(cs$ko_strategy[i])
    n_ko <- as.integer(cs$n_ko[i])
    n_wt <- as.integer(cs$n_WT[i])
    n_samples <- n_ko + n_wt

    grp <- parse_de_group(de_group)
    anno <- condition_to_annotation(grp$condition)

    matrix_file <- sprintf("%s_%s_%s_%s_DEseq2.tsv", dataset, de_group, ko_gene, ko_strategy)
    matrix_path <- path_join(expt_dir, processed_dir, matrix_file)

    volcano_name <- sprintf("%s_%s_%s.png", de_group, ko_gene, ko_strategy)
    volcano_rel <- vol_map[[volcano_name]] %||% NA_character_
    volcano_path <- if (is.na(volcano_rel)) NA_character_ else path_join(expt_dir, volcano_rel)

    data.frame(
      DAV = DAV,
      Dataset = dataset,
      `Gene Symbol` = ko_gene,
      `DRACC Matrix` = counts_name,
      `Analysis Type` = analysis,
      `Number of Samples` = n_samples,
      `Number of WT` = n_wt,
      `Description (optional)` = paste("JAX", dataset_short, grp$model_system),
      Condition = paste0("day ", grp$day, " ", anno, " ", ko_gene, " ", ko_strategy, " vs WT"),
      `additional annotation` = "",
      `Assay Type` = assay,
      `DAV Matrix` = matrix_file,
      `Output Image Object` = if (is.na(volcano_rel)) NA_character_ else basename(volcano_rel),
      `Plot Title` = NA_character_,
      `DAV Matrix Location` = matrix_path,
      `DAV SVG location` = volcano_path,
      Script = script,
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
  })

  do.call(rbind, rows)
}

build_enrichment_rows <- function(expt, expt_dir) {
  DAV <- "Fred-Hutch"
  dataset <- expt$de$stage4$output_prefix %||% expt$config$output_prefix
  if (is.null(dataset) || !nzchar(dataset)) stop("Missing output_prefix in experiment object.", call. = FALSE)

  dataset_short <- gsub("^JAX_", "", expt$dataset_name %||% "")
  if (!nzchar(dataset_short)) dataset_short <- dataset

  counts_name <- basename(expt$paths$counts_file %||% "genesCounts.csv")
  assay <- "Bulk RNAseq"
  analysis <- "Enrichment"
  script <- path_join(expt_dir, "stage5_volcano_enrichment.Rmd")

  files <- expt$plots$stage5$goseq$files %||% character(0)
  if (length(files) == 0) return(NULL)

  rows <- lapply(files, function(rel) {
    b <- sub("\\.png$", "", basename(rel))
    parts <- strsplit(b, "_", fixed = TRUE)[[1]]
    if (length(parts) < 4) stop("Unexpected enrichment filename: ", basename(rel), call. = FALSE)

    direction <- parts[length(parts)]
    ko_strategy <- parts[length(parts) - 1]
    ko_gene <- parts[length(parts) - 2]
    de_group <- paste(parts[1:(length(parts) - 3)], collapse = "_")

    grp <- parse_de_group(de_group)
    anno <- condition_to_annotation(grp$condition)

    img_path <- path_join(expt_dir, rel)

    data.frame(
      DAV = DAV,
      Dataset = dataset,
      `Gene Symbol` = ko_gene,
      `DRACC Matrix` = counts_name,
      `Analysis Type` = analysis,
      `Number of Samples` = NA,
      `Number of WT` = NA,
      `Description (optional)` = paste("JAX", dataset_short, grp$model_system),
      Condition = paste0("day ", grp$day, " ", anno, " ", ko_gene, " ", direction_label(direction)),
      `additional annotation` = "",
      `Assay Type` = assay,
      `DAV Matrix` = NA_character_,
      `Output Image Object` = basename(rel),
      `Plot Title` = NA_character_,
      `DAV Matrix Location` = NA_character_,
      `DAV SVG location` = img_path,
      Script = script,
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
  })

  do.call(rbind, rows)
}

build_rows_for_expt <- function(expt_file) {
  expt <- readRDS(expt_file)
  expt_dir <- dirname(dirname(expt_file)) # experiments/JAX_RNAseqXX

  d1 <- build_dge_rows(expt, expt_dir)
  d2 <- build_enrichment_rows(expt, expt_dir)
  out <- rbind(d1, d2)
  out
}

rows <- do.call(rbind, lapply(expt_files, build_rows_for_expt))

# Use the exact column order from the template (sheet 1).
sheet_names <- getSheetNames(template_file)
if (length(sheet_names) == 0) stop("Template has no sheets: ", template_file, call. = FALSE)
sheet1 <- sheet_names[1]
col_order <- c(
  "DAV",
  "Dataset",
  "Gene Symbol",
  "DRACC Matrix",
  "Analysis Type",
  "Number of Samples",
  "Number of WT",
  "Description (optional)",
  "Condition",
  "additional annotation",
  "Assay Type",
  "DAV Matrix",
  "Output Image Object",
  "Plot Title",
  "DAV Matrix Location",
  "DAV SVG location",
  "Script"
)
missing_cols <- setdiff(col_order, colnames(rows))
if (length(missing_cols) > 0) stop("Missing expected columns: ", paste(missing_cols, collapse = ", "), call. = FALSE)
rows <- rows[, col_order, drop = FALSE]

# Rebuild a clean workbook (keeps template sheet names, but avoids carrying any
# potentially incompatible workbook-view metadata from the template).
wb <- createWorkbook()
for (s in sheet_names) addWorksheet(wb, s)
writeData(wb, sheet = sheet1, x = rows, withFilter = TRUE)

dir.create(dirname(out_file), recursive = TRUE, showWarnings = FALSE)
saveWorkbook(wb, file = out_file, overwrite = TRUE)

cat("Wrote DAV input xlsx: ", out_file, "\n", sep = "")

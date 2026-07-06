suppressPackageStartupMessages({
  library(data.table)
  library(openxlsx)
})

repo_dir <- "."
release_name <- "2026_01_MSK_bulkRNAseq_ISL1_OE"
dataset <- release_name

result_dir <- file.path(repo_dir, "results", release_name)
processed_dir <- file.path(result_dir, "processed")
figure_dir <- file.path(repo_dir, "figures", release_name)
volcano_dir <- file.path(figure_dir, "volcano_plots")
goseq_dir <- file.path(figure_dir, "goseq_plots")
metadata_file <- file.path(repo_dir, "data", "Jan_2026",
                           "MSK_bulkRNAseq_ISL1_OE_meta_data.tsv")
raw_metadata_xlsx <- file.path(repo_dir, "data", "Jan_2026",
                               "R4_MSK_RNAseq_Prod.xlsx")

out_dir <- file.path(repo_dir, "dav_input")
out_xlsx <- file.path(out_dir,
                      "DAV_input_2026_01_MSK_bulkRNAseq_ISL1_OE.xlsx")
out_tsv <- file.path(out_dir,
                     "DAV_input_2026_01_MSK_bulkRNAseq_ISL1_OE.tsv")

stopifnot(file.exists(metadata_file))
stopifnot(file.exists(raw_metadata_xlsx))
stopifnot(dir.exists(processed_dir))

col_order <- c(
  "DAV",
  "study_title",
  "dataset",
  "Assay_Type",
  "HGNC_IDs",
  "Gene_symbol",
  "DRACC Matrix",
  "Analysis_Type",
  "Analysis_type_outcome",
  "Number of Samples",
  "Number of WT",
  "Perturbation_count",
  "Pertubed_location",
  "model_system_abbr",
  "model_organ",
  "timepoint",
  "condition",
  "analysis_condition1",
  "analysis_condition2",
  "Description (optional)",
  "title",
  "additional annotation",
  "DAV Matrix",
  "Output Image Object",
  "DAV Matrix Location",
  "DAV SVG location",
  "Script"
)

path_join <- function(...) {
  gsub("/+", "/", file.path(...))
}

blank_row <- function() {
  x <- as.list(rep("", length(col_order)))
  names(x) <- col_order
  as.data.frame(x, stringsAsFactors = FALSE, check.names = FALSE)
}

expr_alt <- read.xlsx(raw_metadata_xlsx,
                      sheet = "Expression alteration",
                      colNames = TRUE)
expr_alt <- expr_alt[
  !is.na(expr_alt$ALTERED.GENE.SYMBOL) &
    !is.na(expr_alt$HGNC.ID) &
    grepl("^HGNC:[0-9]+$", expr_alt$HGNC.ID),
]
hgnc_map <- setNames(expr_alt$HGNC.ID, expr_alt$ALTERED.GENE.SYMBOL)

meta <- fread(metadata_file, data.table = FALSE)
timepoint <- ""
if ("timepoint_value" %in% names(meta)) {
  timepoint_values <- unique(na.omit(meta$timepoint_value))
  if (length(timepoint_values) == 1) timepoint <- paste("day", timepoint_values)
}
model_system <- ""
if ("model_system" %in% names(meta)) {
  model_system_values <- unique(na.omit(meta$model_system))
  if (length(model_system_values) == 1) model_system <- model_system_values
}
condition_value <- ""
if ("condition" %in% names(meta)) {
  condition_values <- unique(na.omit(meta$condition))
  if (length(condition_values) == 1) condition_value <- condition_values
}

base_row <- function(gene_symbol, analysis_type) {
  row <- blank_row()
  row$DAV <- "Fred-Hutch"
  row$study_title <- "MSK bulk RNA-seq ISL1 OE"
  row$dataset <- dataset
  row$Assay_Type <- "Bulk RNAseq"
  row$HGNC_IDs <- if (gene_symbol %in% names(hgnc_map)) {
    hgnc_map[[gene_symbol]]
  } else {
    ""
  }
  if (is.null(row$HGNC_IDs) || is.na(row$HGNC_IDs)) row$HGNC_IDs <- ""
  row$Gene_symbol <- gene_symbol
  row$`DRACC Matrix` <- "genesCounts.csv"
  row$Analysis_Type <- analysis_type
  row$Perturbation_count <- "Single"
  row$model_system_abbr <- model_system
  row$timepoint <- timepoint
  row$condition <- condition_value
  row$`Description (optional)` <- paste("MSK bulkRNAseq ISL1 OE",
                                        model_system)
  row
}

volcano_file_for_dge <- function(kind, background = "", gene_symbol = "") {
  if (kind == "oe") {
    paste0(background, "_ISL1_OE_volcano.png")
  } else {
    paste0("control_", gene_symbol, "_KO_vs_WT_volcano.png")
  }
}

build_oe_dge_rows <- function() {
  n_file <- file.path(result_dir,
                      paste0(release_name, "_DE_n_samples.tsv"))
  stopifnot(file.exists(n_file))
  n_tab <- fread(n_file, data.table = FALSE)

  rows <- lapply(seq_len(nrow(n_tab)), function(i) {
    background <- as.character(n_tab$cell_line[i])
    n_ko <- as.integer(n_tab$n_ko[i])
    n_wt <- as.integer(n_tab$n_WT[i])
    matrix_file <- paste0(release_name, "_",
                          as.character(n_tab$DE_group[i]), "_",
                          background, "_ISL1_OE_DEseq2.tsv")
    volcano_file <- volcano_file_for_dge("oe", background = background)

    row <- base_row("ISL1", "DGE")
    row$`Number of Samples` <- as.character(n_ko + n_wt)
    row$`Number of WT` <- as.character(n_wt)
    row$analysis_condition1 <- paste0(background, "_ISL1_OE")
    row$analysis_condition2 <- paste0(background, "_control")
    row$title <- paste(timepoint, row$analysis_condition1, "vs",
                       row$analysis_condition2)
    row$`DAV Matrix` <- matrix_file
    row$`Output Image Object` <- if (file.exists(file.path(volcano_dir,
                                                           volcano_file))) {
      volcano_file
    } else {
      ""
    }
    row$`DAV Matrix Location` <- path_join("results", release_name,
                                           "processed", matrix_file)
    row$`DAV SVG location` <- if (nzchar(row$`Output Image Object`)) {
      path_join("figures", release_name, "volcano_plots", volcano_file)
    } else {
      ""
    }
    row$Script <- "step2_DE_testing_2026_01_MSK_ISL1_OE.Rmd"
    row
  })

  rbindlist(rows, fill = TRUE)
}

build_control_dge_rows <- function() {
  n_file <- file.path(result_dir,
                      paste0(release_name,
                             "_DE_control_KO_vs_WT_n_samples.tsv"))
  stopifnot(file.exists(n_file))
  n_tab <- fread(n_file, data.table = FALSE)

  rows <- lapply(seq_len(nrow(n_tab)), function(i) {
    ko_strategy <- as.character(n_tab$knockout_gene_strategy[i])
    gene_symbol <- sub("_KO$", "", ko_strategy)
    n_ko <- as.integer(n_tab$n_ko[i])
    n_wt <- as.integer(n_tab$n_WT[i])
    matrix_file <- paste0(release_name, "_",
                          as.character(n_tab$DE_group[i]), "_control_",
                          ko_strategy, "_vs_WT_DEseq2.tsv")
    volcano_file <- volcano_file_for_dge("control", gene_symbol = ko_strategy)

    row <- base_row(gene_symbol, "DGE")
    row$`Number of Samples` <- as.character(n_ko + n_wt)
    row$`Number of WT` <- as.character(n_wt)
    row$analysis_condition1 <- paste0(ko_strategy, "_control")
    row$analysis_condition2 <- "WT_control"
    row$title <- paste(timepoint, row$analysis_condition1, "vs",
                       row$analysis_condition2)
    row$`DAV Matrix` <- matrix_file
    row$`Output Image Object` <- if (file.exists(file.path(volcano_dir,
                                                           volcano_file))) {
      volcano_file
    } else {
      ""
    }
    row$`DAV Matrix Location` <- path_join("results", release_name,
                                           "processed", matrix_file)
    row$`DAV SVG location` <- if (nzchar(row$`Output Image Object`)) {
      path_join("figures", release_name, "volcano_plots", volcano_file)
    } else {
      ""
    }
    row$Script <- "step2_DE_testing_2026_01_MSK_ISL1_OE.Rmd"
    row
  })

  rbindlist(rows, fill = TRUE)
}

infer_gene_symbol <- function(analysis_condition1) {
  if (grepl("_ISL1_OE$", analysis_condition1)) return("ISL1")
  if (grepl("_KO_control$", analysis_condition1)) {
    return(sub("_KO_control$", "", analysis_condition1))
  }
  ""
}

parse_goseq_file <- function(file_path) {
  b <- sub("\\.png$", "", basename(file_path))
  parts <- strsplit(b, "_", fixed = TRUE)[[1]]
  direction <- parts[length(parts)]
  core <- parts[-length(parts)]
  vs_i <- which(core == "vs")
  if (length(vs_i) != 1 || vs_i <= 3 || vs_i >= length(core)) {
    stop("Unexpected goseq filename: ", basename(file_path), call. = FALSE)
  }
  list(
    title = paste(core[1], core[2],
                  paste(core[3:(vs_i - 1)], collapse = "_"),
                  "vs",
                  paste(core[(vs_i + 1):length(core)], collapse = "_")),
    analysis_condition1 = paste(core[3:(vs_i - 1)], collapse = "_"),
    analysis_condition2 = paste(core[(vs_i + 1):length(core)], collapse = "_"),
    direction = direction
  )
}

build_enrichment_rows <- function() {
  files <- list.files(goseq_dir, pattern = "\\.png$", full.names = TRUE)
  if (length(files) == 0) return(data.frame())

  rows <- lapply(sort(files), function(f) {
    parsed <- parse_goseq_file(f)
    gene_symbol <- infer_gene_symbol(parsed$analysis_condition1)
    row <- base_row(gene_symbol, "Enrichment")
    row$Analysis_type_outcome <- parsed$direction
    row$analysis_condition1 <- parsed$analysis_condition1
    row$analysis_condition2 <- parsed$analysis_condition2
    row$title <- paste(parsed$title, parsed$direction)
    row$`Output Image Object` <- basename(f)
    row$`DAV SVG location` <- path_join("figures", release_name,
                                        "goseq_plots", basename(f))
    row$Script <- "step5_draw_goseq_2026_01_MSK_bulkRNAseq_ISL1_OE.Rmd"
    row
  })

  rbindlist(rows, fill = TRUE)
}

rows <- rbindlist(list(build_oe_dge_rows(),
                       build_control_dge_rows(),
                       build_enrichment_rows()),
                  fill = TRUE)

missing_cols <- setdiff(col_order, names(rows))
if (length(missing_cols) > 0) {
  stop("Missing expected columns: ", paste(missing_cols, collapse = ", "),
       call. = FALSE)
}
rows <- rows[, col_order, with = FALSE]
rows[is.na(rows)] <- ""

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
fwrite(rows, out_tsv, sep = "\t", quote = FALSE, na = "")

wb <- createWorkbook()
addWorksheet(wb, "Input_MSK_bulkRNAseq_ISL1_OE")
writeData(wb, sheet = 1, x = rows, withFilter = TRUE)
saveWorkbook(wb, file = out_xlsx, overwrite = TRUE)

cat("Wrote DAV input TSV: ", out_tsv, "\n", sep = "")
cat("Wrote DAV input XLSX: ", out_xlsx, "\n", sep = "")
cat("Rows: ", nrow(rows), "\n", sep = "")

# Web Portal Metadata (DAV Input)

This folder contains inputs and helper scripts for generating MorPhiC web portal
metadata spreadsheets in the current DAV template format.

## Organization

- `templates/`: DAV-provided templates/examples (these may change across releases).
- `generate_dav_input_*.R`: release-specific generators that fill sheet 1 of the
  template using analysis outputs produced in this repo.
- `DAV_input_*.xlsx`: generated DAV input files ready to send to the portal team.

## How it works (high level)

The DAV input spreadsheet is a *manifest* of portal items:
- `Analysis Type = DGE`: a per-gene DE matrix (TSV) + a volcano plot image.
- `Analysis Type = Enrichment`: a static enrichment plot image (up/down).

Generators in this folder typically build those rows from:
- `experiments/*/outputs/processed/*_DEseq2.tsv`
- `experiments/*/outputs/figures/volcano_plots/*.png`
- `experiments/*/outputs/figures/goseq_plots/*.png`

File locations are written as repo-relative paths (no `MorPhiC_bulk_RNAseq/` prefix).

## December 2025 JAX bulk RNA-seq (datasets 12 and 13)

- Template (reference): `meta_data_web_portal/templates/DAV_input_template_filled_example.xlsx`
- Generator: `meta_data_web_portal/generate_dav_input_2025_12_JAX_RNAseq12_13.R`
- Output: `meta_data_web_portal/DAV_input_2025_12_JAX_RNAseq12_13.xlsx`

Run from repo root:

```bash
/home/byu2/anaconda3/envs/morphic/bin/Rscript meta_data_web_portal/generate_dav_input_2025_12_JAX_RNAseq12_13.R
```

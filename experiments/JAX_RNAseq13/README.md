# JAX_RNAseq13
Mini-experiment for the December 2025 JAX_RNAseq13 bulk RNA-seq release.

**Dataset Summary**
- 45 samples from KOLF2.2J.
- Day 5, ENDO (18) and MESO (27).
- 6 WT for ENDO, 9 WT for MESO, 3 KO on 2 genes for MESO, and 3 PTC on 8 genes under one of the two systems.
- 3 runs (38 + 6 + 1), default condition.

**Dataset Notes**
- Use corrected metadata workbook:
  `metadata/JAX_RNAseq13_metadata_CORRECTED_FinalVersion.xlsx`.
- Run ID merge (after Stage 3 PCA review): if the singleton run
  `20250724_GT25-RobsonP-125-run2` clusters with `20250702_GT25-RobsonP-125`,
  we merge it to `20250702_GT25-RobsonP-125` before Stage 4 DE so `run_id` is
  estimable.
- If clonal labels between `dc` and `cl` differ due to missing a leading `1` for
  2-digit tokens (e.g., `..._46` vs `..._146`), Stage 1 normalizes `cl$clonal.label`
  before merging and stops if mismatches remain.
- WT control parsing tolerates hyphen separators (e.g., `MOK...-141-WT1`) by
  normalizing `-` to `_` before tokenizing.

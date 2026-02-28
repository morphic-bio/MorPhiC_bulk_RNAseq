# JAX_RNAseq12
Mini-experiment for the December 2025 JAX_RNAseq12 bulk RNA-seq release.

**Dataset Summary**
- 21 samples from KOLF2.2J.
- Day 6, ExM and PrS.
- 6 WT and 15 PTC across 5 KO genes (ELK3, SNAI2, SOX7, TFEB, ZNF175).
- 2 runs (12 + 9), default condition.

**Dataset-Specific Fixes**
- WT clonal descriptions are inferred from KO clone labels.
- Inference assumes short numeric tokens share the same hundred digit as the base clone ID (e.g., `MOK20126_46` -> 126 and 146).

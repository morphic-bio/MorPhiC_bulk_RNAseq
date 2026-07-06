bulk RNAseq dataset: Jan 2026 release MSK_bulkRNAseq_ISL1_OE

There is only one model system involved in this dataset, pancreatic islet.

There are two levels of expression alternations, one is gene knockout KO (ISL1/PAX6/PDX1/WT) and the other one is ISL1 overexpression OE.
The samples are combined into one DE group to run DESeq2 on.
Which is to say, a DESeq2 model is fit on the group of all samples, and the DE results of comparison in interest are extracted from the fitted model.

Two types of DE tests were run on this dataset:

(1) The first type is between ISL1 gene OE and the corresponding control for OE.
For this type of tests, the number of samples in each contrast are listed in this file:
    2026_01_MSK_bulkRNAseq_ISL1_OE_DE_n_samples.tsv

(2) The second type is only among the control for OE samples, between each gene KO and WT.
For this type of tests, the number of samples in each contrast are listed in this file:
    2026_01_MSK_bulkRNAseq_ISL1_OE_DE_control_KO_vs_WT_n_samples.tsv
    
For this dataset, the dispersion parameter estimate for one gene GCG (ENSG00000115263) is patched

* this is the gene with -log10(pvalue from limma-voom / pvalue from DESeq2) > 3 
* for this highly expressed genes, the dispersion estimate is patched to DESeq2's un-reverted niter=2 value, 
  since the default niter=1 fit's noIncrease guard discarded the correct low dispersion and kept an inflated design-blind seed, 
  inflating the standard error and masking a genuine effect.
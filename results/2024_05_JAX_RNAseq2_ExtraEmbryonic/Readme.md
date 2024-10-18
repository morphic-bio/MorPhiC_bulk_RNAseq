bulk RNAseq dataset: May 2024 release 2024_05_JAX_RNAseq2_ExtraEmbryonic

There are two model systems involved in this dataset, ExM & PrS.

The samples are separated into different DE groups to run DESeq2 on.
Which is to say, a DESeq2 model is fit on each group of samples, and the DE results of comparison in interest are extracted from the fitted model.

One type of DE tests were run on this dataset:

between knockout_gene_strategy and WT samples.

For this type of tests, the DE group information is listed in the first column of the file:
    2024_05_JAX_RNAseq2_ExtraEmbryonic_DE_n_samples.tsv

For the (model_system, day) combination ExM_day_6, from the PC plot, the batch effect due to the run ids seems big.
Run DESeq2 on samples under each run id separately.

For the (model_system, day) combination PrS_day_6, from the PC plots, the WT samples from multiple runs appear close to each other.
To borrow strength from WT samples across different runs, run DESeq2 on all samples under this combination together, while incoporating run_id in the model.

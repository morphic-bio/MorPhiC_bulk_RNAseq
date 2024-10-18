bulk RNAseq dataset: June 2024 release JAX_RNAseq4_ExEm_brain

There are two model systems involved in this dataset, CBO and PrS.

There are samples from multiple days.

The samples are separated into different DE groups to run DESeq2 on.
Which is to say, a DESeq2 model is fit on each group of samples, and the DE results of comparison in interest are extracted from the fitted model.

One type of DE tests were run on this dataset:

Between knockout_gene_strategy and WT samples.

For this type of tests, the DE group information is listed in the first column of the file:
    2024_06_JAX_RNAseq4_ExEm_brain_DE_n_samples.tsv

For model system CBO, CBO_day_9 is treated as one DE group.
CBO_day_32 is excluded from DE analysis because it only has one WT sample.

For model system PrS, under PrS_day_6, the two run ids is each treated as a DE group due to a big difference between these two run ids as shown on the PC plot.

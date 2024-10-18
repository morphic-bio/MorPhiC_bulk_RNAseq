bulk RNAseq dataset: June 2024 release JAX_RNAseq_Neuroectoderm

There is only one model system involved in this dataset, CBO.

There are samples from multiple days.

The samples are separated into different DE groups to run DESeq2 on.
Which is to say, a DESeq2 model is fit on each group of samples, and the DE results of comparison in interest are extracted from the fitted model.

One types of DE tests were run on this dataset:

Between knockout_gene_strategy and WT samples.
For this type of tests, the DE group information is listed in the first column of the file:
    2024_06_JAX_RNAseq_Neuroectoderm_DE_n_samples.tsv

The DE groups are constructed based on days.

For day 3 and day 4, they are combined into one DE group, because each of them only has one WT sample and also they appear close on the PC plot.
A day indicator is included in the model.

For days 6, 7, 8, and 9, they are each treated as a DE group separately.
Among which, for day 8, the samples from run ID 20230424_23-scbct-028-run3 were excluded because the batch effect seems to be big on the PC plot.

Day 5 and day 14 were excluded from DE test because they each only has one WT sample.

bulk RNAseq dataset: September 2024 release JAX_RNAseq5_ExE_CBO

There are two model systems involved in this dataset, CBO and PrS.

There are samples from multiple days.

The samples are separated into different DE groups to run DESeq2 on.
Which is to say, a DESeq2 model is fit on each group of samples, and the DE results of comparison in interest are extracted from the fitted model.

One type of DE tests were run on this dataset:

Between knockout_gene_strategy and WT samples.

For this type of tests, the DE group information is listed in the first column of the file:
    2024_09_JAX_RNAseq5_ExE_CBO_DE_n_samples.tsv

For model system CBO, CBO_day_8 and CBO_day_22 are each treated as one DE group.

For model system PrS, under PrS_day_6, the knockout gene groups are used as DE groups.

* Meaning of knockout gene group:
this comes from which knockout genes the WT samples are for.
In some cases, the WT samples are specifically for certain knockout gene.
In some other cases, the WT samples are shared for multiple knockout genes.
In both cases, the samples under knockout gene(s) and the WT samples for them are viewed as forming one knockout gene group.

For example, DE group PrS_day_6_DLX4-DLX5-DLX6 refers to all knockout samples under genes DLX4, DLX5, and DLX6, together with the WT samples shared by them.

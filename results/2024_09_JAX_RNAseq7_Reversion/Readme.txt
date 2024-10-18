bulk RNAseq dataset: September 2024 release JAX_RNAseq7_Reversion

This dataset are mostly about reversion of PTC.

There are two model systems involved in this dataset, CBO and PrS.

There are also both normoxia and hypoxia samples involved in this dataset.

For all genes in this dataset, there are samples from reversion of PTC.
For one gene, PAX6, there are samples from both PTC and reversion of PTC.

There are samples from multiple days.

The samples are separated into different DE groups to run DESeq2 on.
Which is to say, a DESeq2 model is fit on each group of samples, and the DE results of comparison in interest are extracted from the fitted model.

Two types of DE tests were run on this dataset:

(1) Between knockout_gene_strategy and WT samples.

For this type of tests, the DE group information is listed in the first column of the file:
    2024_09_JAX_RNAseq7_Reversion_DE_n_samples.tsv

For model system CBO, all samples are under day_9, and day_9 is treated as one DE group.

For model system PrS, all samples are under day_6.
For condition hypoxia, PrS_day_6_hyp is treated as one DE group.
For condition normoxia, treat each knockout gene group as one DE group.

* Meaning of knockout gene group:
this comes from which knockout genes the WT samples are for.
In some cases, the WT samples are specifically for certain knockout gene.
In some other cases, the WT samples are shared for multiple knockout genes.
In both cases, the samples under knockout gene(s) and the WT samples for them are viewed as forming one knockout gene group,
and the group is named after the names of the knockout genes.


(2) Between normoxia and hypoxia conditions.
For this type of tests, the samples involved are WT samples and knockout samples specific to the comparison between normoxia and hypoxia conditions.
The model system and day information for these samples is listed in the first column of the file:
    2024_09_JAX_RNAseq7_Reversion_DE_hyp_vs_nor_n_samples.tsv

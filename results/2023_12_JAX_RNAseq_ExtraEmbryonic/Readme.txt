bulk RNAseq dataset: December 2023 release JAX_RNAseq_ExtraEmbryonic

There are two model systems involved in this dataset, ExM & PrS.

There are also both normoxia and hypoxia samples involved in this dataset.

The samples are separated into different DE groups to run DESeq2 on.
Which is to say, a DESeq2 model is fit on each group of samples, and the DE results of comparison in interest are extracted from the fitted model.

Two types of DE tests were run on this dataset:

(1) The first type is between knockout_gene_strategy and WT samples.
For this type of tests, the DE group information is listed in the first column of the file:
    2023_12_JAX_RNAseq_ExtraEmbryonic_DE_n_samples.tsv
For the (model_system, day, condition) combinations ExM_day_6_nor and PrS_day_6_hyp, only one knockout gene and one run_id is involved.
Run DESeq2 on samples under each combination separately.
For the (model_system, day, condition) combination PrS_day_6_nor, the WT samples from multiple runs appear close to each other.
To borrow strength from WT samples across different runs, run DESeq2 on all samples under this combination together, while incoporating run_id in the model.

(2) The second type is between normoxia and hypoxia conditions.
For this type of tests, the samples involved are WT samples and knockout samples specific to the comparison between normoxia and hypoxia conditions.
The model system and day information for these samples is listed in the first column of the file:
    2023_12_JAX_RNAseq_ExtraEmbryonic_DE_hyp_vs_nor_n_samples.tsv

# JAX bulk RNAseq
Workflows for JAX bulk RNAseq data analysis

## step1_check_data

Explore data and meta data

## step2_DE_testing

Bulk RNA-seq DE testing by DESeq2

There can be multiple model systems (e.g., Cortical brain (dorsal forebrain patterning), Extra-embryonic primitive syncytial cells) in one dataset. <br>
Some datasets each has both samples under normoxia and hypoxia conditions. <br>
Some datasets each has multiple timepoints. 

DESeq2 is run on the level of DE group. To decide the DE groups, PC plot of samples under each (model system, condition, timepoint) is generated. The decision is made by combining the pattern in the PC plots with the batch information of the samples, (e.g., run id, or which knockout genes the wild type samples are for). The general principle for the decision is, if wild type samples from different batches appear closer among themselves than the knockout samples from different batches do, we can set DE group to be samples from all batches together, in order to borrow information from wild type samples in different batches. But if the samples from different batches appear have big difference on PC plot, the DE group is set at the batch level. 

The major type of DE testing is between knockout samples and wild type samples. <br>
The second type of DE testing happens when there are samples both from normoxia and hypoxia conditions. In this case, DE testing is also done to compare wild type samples between normoxia and hypoxia, and also compare knockout samples between the two condtions. 

To make the results more reliable, genes with low expression are excluded from DE testing or have adjusted pvalue marked as NA. 

There are mutiple steps involved in the filtering procedure:<br>
- For each gene, compute the 75\% quantile of its expression among samples under each model system. If a gene has 75\% quantile being 0 under all model systems in the dataset, exclude the gene from further analysis.
- Before running DESeq2, based on the samples in the DE group, there are two steps excluding certain genes from DESeq2:
  - Genes each with 75\% quantile of expression being 0 are filtered out.
  - Genes each with nonzero expression in fewer than 4 samples are filtered out.
- DESeq2 internally excludes genes with mean normalized counts below a filtering threshold from multiple testing adjustment, and these genes will have adjusted pvalue being NA.
- After DESeq2, in results from a specific contrast (e.g.,one knockout gene under one knockout strategy v.s. wild type samples), based on samples directly involved in the comparison, genes each with nonzero expression in fewer than 4 samples are assigned NA as adjusted pvalue.



## step3_check_DE

Visulization of the DE results, in two aspects:
- Scatterplots showing Knockout effect on the knockout genes themselves, and the number of DE genes
- Volcano plots showing DE genes. 

## step4 and 5

Functional category enrichment analysis

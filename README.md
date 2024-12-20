# MorPhiC bulk RNAseq
Workflows for MorPhiC bulk RNAseq data analysis

## step1_check_data

Explore data and generate meta data

## step2_DE_testing

Bulk RNA-seq DE testing by DESeq2

DE testing was conducted separately for different model systems (e.g., Cortical brain or Extra-embryonic primitive syncytial cells), oxygen conditions (normoxia or hypoxia), or time points.  

Given a particular model system, oxygen condition, and time point, DESeq2 was run on the level of DE group. A DE group typically includes the samples belonging to one batch (i.e., one run id). Though if wild type samples from different batches are more simialr to each other than the knock out samples (judged by PC plots), we combine samples of these batches as one DE group, in order to borrow information across batches. 

The major type of DE testing is between knockout samples and wild type samples. The second type of DE testing is between normoxia and hypoxia conditions. 

To make the results more reliable, genes with low expression are excluded from DE testing or have adjusted pvalue marked as NA. 

There are mutiple steps involved in the filtering procedure:

- For each gene, compute the 75\% quantile of its expression among samples under each model system. If a gene has 75\% quantile being 0 under all model systems in the dataset, exclude the gene from further analysis.
  
- Before running DESeq2, based on the samples in the DE group, there are two steps excluding certain genes from DESeq2:
  
  - Genes with 75\% quantile of expression being 0.
    
  - Genes with nonzero expression in fewer than 4 samples.

- DESeq2 internally excludes genes with mean normalized counts below a filtering threshold from multiple testing adjustment, and these genes will have adjusted pvalue being NA.

- After running DESeq2, for the results from a specific contrast (e.g., KO of one gene vs. WT), if one gene has nonzero expression in fewer than 4 samples, its adjusted pvalue is assigned as NA.



## step3_check_DE

Visulization of the DE results, in two aspects:
- Scatterplots showing Knockout effect on the knockout genes themselves, and the number of DE genes
  
- Volcano plots showing DE genes. 

## step4 and 5

Functional category enrichment analysis

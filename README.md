
# Genetic characterization with Whole Genome Sequencing of Parkinson's disease patients

These scripts were developed for the genetic characterization of Parkinson's disease (PD) patients using short-read WGS. The aim is to identify single nucleotide variants (SNVs), structural variants (SVs) and copy number variation (CNVs), extract relevant information from them and perform diverse plots.

Within each script there is information about the function of each one, as well as the parameters and filters used.



## Author

- [@serbaugon](https://www.github.com/serbaugon)

## 1. First steps

First of all, it is necessary to launch the script **sarek_launch.sbatch** using FASTQ files as input. 

This script will perform the pre-processing of the samples as well as the variant calling of SNVs (*HaplotypeCaller*), SVs (*Manta*) and CNVs (*CNVkit*).

These steps are performed in the nf-core/sarek framework, a workflow for germline and somatic variant detection from WGS, WES and gene panel data. Sarek is part of the pipelines developed by the nf-core community and is written in Nextflow.

## 2. Analysis of the variants
* **SNVs analysis**

The compressed VCF files obtained from the SNVs variant calling are quality filtered using the **quality_filters.sh** script. 

To annotate VCFs with *VEP* it is necessary to fill the script **vep_script.sh** with the required plugins and directories and then use **sbatch_vep.sh** to launch the annotation script to the cluster queue for each sample.

After that, **post_VEP_filters.sh** is used to apply filters on the VCFs, including the separation of variants into single nucleotide variants (SNPs) and small insertions/deletions (INDELs).

Both SNPs and INDELs are classified according to the American College of Medical Genetics (ACMG) guidelines and criteria using *VarSome* with **varsome_classification.sh**. According to this classification, variants are classified as Pathogenic, Likely Pathogenic, Uncertain Significance (VUS), Likely Benign and Benign.

In the case that the INDELs files classified by *VarSome* have a mismatch between the number of columns and the number of elements in the header, this can be fixed with **columns_fix_post_varsome.sh**.

* **SVs analysis**
  
VCF files obtained from SVs variant calling with *Manta* are annotated with *AnnotSV* using **SVs_annotation.sh**.

* **CNVs analysis**
  
The script **CNVs_annotation.sh** is used for the annotation of segments contained in CALL.CNS files obtained from *CNVkit*.

## 3. Data exploration and visualization
* **SNVs exploration**
  
To count how many VUS, Likely Pathogenic and Pathogenic variants are in SNP and INDEL files and also plot the frequency of VUS, Likely Pathogenic and Pathogenic variants per sample, the **SNVs_classification_plot.R** script is used.

For the identification of variants classified as Likely Pathogenic or Pathogenic and their associated genes and genetic consequences, the **SNPs_LP_P_gen_CSQ&Location_count&Location_plot.R** script can be used in the case of SNPs and the **INDELs_LP_P_gen_CSQ&Location_count&Location_plot.R** script in the case of INDELs. Both scripts also plot count the genomic locations of the variants and plot the frequency of the locations per sample.

**verdict_CSQ_AlphaMissense.R** is used to identify which missense VUS SNPs are classified as Likely Pathogenic by *AlphaMissense*. Besides, it plots each of those missense VUS SNP and their corresponding *AlphaMissense* score values.

* **SVs exploration**
  
To filter the TSV files obtained from annotation with *AnnnotSV*, **known_genes_and_LP_P_SVs_plot&SVs_type_count.R** script is used. Moreover, it identifies SVs associated to previously reported PD genes and show their classification according to ACMG criteria. Then, it plots the frequency of those SVs per sample
and the frequency of their associated genes per sample.
Besides, it looks for SVs classified as Likely Pathogenic or Pathogenic according to ACMG criteria and their associated genes. Then, it plots the frequency of those SVs per sample
and the frequency of their associated genes per sample.
It also counts the different types of SVs (DEL, INS, INV and DUP) per sample before and after filtering.

**SVs_overview_pre_post_filter_plot.R** script is used to plot an overview of the SVs across the chromosomes per sample before and after applying the filters from TSV files obtained from annotation with *AnnotSV*.

* **CNVs exploration**
  
For counting the copy number (CN) in all segments in CNS files after annoting with *CNVkit* and plot the frequency of CN per sample before and after removing CN = 2, **CN_count&CN_plot.R** can be used.




## 4. Dependencies
Tools needed to run the bash scripts: *bcftools*, *Ensembl Variant Effect Predictor* (*VEP*), *AnnotSV* and those tools implemented in the nf-core/sarek pipeline.

Packages needed to run the *R* scripts: *vcfR*, *stringr*, *ggplot2*, *data.table*, *dplyr*, *tidyr*, *ParallelLogger*, *SVIV* and *gtools*.


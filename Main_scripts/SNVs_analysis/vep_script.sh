#!/bin/sh

# This script sets up all plugins and directories needed for VEP annotation from the VCF files filtered with "quality_filters.sh". 
# To launch this script to the cluster queue for all the samples it is required to use the script "sbatch_vep.sh".

# Arguments
threads=4
vcf_file=$1
file="$(basename "$vcf_file")" 
name="$(echo $file | cut -d "." -f 1)"

# Modules and Databases
DIRECTORY="/mnt/beegfs/home/serbaugon/vep_data"
PLUGIN_DIR="/mnt/beegfs/home/serbaugon/vep_data/Plugins"
FASTA="/mnt/beegfs/home/serbaugon/Fasta"
dbNSFP_DB="/mnt/beegfs/home/serbaugon/Databases/dbNSFP"
LoFtool_DB="/mnt/beegfs/home/serbaugon/Databases/LoFtool"
ExACpLI_DB="/mnt/beegfs/home/serbaugon/Databases/ExACpLI"
ALPHA_MISSENSE="/mnt/beegfs/home/serbaugon/Databases/AlphaMissense"
mkdir -p "/mnt/beegfs/home/serbaugon/Samples/Output_VEP"
OUTPUT="/mnt/beegfs/home/serbaugon/Samples/Output_VEP"

# Command
singularity exec vep109.sif \
  vep --dir $DIRECTORY \
      --cache --offline --hgvs --max_af --format vcf --vcf --force_overwrite --canonical --pick --fork $threads --dir_plugins $PLUGIN_DIR --fasta $FASTA/Homo_sapiens.GRCh38.dna.primary_assembly.fa \
      --biotype --regulatory --protein --symbol --variant_class \
      --input_file $vcf_file \
      --output_file $OUTPUT/$name.VEP.vcf \
      --plugin dbNSFP,$dbNSFP_DB/dbNSFP4.4a_grch38.gz,gnomAD_genomes_AC,gnomAD_genomes_AN,gnomAD_genomes_AF,gnomAD_genomes_nhomalt,gnomAD_genomes_NFE_AC,gnomAD_genomes_NFE_AN,gnomAD_genomes_NFE_AF,gnomAD_genomes_NFE_nhomalt,gnomAD_genomes_controls_and_biobanks_AC,gnomAD_genomes_controls_and_biobanks_AN,gnomAD_genomes_controls_and_biobanks_AF,gnomAD_genomes_controls_and_biobanks_nhomalt,gnomAD_genomes_controls_and_biobanks_NFE_AC,gnomAD_genomes_controls_and_biobanks_NFE_AN,gnomAD_genomes_controls_and_biobanks_NFE_AF,gnomAD_genomes_controls_and_biobanks_NFE_nhomalt,gnomAD_genomes_POPMAX_AC,gnomAD_genomes_POPMAX_AN,gnomAD_genomes_POPMAX_AF,gnomAD_genomes_POPMAX_nhomalt,gnomAD_exomes_AC,gnomAD_exomes_AN,gnomAD_exomes_AF,gnomAD_exomes_nhomalt,gnomAD_exomes_NFE_AC,gnomAD_exomes_NFE_AN,gnomAD_exomes_NFE_AF,gnomAD_exomes_NFE_nhomalt,gnomAD_exomes_controls_AC,gnomAD_exomes_controls_AN,gnomAD_exomes_controls_AF,gnomAD_exomes_controls_nhomalt,gnomAD_exomes_controls_NFE_AC,gnomAD_exomes_controls_NFE_AN,gnomAD_exomes_controls_NFE_AF,gnomAD_exomes_controls_NFE_nhomalt,gnomAD_exomes_POPMAX_AC,gnomAD_exomes_POPMAX_AN,gnomAD_exomes_POPMAX_AF,gnomAD_exomes_POPMAX_nhomalt,clinvar_id,clinvar_clnsig,clinvar_trait,clinvar_review,clinvar_MedGen_id,clinvar_OMIM_id,clinvar_Orphanet_id,CADD_raw,CADD_phred,REVEL_score,MetaSVM_score,MetaSVM_pred,MetaLR_score,MetaLR_pred,MetaRNN_score,MetaRNN_pred,FATHMM_score,FATHMM_pred,fathmm-MKL_coding_score,fathmm-MKL_coding_pred,fathmm-XF_coding_score,fathmm-XF_coding_pred,MutPred_score,MutPred_Top5features,DEOGEN2_score,DEOGEN2_pred,MVP_score,Eigen-raw_coding,Eigen-phred_coding,Eigen-PC-raw_coding,Eigen-PC-phred_coding,LRT_score,LRT_pred,M-CAP_score,M-CAP_pred,PrimateAI_score,PrimateAI_pred,SIFT_score,SIFT_pred,SIFT4G_score,SIFT4G_pred,Polyphen2_HDIV_score,Polyphen2_HDIV_pred,Polyphen2_HVAR_score,Polyphen2_HVAR_pred,LIST-S2_score,LIST-S2_pred,MutationAssessor_score,MutationAssessor_pred,MutationTaster_score,MutationTaster_pred,PROVEAN_score,PROVEAN_pred,GERP++_RS,phastCons100way_vertebrate,phyloP100way_vertebrate \
      --plugin LoFtool,$LoFtool_DB/LoFtool_scores.txt \
      --plugin ExACpLI,$ExACpLI_DB/ExACpLI_values.txt \
      --plugin AlphaMissense,file=$ALPHA_MISSENSE/AlphaMissense_hg38.tsv.gz


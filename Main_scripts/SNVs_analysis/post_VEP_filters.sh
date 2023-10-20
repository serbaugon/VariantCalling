#!/bin/sh

# DIRECTORIES
# Directory of bcftools and the initial sample files
BCFTOOLS_DIR="/mnt/beegfs/home/mimarbor/singularity_cache/depot.galaxyproject.org-singularity-bcftools-1.16--hfe4b78e_1.img"
SAMPLES_DIR="/mnt/beegfs/home/serbaugon/Samples/Output_VEP"

# Creation of a new directory to store the output files after applying the filters
mkdir -p /mnt/beegfs/home/serbaugon/Samples/Post_VEP
FILTERS_DIR="/mnt/beegfs/home/serbaugon/Samples/Post_VEP"


# FILTERING COMMANDS
# Remove multi-allelic variants
mkdir -p $FILTERS_DIR/MaxAlleles2
MAX_ALLELES_DIR="$FILTERS_DIR/MaxAlleles2"

for input in $SAMPLES_DIR/*.vcf; do
  file="$(basename "$input")" 
  name="$(echo $file | cut -d "." -f 1)"
  singularity run $BCFTOOLS_DIR bcftools view --max-alleles 2 $input -o $MAX_ALLELES_DIR/$name.MaxAlleles2.vcf
  echo "Filtered file: $file"
done


# Split SNPs and indels
# For SNPs:
mkdir -p $FILTERS_DIR/SNPs
SNPs_DIR="$FILTERS_DIR/SNPs"

for input in $MAX_ALLELES_DIR/*.vcf; do
  file="$(basename "$input")" 
  name="$(echo $file | cut -d "." -f 1)"
  singularity run $BCFTOOLS_DIR bcftools view -v snps $input -o $SNPs_DIR/${name}_SNPs.vcf
  echo "Filtered file: $file"
done 

# For indels:
mkdir -p $FILTERS_DIR/Indels
INDELS_DIR="$FILTERS_DIR/Indels"

for input in $MAX_ALLELES_DIR/*.vcf; do
  file="$(basename "$input")" 
  name="$(echo $file | cut -d "." -f 1)"
  singularity run $BCFTOOLS_DIR bcftools view -v indels $input -o $INDELS_DIR/${name}_Indels.vcf
  echo "Filtered file: $file"
done 


# Filter SNPs and indels files by maximum allele frequency
# For SNPs:
mkdir -p $SNPs_DIR/MAX_AF
MAX_AF_SNPs_DIR="$SNPs_DIR/MAX_AF"

for input in $SNPs_DIR/*.vcf; do
  file="$(basename "$input")" 
  name="$(echo $file | cut -d "." -f 1)"
  singularity exec vep109.sif filter_vep -i $input -o $MAX_AF_SNPs_DIR/$name.MaxAF.vcf --filter "MAX_AF < 0.05 or not MAX_AF" --force_overwrite
  echo "Filtered file: $file"
done 

# For indels:
mkdir -p $INDELS_DIR/MAX_AF
MAX_AF_INDELS_DIR="$INDELS_DIR/MAX_AF"

for input in $INDELS_DIR/*.vcf; do
  file="$(basename "$input")" 
  name="$(echo $file | cut -d "." -f 1)"
  singularity exec vep109.sif filter_vep -i $input -o $MAX_AF_INDELS_DIR/$name.MaxAF.vcf --filter "MAX_AF < 0.05 or not MAX_AF" --force_overwrite
  echo "Filtered file: $file"
done 


# Remove introns from SNPs and indels files
# For SNPs:
mkdir -p $SNPs_DIR/NOT_INTRONS
NOT_INTRONS_SNPs_DIR="$SNPs_DIR/NOT_INTRONS"

for input in $MAX_AF_SNPs_DIR/*.vcf; do
  file="$(basename "$input")" 
  name="$(echo $file | cut -d "." -f 1)"
  singularity exec vep109.sif filter_vep -i $input -o $NOT_INTRONS_SNPs_DIR/$name.NotIntrons.vcf --filter "not Consequence match intron" --force_overwrite
  echo "Filtered file: $file"
done 

# For indels:
mkdir -p $INDELS_DIR/NOT_INTRONS
NOT_INTRONS_INDELS_DIR="$INDELS_DIR/NOT_INTRONS"

for input in $MAX_AF_INDELS_DIR/*.vcf; do
  file="$(basename "$input")" 
  name="$(echo $file | cut -d "." -f 1)"
  singularity exec vep109.sif filter_vep -i $input -o $NOT_INTRONS_INDELS_DIR/$name.NotIntrons.vcf --filter "not Consequence match intron" --force_overwrite
  echo "Filtered file: $file"
done 


# Keep variants that code for proteins ONLY in SNPs files
# For SNPs:
mkdir -p $SNPs_DIR/PROTEIN_CODING
PROTEIN_CODING_SNPs_DIR="$SNPs_DIR/PROTEIN_CODING"

for input in $NOT_INTRONS_SNPs_DIR/*.vcf; do
  file="$(basename "$input")" 
  name="$(echo $file | cut -d "." -f 1)"
  singularity exec vep109.sif filter_vep -i $input -o $PROTEIN_CODING_SNPs_DIR/$name.ProteinCoding.vcf --filter "(BIOTYPE is protein_coding) or (not BIOTYPE)" --force_overwrite
  echo "Filtered file: $file"
done 

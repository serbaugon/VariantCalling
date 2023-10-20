#!/bin/sh

# This script aims to filter the VCF files obtained from Manta that contain the SVs.
# The filters include the PASS filter and the removal of SVs shorter than 50 bp and larger than 50 kb

# DIRECTORIES
# Directory of bcftools and SVs files
BCFTOOLS_DIR="/mnt/beegfs/home/mimarbor/singularity_cache/depot.galaxyproject.org-singularity-bcftools-1.16--hfe4b78e_1.img"
SAMPLES_DIR="/mnt/beegfs/home/serbaugon/Manta"
# Creation of a new directory to store the output files after applying the filters
mkdir -p $SAMPLES_DIR/Output_AnnotSV_FILTER
FILTERS_DIR="$SAMPLES_DIR/Output_AnnotSV_FILTER"

# FILTERING COMMANDS
# PASS filter
mkdir -p $FILTERS_DIR/PASS
PASS_DIR="$FILTERS_DIR/PASS"

for input in $SAMPLES_DIR/*.vcf; do
  file="$(basename "$input")" 
  name="$(echo $file | cut -d "." -f 1)"
  singularity run $BCFTOOLS_DIR bcftools view -f PASS $input -o $PASS_DIR/$name.PASS.vcf.gz
  echo "PASS filter applied to file: $file"
done


# Length filter
mkdir -p $FILTERS_DIR/Length
LENGTH_DIR="$FILTERS_DIR/Length"

for input in $PASS_DIR/*.vcf.gz; do
  file="$(basename "$input")" 
  name="$(echo $file | cut -d "." -f 1)"
  singularity run $BCFTOOLS_DIR bcftools view -i "(SVLEN>50 || SVLEN<-50) && (SVLEN<50000 && SVLEN>-50000)" $input -o $LENGTH_DIR/$name.Length.vcf
  echo "SVs length filter applied to file: $file"
done



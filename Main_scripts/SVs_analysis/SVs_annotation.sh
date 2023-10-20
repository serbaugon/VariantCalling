#!/bin/sh

# This script is aimed for the annotation of SVs using AnnotSV after filters are applied using "SVs_filters.sh"

# DIRECTORIES
DIRECTORY="/mnt/beegfs/home/serbaugon/Manta/Output_AnnotSV_FILTER/Length"
mkdir -p /mnt/beegfs/home/serbaugon/Manta/Output_AnnotSV_FILTER/AnnotSV
OUTPUT="/mnt/beegfs/home/serbaugon/Manta/Output_AnnotSV_FILTER/AnnotSV"
export ANNOTSV=/mnt/beegfs/home/serbaugon/AnnotSV

# SVs annotation
for input in $DIRECTORY/*.vcf; do
  file="$(basename "$input")" 
  name="$(echo $file | cut -d "." -f 1)"
  $ANNOTSV/bin/AnnotSV -SVinputFile $input -outputFile $OUTPUT/$name.annotated.tsv -genomeBuild GRCh38
  echo "Annotated file: $file"
done

rm $OUTPUT/*header.tsv



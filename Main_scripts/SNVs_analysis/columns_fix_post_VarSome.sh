#!/bin/bash

# DIRECTORIES
DIRECTORY="/mnt/beegfs/home/serbaugon/Samples/Post_VarSome/Indels"
mkdir -p /mnt/beegfs/home/serbaugon/Samples/Post_VarSome/Indels/Fixed
OUTPUT_DIR="/mnt/beegfs/home/serbaugon/Samples/Post_VarSome/Indels/Fixed"

# Fix columns in indels files after VarSome Classification
for input in "$DIRECTORY"/*.vcf; do
  file="$(basename "$input")" 
  name="$(echo $file | cut -d "." -f 1)"
  sed 's/\t\t/\t.\t/g' "$input" > "$OUTPUT_DIR/${name}_fixed.vcf"
  echo "Fixed file: $file"
done

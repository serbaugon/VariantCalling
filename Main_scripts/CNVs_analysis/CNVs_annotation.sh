#!/bin/sh

# This script is aimed for the annotation of segments contained in CALL.CNS files obtained from CNVkit.

# DIRECTORIES
DIRECTORY="/mnt/beegfs/home/serbaugon/CNVkit"
mkdir -p $DIRECTORY/Output
OUTPUT="$DIRECTORY/Output"

# CNVs annotation
for input in $DIRECTORY/**/*.call.cns; do
  file="$(basename "$input")" 
  name="$(echo $file | cut -d "." -f 1)"
  python3 $DIRECTORY/cnv_annotate.py $DIRECTORY/refFlat.txt $input -o $OUTPUT/$name.annotated.cns
  echo "Annotated file: $file"
done






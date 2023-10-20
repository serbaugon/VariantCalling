#!/bin/sh

# This script is used to lauch the script "vep_script.sh" for each sample to the cluster queue

# Directories of the input samples, the logfiles and the annotation script with VEP
SAMPLES="/mnt/beegfs/home/serbaugon/Samples/Quality_Filters/PASS"
mkdir -p "/mnt/beegfs/home/serbaugon/Samples/Output_VEP"
OUTPUT="/mnt/beegfs/home/serbaugon/Samples/Output_VEP"
mkdir -p $OUTPUT/Logfiles
LOGFILES="$OUTPUT/Logfiles"
VEP_SCRIPT="/mnt/beegfs/home/serbaugon"

# Each sample is sent to the cluster queue so that the VEP script is executed on each one
for input in $SAMPLES/*.vcf.gz;do
  file="$(basename "$input")" 
  name="$(echo $file | cut -d "." -f 1)"
  sbatch -o $LOGFILES/$name.out -e $LOGFILES/$name.err $VEP_SCRIPT/vep_script.sh "$input" 
  echo "Uploaded file: $file"
done


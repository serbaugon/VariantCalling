#!/bin/bash

# This is script is used for pre-processing of FASTQ files and variant calling of SNVs, SVs and CNVs

#SBATCH -o log_launcher.out
#SBATCH -e log_launcher.err
#SBATCH -J sarekLaunch
#SBATCH -t 99:00:00

export NXF_OPTS='-Xms1g -Xmx4g'
export NXF_EXECUTOR=slurm
export NXF_SINGULARITY_CACHEDIR=/mnt/beegfs/home/mimarbor/singularity_cache

export TMPDIR=/scratch/mimarbor/singularity/tmp
export SINGULARITY_TMPDIR=/scratch/mimarbor/singularity/tmp

ulimit -u 4126507
ulimit -n 131072
ulimit -m 8388608


nextflow -Dnxf.pool.type=sync run $(realpath ~/nf-core-sarek-3.1.2/workflow) -process.errorStrategy='ignore' -process.scratch=true -process.stageInMode='copy' \
-process.maxForks=80 -process.time='2h' -process.cache='lenient' -profile singularity --outdir results_WGS_manta_cnvkit_3 --input samplesheet.csv --igenomes_base /mnt/beegfs/genomes/igenomes \
--tools cnvkit,manta --genome "GATK.GRCh38" --max_cpus 10 --max_memory '80.GB' -resume


 
# Second run
#nextflow -Dnxf.pool.type=sync run $(realpath ~/nf-core-sarek-3.1.2/workflow) -process.errorStrategy='ignore' -process.scratch=true -process.stageInMode='symlink' \
#-process.maxForks=80 -process.time='2h' -process.cache='lenient' -profile singularity --outdir results_WGS_5 --input samplesheet_5.csv --igenomes_base /mnt/beegfs/genomes/igenomes \
#--tools haplotypecaller,strelka --genome "GATK.GRCh38" --max_cpus 10 --max_memory '80.GB' -resume

# First run
# nextflow -Dnxf.pool.type=sync run $(realpath ~/nf-core-sarek-3.1.2/workflow) -process.errorStrategy='ignore' -process.scratch=false -process.stageInMode='copy' -process.maxForks=80 -process.time='2h' \
# -process.cache='lenient' -profile singularity --outdir results_WGS --input samplesheet.csv --igenomes_base /mnt/beegfs/genomes/igenomes --tools deepvariant,haplotypecaller,strelka,cnvkit --genome "GATK.GRCh38" --max_cpus 10 --max_memory '80.GB' -resume

# Second run resume
#nextflow -Dnxf.pool.type=sync run $(realpath ~/nf-core-sarek-3.1.2/workflow) -process.errorStrategy='ignore' -process.scratch=false -process.stageInMode='copy' -process.maxForks=80 -process.time='2h' \
#-process.cache='lenient' -profile singularity --outdir results_WGS_2 --input samplesheet_2.csv --igenomes_base /mnt/beegfs/genomes/igenomes --tools deepvariant,haplotypecaller,strelka,cnvkit --genome "GATK.GRCh38" --max_cpus 10 --max_memory '80.GB' -resume

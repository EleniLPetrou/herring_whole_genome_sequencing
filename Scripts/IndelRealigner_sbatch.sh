#!/bin/bash
#SBATCH --job-name=elp_IndelRealigner
#SBATCH --account=merlab
#SBATCH --partition=compute-hugemem
#SBATCH --nodes=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=15-12:00:00
## Memory per node
#SBATCH --mem=300G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=elpetrou@uw.edu

##### ENVIRONMENT SETUP ####################################################
## Specify the directories and file names containing your data (edit lines 16-20 as needed)
DATADIR=/gscratch/scrubbed/elpetrou/bam #path to the bam files that you want to analyze with GATK3
GENOMEDIR=/gscratch/merlab/genomes/atlantic_herring #directory containing the genome
REFERENCE=GCF_900700415.1_Ch_v2.0.2_genomic.fna # Name of genome
BAMLIST=bam_list_dedup_overlapclipped.list # A list of merged, deduplicated, and overlap-clipped bam files. This file has to have a suffix of ".list"

## Specify some information about the conda environments and names of intermediate files. You probably do NOT need to edit this information.
GATK3=/gscratch/merlab/software/miniconda3/envs/gatk3_env/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar # the path to the gatk3 jarfile
MYCONDA=/gscratch/merlab/software/miniconda3/etc/profile.d/conda.sh # path to conda installation on our Klone node. Do NOT change this.
GATK3_ENV=gatk3_env #name of the conda environment running gatk3


## Source command will allow us to execute commands from a file in the current shell (conda)
module purge
source $MYCONDA
conda activate $GATK3_ENV


########## Code for Indel Realignment ###################

## Move into the data directory so GATK3 writes output files here
cd $DATADIR 

## Run GATK3 IndelRealigner

java -jar $GATK3 \
-T IndelRealigner \
-R $GENOMEDIR'/'$REFERENCE \
-I $DATADIR'/'$BAMLIST \
-targetIntervals $DATADIR'/'all_samples_for_indel_realigner.intervals \
--consensusDeterminationModel USE_READS  \
--nWayOut _realigned.bam

## Leave gatk3 conda environment
conda deactivate

#!/bin/bash
#SBATCH --job-name=elp_dedup_clip
#SBATCH --account=merlab
#SBATCH --partition=compute-hugemem
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=3-12:00:00
## Memory per node
#SBATCH --mem=100G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=elpetrou@uw.edu

##### ENVIRONMENT SETUP ####################################################
## Specify the directory containing data
DATADIR=/mmfs1/gscratch/scrubbed/elpetrou/bam #directory containing bam files
SUFFIX1=_minq20_sorted.bam # suffix to sorted and quality-filtered bam files produced in previous step of pipeline.
MYCONDA=/gscratch/merlab/software/miniconda3/etc/profile.d/conda.sh # path to conda installation on our Klone node. Do NOT change this.
MYENV=picard_env #name of the conda environment containing picard software. 

## Activate the conda environment:
## start with clean slate
module purge

## This is the filepath to our conda installation on Klone. Source command will allow us to execute commands from a file in the current shell
source $MYCONDA

## activate the conda environment
conda activate $MYENV

###### CODE FOR ANALYSIS ####################################################
## Move into the working directory
cd $DATADIR

## Run picard and bamutils (remove pcr duplicates and clip overlapping reads). These analyses take ~4 min to run per sample. Please note that picard can't handle newline breaks in the code (\) - so that is why all the commands are hideously written on one line.

for MYSAMPLEFILE in *$SUFFIX1
do
    echo $MYSAMPLEFILE
    MYBASE=`basename --suffix=$SUFFIX1 $MYSAMPLEFILE`
    echo $MYBASE
    picard MarkDuplicates INPUT=$MYBASE'_minq20_sorted.bam' OUTPUT=$MYBASE'_minq20_sorted_dedup.bam' METRICS_FILE=$MYBASE'_minq20_sorted_dupstat.txt' VALIDATION_STRINGENCY=SILENT REMOVE_DUPLICATES=true
    bam clipOverlap --in $MYBASE'_minq20_sorted_dedup.bam' --out $MYBASE'_minq20_sorted_dedup_overlapclipped.bam' --stats
done 

## Leave the picard conda environment
conda deactivate

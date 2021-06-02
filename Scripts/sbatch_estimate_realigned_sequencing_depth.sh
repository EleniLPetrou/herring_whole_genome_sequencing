#!/bin/bash
#SBATCH --job-name=elp_R_seq_depth
#SBATCH --account=merlab
#SBATCH --partition=compute-hugemem
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=4-12:00:00
## Memory per node
#SBATCH --mem=50G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=elpetrou@uw.edu


##### ENVIRONMENT SETUP ##########
## Specify the directory containing data
DATADIR=/mmfs1/gscratch/scrubbed/elpetrou/bam #directory with depth files created by samtools
MYSCRIPT=/mmfs1/home/elpetrou/scripts/plot_realigned_sequencing_depth.R #path to R script
SUFFIX1=.bam.depth.gz #suffix of files that you would like to analyze

## start with clean slate
module purge

###################################################################################################################
## Move into the working directory and run script
cd $DATADIR


## Run R script
for MYSAMPLEFILE in *$SUFFIX1
do
    Rscript --vanilla $MYSCRIPT $MYSAMPLEFILE
done

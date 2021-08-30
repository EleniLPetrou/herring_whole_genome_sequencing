#!/bin/bash
#SBATCH --job-name=subsample_LD_per_chrom
#SBATCH --account=merlab
#SBATCH --partition=compute-hugemem
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=1-12:00:00
## Memory per node
#SBATCH --mem=100G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=elpetrou@uw.edu

###########################################################
## Specify data directory and input file name
DATADIR=/gscratch/scrubbed/elpetrou/ngsld
MYFILE=all_samples_maf0.05_miss0.3.nuclear.ld

## Specify list of chromosome names
LIST_CHROM=(
NC_045152.1
NC_045153.1
NC_045154.1
NC_045155.1
NC_045156.1
NC_045157.1
NC_045158.1
NC_045159.1
NC_045160.1
NC_045161.1
NC_045162.1
NC_045163.1
NC_045164.1
NC_045165.1
NC_045166.1
NC_045167.1
NC_045168.1
NC_045169.1
NC_045170.1
NC_045171.1
NC_045172.1
NC_045173.1
NC_045174.1
NC_045175.1
NC_045176.1
NC_045177.1
)

## Save the LD output for each chromosome seprately in a text file

cd $DATADIR

for CHROM in ${LIST_CHROM[@]}
do
    echo $CHROM
    grep $CHROM* $MYFILE > $MYFILE.$CHROM.txt
done

#!/bin/bash
#SBATCH --job-name=LD_by_blocks_sbatch
#SBATCH --account=merlab
#SBATCH --partition=compute-hugemem
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=4-12:00:00
## Memory per node
#SBATCH --mem=100G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=elpetrou@uw.edu


##### ENVIRONMENT SETUP ####################################################
## Specify the directories and file names containing your data
DATADIR=/gscratch/scrubbed/elpetrou/ngsld
SUFFIX1=.1.txt #files ending in this suffix contain ld results for each chromosome
MYSCRIPT=/mmfs1/home/elpetrou/scripts/ld_by_blocks_optimized_gzinput.py #path to python script
BLOCKSIZE=1000 # size of blocks in genome (in Kb) over which R2 values should be summarized
METHOD=quant
##################################################################
## start with clean slate
module purge
# Make python script executable
chmod +x $MYSCRIPT

################################################################
## Prepare the input files and run python script on each one

# Move into working directory
cd $DATADIR

# Run the python script
for MYFILE in *$SUFFIX1
do
	MYBASE=`basename --suffix=$SUFFIX1 $MYFILE`
	gzip $MYBASE'.1.txt'
	python3 $MYSCRIPT $MYBASE'.1.txt.gz' $BLOCKSIZE $MYBASE'.'$BLOCKSIZE'.'$METHOD'.txt'
done


# Estimate read depth bam files after indel realignment

Using samtools, I estimated the read depth of each bam file after indel realignment using the script below. As far as I could tell, samtools depth command does not support multithreading, so it took about ~2 min to run for each sample. 

``` bash
#!/bin/bash
#SBATCH --job-name=elp_samtools_depth
#SBATCH --account=merlab
#SBATCH --partition=compute-hugemem
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=3-12:00:00
## Memory per node
#SBATCH --mem=50G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=elpetrou@uw.edu


##### ENVIRONMENT SETUP ##########
## Specify the directory containing data
DATADIR=/mmfs1/gscratch/scrubbed/elpetrou/bam #directory with sam files
SUFFIX1=_realigned.bam #file suffix
MYCONDA=/gscratch/merlab/software/miniconda3/etc/profile.d/conda.sh # path to conda installation on our Klone node. Do NOT change this.
MYENV=samtools_env #name of the conda environment containing samtools software. 

## Activate the conda environment:
## start with clean slate
module purge

## This is the filepath to our conda installation on Klone. Source command will allow us to execute commands from a file in the current shell
source $MYCONDA

## activate the conda environment
conda activate $MYENV


###################################################################################################################
## Move into the working directory and run script
cd $DATADIR

## Run samtools commands. This takes about 5 min per sample (so like 2 days total for whole data set?)
for MYSAMPLEFILE in *$SUFFIX1
do
    echo $MYSAMPLEFILE
    samtools depth -aa $MYSAMPLEFILE | cut -f 3 | gzip > $MYSAMPLEFILE'.depth.gz'
done

## Flag explanations for samtools depth:
## -aa: output absolutely all positions, including unused ref. sequences

## deactivate the conda environment
conda deactivate

```

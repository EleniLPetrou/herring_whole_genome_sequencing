#Create a conda environment for multiqc
conda create -n multiqc_env

# To activate or enter the environments you just created simply type:
conda activate multiqc_env

# Once in the environment, install the versions of software that you want using conda:
conda install -c bioconda -c conda-forge multiqc

##################################
# To use the environment:

srun -p compute-hugemem -A merlab --nodes=1 --ntasks-per-node=1 --time=02:00:00 --mem=20G --pty /bin/bash

MYCONDA=/gscratch/merlab/software/miniconda3/etc/profile.d/conda.sh # path to conda installation on our Klone node. Do NOT change this.
MYENV=multiqc_env #name of the conda environment containing samtools software. 

## Activate the conda environment:
## start with clean slate
module purge

## This is the filepath to our conda installation on Klone. Source command will allow us to execute commands from a file in the current shell
source $MYCONDA

## activate the conda environment
conda activate $MYENV

# test it out 
DATADIR=/mmfs1/gscratch/scrubbed/elpetrou/bam #directory with depth files created by samtools

cd $DATADIR

multiqc .




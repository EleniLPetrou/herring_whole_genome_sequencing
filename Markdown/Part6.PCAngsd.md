# PCA using angsd output files

## First, I downloaded and installed pcangsd version 1.02 software on Klone:

``` bash
# Directions from: http://www.popgen.dk/software/index.php/PCAngsdv2

# Go to the directory where you will install your software
cd /gscratch/merlab/software/miniconda3/envs

# create a conda environment for pcangsd and activate it
conda create -n pcangsd_env
conda activate pcangsd_env

# install cython v0.29.23 (needed for pcangsd installation)
conda install -c anaconda cython

# install numpy v1.20.2 (needed for pcangsd installation)
conda install -c anaconda numpy

#install pcangsd Version 1.02 (done on 20210617)
#Download the source code:
git clone https://github.com/Rosemeis/pcangsd.git

#Configure, Compile and Install:
cd pcangsd/
python setup.py build_ext --inplace

#Install dependencies: The required set of Python packages are easily installed using the pip command and the requirements.txt file included in the pcangsd folder.

pip install --user -r requirements.txt

# Path to PCANGSD: /gscratch/merlab/software/miniconda3/envs/pcangsd

# Get help
python pcangsd.py -h
# woohoo! installation worked!!

```
NB: in the first trial runs of pcangsd, I tried to input beagle files with 11 million and 5 million SNPS, respectively. This caused pcangsd to exit prematurely with this warning: exit code 139 (segmentation fault, core dumped). After googling this error, I came to the hypothesis that the program was running out of memory (apparently 700 Gb was not enough). To test this hypothesis, I created a smaller .beagle.gz file by retaining only the first 6 million lines of the original file ``` head -n 600000 all_samples_maf0.05.beagle > test.beagle``` and used this in pcangsd. This analysis ran to completion, so the problem was indeed a memory issue (phew!). I will filter the genotype liklihoods more stringently (maf >0.05, max missing data per SNP = 30%) to get approximately 600,000 SNPs and then I will run pcangsd again. 


## Next, I ran PCAngsd using some genotype likelihood files that I created in angsd

``` bash

#!/bin/bash
#SBATCH --job-name=elp_angsd_variants
#SBATCH --account=merlab
#SBATCH --partition=compute-hugemem
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=8-12:00:00
## Memory per node
#SBATCH --mem=400G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=elpetrou@uw.edu


#####################################################################
##### ENVIRONMENT SETUP ##########

## software information
MYCONDA=/gscratch/merlab/software/miniconda3/etc/profile.d/conda.sh # path to conda installation on our Klone node. Do NOT change this.
MYENV=pcangsd_env #name of the conda environment containing samtools software. 
PCANGSD=/gscratch/merlab/software/miniconda3/envs/pcangsd/pcangsd.py #path to pcangsd software on Klone

## data information
DATADIR=/gscratch/scrubbed/elpetrou/angsd #path to input files (beagle file)
OUTDIR=/gscratch/scrubbed/elpetrou/results #path to output files
MYINFILE=all_samples_maf0.01.beagle.gz #name of beagle file
OUTPREFIX=pca_all_samples_maf0.01 #prefix for output files

##################################################################
## Activate the conda environment:
## start with clean slate
module purge

## This is the filepath to our conda installation on Klone. Source command will allow us to execute commands from a file in the current shell
source $MYCONDA

## activate the conda environment
conda activate $MYENV

## run pcangsd
python $PCANGSD -beagle $DATADIR'/'$MYINFILE -o $OUTDIR'/'$OUTPREFIX -threads ${SLURM_JOB_CPUS_PER_NODE}

```

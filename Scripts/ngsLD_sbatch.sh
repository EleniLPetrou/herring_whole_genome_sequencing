#!/bin/bash
#SBATCH --job-name=elp_ngsLD
#SBATCH --account=merlab
#SBATCH --partition=compute-hugemem
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=16
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=10-12:00:00
## Memory per node
#SBATCH --mem=400G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=elpetrou@uw.edu

##### ENVIRONMENT SETUP ##########
MYCONDA=/gscratch/merlab/software/miniconda3/etc/profile.d/conda.sh # path to conda installation on our Klone node. Do NOT change this.
MYENV=ngsLD_env #name of the conda environment containing samtools software. 

## Specify file names and data directories
DATADIR=/gscratch/scrubbed/elpetrou/angsd #path to input files from angsd
OUTDIR=/gscratch/scrubbed/elpetrou/ngsld #path to output files from ngsld
MYFILE=all_samples_maf0.05_miss0.3.nuclear # name of input beagle file created by angsd without the .beagle.gz extension

## Specify the variables
N_IND=550 # number of individuals in beagle file
N_SITES=607980 #number of variant sites in beagle file
N_THREADS=16 #make sure this matches the value in line 6 (--ntasks-per-node)

## Specify the path to required program (ngsLD) as variables
NGSLD=/gscratch/merlab/software/miniconda3/envs/ngsLD_env/ngsLD/

##################################################################
## Activate the conda environment:
## start with clean slate
module purge

## This is the filepath to our conda installation on Klone. Source command will allow us to execute commands from a file in the current shell
source $MYCONDA

## activate the conda environment
conda activate $MYENV

## Specify path to libgsl.so.25 file for ngsLD (do not change this!!)
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/gscratch/merlab/software/miniconda3/envs/ngsLD_env/lib 
export LD_LIBRARY_PATH

################################################################
## Prepare the input files - ngsLD requires two input files:

##1)--geno FILE : a beagle formatted genotype likelihood file generated from ANGSD (-doGlf 2) can be inputted into ngsLD
## after the header row and the first three columns (i.e. positions, major allele, minor allele) are removed.

## Prepare the geno file

#zcat $DATADIR/$MYFILE.beagle.gz | cut -f 4- | sed '1d' | gzip  > $OUTDIR/$MYFILE.formatted.beagle.gz

##2)--pos FILE: input file with site coordinates (one per line), where the 1st column stands for the chromosome/contig and 
## the 2nd for the position (bp). One convenient way to generate this is by selecting the first two columns of the mafs file outputted by ANGSD, 
## with the header removed. 

## Prepare a pos file - viera says to take the first two columns of mafs file and remove header: https://github.com/fgvieira/ngsLD/issues/4. That should do it.

#zcat $DATADIR/$MYFILE.mafs.gz | cut -f 1,2 | sed '1d' | gzip > $OUTDIR/$MYFILE.formatted.pos.gz


################################################################
## Run ngsLD

$NGSLD/ngsLD \
--geno $OUTDIR/$MYFILE.formatted.beagle.gz \
--pos $OUTDIR/$MYFILE.formatted.pos.gz \
--probs \
--n_ind $N_IND \
--n_sites $N_SITES \
--max_kb_dist 0 \
--n_threads $N_THREADS \
--out $OUTDIR/$MYFILE.ld

#Important ngsLD parameters:

#--probs: specification of whether the input is genotype probabilities (likelihoods or posteriors)?
#--n_ind INT: sample size (number of individuals).
#--n_sites INT: total number of sites.
#--max_kb_dist DOUBLE: maximum distance between SNPs (in Kb) to calculate LD. Set to 0(zero) to disable filter. [100]
#--max_snp_dist INT: maximum distance between SNPs (in number of SNPs) to calculate LD. Set to 0 (zero) to disable filter. [0]
#--n_threads INT: number of threads to use. [1]
#--out FILE: output file name. [stdout]



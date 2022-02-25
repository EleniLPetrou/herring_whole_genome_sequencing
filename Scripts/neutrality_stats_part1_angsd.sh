#!/bin/bash
#SBATCH --job-name=herring_thetas
#SBATCH --account=merlab
#SBATCH --partition=compute-hugemem
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=32
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=10-6:00:00
## Memory per node
#SBATCH --mem=600G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=elpetrou@uw.edu

## The purpose of this scripts is to estimate the site frequency spectrum and neutrality statistics (like Tajima's D) for different populations in angsd.

##### ENVIRONMENT SETUP ##########
MYCONDA=/gscratch/merlab/software/miniconda3/etc/profile.d/conda.sh # path to conda installation on our Klone node. Do NOT change this.
MYENV=angsd_env_0.921 #name of the conda environment containing samtools software. 
REALSFS=/gscratch/merlab/software/miniconda3/envs/angsd_env_0.921/bin/realSFS #full path to realSFS program in angsd

## Specify directories with data
REFGENOME=/gscratch/merlab/genomes/atlantic_herring/GCF_900700415.1_Ch_v2.0.2_genomic.fna #path to fasta genome
BAMDIR=/gscratch/scrubbed/elpetrou/bam #path to directory containing bam files
SFSDIR=/gscratch/scrubbed/elpetrou/sfs #directory for output files

## Specify the base name of each of the populations
LIST_POP=(
CHPT16
PORT14
SQUA14
ELBY15
QLBY19
SMBY15
KRES19
OLGA19
CRAIG18
CRAW20
SITKA17
BERN16
) 

##################################################################
## Activate the conda environment:
## start with clean slate
module purge

## This is the filepath to our conda installation on Klone. Source command will allow us to execute commands from a file in the current shell
source $MYCONDA

## activate the conda environment
conda activate $MYENV

#############################################################################################################
## Step 1 - find a global estimate of the Site Frequency Spectrum without filtering for minor allele frequency

## Prep work: Create a text file containing the names of the bam files for each population
# try to make an SFS file for one population

## Make a list of bams for each population
cd $BAMDIR

for POP in ${LIST_POP[@]}
do
	ls $POP*'.bam' > $POP'_bams.txt'
done

# Note - I removed migrant indivs from SMBY15_bams.txt by hand (indivs 15,16,35,43,23,27,30,33,47)

# First, estimate the site allele frequency likelihood for every bam file
## Specify filtering values for angsd
FILTERS="-minMapQ 30 -minQ 20 -minInd 20 -uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1"

## Specify output options for angsd
OPTIONS="-GL 1 -doSaf 1 -doMajorMinor 1"

for POP in ${LIST_POP[@]}
do
	angsd -b $BAMDIR/$POP'_bams.txt' -ref $REFGENOME -anc $REFGENOME -out $SFSDIR/$POP \
	$FILTERS \
	$OPTIONS \
	-nThreads ${SLURM_JOB_CPUS_PER_NODE}
done

## The output files end in .saf.gz, .saf.idx, and .saf.pos.gz


# Next, Obtain the maximum likelihood estimate of the SFS for each population using the realSFS program found in the misc subfolder.
# Move into the folder with the ".saf.idx" files
cd $SFSDIR

for POP in ${LIST_POP[@]}
do
	$REALSFS $POP'.saf.idx' -P ${SLURM_JOB_CPUS_PER_NODE} > $POP'.sfs'
done

#############################################################################################################
## Step 2: Calculate the thetas for each site

for POP in ${LIST_POP[@]}
do
	$REALSFS saf2theta $POP'.saf.idx' -sfs $POP'.sfs' -outname $POP
done

# The output from the above command are two files: out.thetas.gz and out.thetas.idx

#############################################################################################################
## Step 3: Estimate Tajima's D and other statistics using a sliding window analysis
# Calculate Tajimas D for every site
#for POP in ${LIST_POP[@]}
#do
#	thetaStat do_stat $POP'.thetas.idx'
#done

# The output from the above command is one file: out.thetas.idx.pestPG

# Do a sliding window analysis for Tajima's D

cd $SFSDIR

for POP in ${LIST_POP[@]}
do
	thetaStat do_stat $POP'.thetas.idx' -win 50000 -step 10000  -outnames $POP'.theta.thetasWindow'
done


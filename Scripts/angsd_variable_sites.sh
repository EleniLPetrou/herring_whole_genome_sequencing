#!/bin/bash
#SBATCH --job-name=elp_angsd_variants
#SBATCH --account=merlab
#SBATCH --partition=compute-hugemem
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=10
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=6-12:00:00
## Memory per node
#SBATCH --mem=200G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=elpetrou@uw.edu


##### ENVIRONMENT SETUP ##########
MYCONDA=/gscratch/merlab/software/miniconda3/etc/profile.d/conda.sh # path to conda installation on our Klone node. Do NOT change this.
MYENV=angsd_env #name of the conda environment containing samtools software. 

## Specify directories with data
DATADIR=/mmfs1/gscratch/scrubbed/elpetrou/bam #directory with realigned bam files
REFGENOME=/gscratch/merlab/genomes/atlantic_herring/GCF_900700415.1_Ch_v2.0.2_genomic.fna #path to fasta genome
MYBAMLIST=bam.filelist # name of text file with bam files
OUTNAME=all_samples_maf0.05_miss0.3 #output file name

## Specify filtering values for angsd
QUAL=20 #quality threshold for minMapQ and minQ filtering options
MAXDEPTH=3000 # maximum total depth (across all individuals. non-zero mean depth +2sd = 5. So if all individuals are sequenced 5x at a site, the global max depth would be 2750)
MINDEPTH=10 #minimum total depth (across all individuals)
MININD=384 #minimum number of individuals for a genomic site to be included in output (half of the individuals, in my case)
MINMAF=0.05 #retain only SNPs with this global minor allele frequency
PVAL=2e-6 #p-value cutoff for calling polymorphic loci


##################################################################
## Activate the conda environment:
## start with clean slate
module purge

## This is the filepath to our conda installation on Klone. Source command will allow us to execute commands from a file in the current shell
source $MYCONDA

## activate the conda environment
conda activate $MYENV

## Move into the directory containing the realigned bam files and save their names to a text file
cd $DATADIR
ls *realigned.bam > $MYBAMLIST

## run angsd to identify variable sites
angsd -b $MYBAMLIST -ref $REFGENOME -out $OUTNAME \
-uniqueOnly 1 -remove_bads 1 -only_proper_pairs 1 \
-minMapQ $QUAL -minQ $QUAL -minInd $MININD -setMinDepth $MINDEPTH -setMaxDepth $MAXDEPTH \
-minMaf $MINMAF -SNP_pval $PVAL \
-GL 1 -doGlf 2 -doMaf 2 -doMajorMinor 1 -doCounts 1 -nThreads ${SLURM_JOB_CPUS_PER_NODE}


## Nina's advice: As a general guidance, -GL 1, -doMaf 1/2 and -doMajorMinor 1 should be the preferred choice when data uncertainty is high

## Explanation of other terms used in my code:
##-uniqueOnly 1 #Discards reads that doesnt map uniquely
##-remove_bads 1 #Discard 'bad' reads, (flag >=256) 
##-only_proper_pairs 1 #Only use reads where the mate could be mapped
##-GL 1 #Estimate genotype likelihoods using the samtools model
##-doGlf 2 #output a beagle likelihood file (ending in .beagle.gz)
##-doMaf 2 #estimate allele frequencies using allele frequency (fixed major unknown minor)
##-doMajorMinor 1 #Infer major and minor alleles from genotype likelihoods
## -doCounts 1 #calculate various count statistics


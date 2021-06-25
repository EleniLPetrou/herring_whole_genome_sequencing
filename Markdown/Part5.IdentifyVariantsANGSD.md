# Install angsd on Klone

I installed angsd v0.935 and htslib 1.12 on Klone in a conda environment called *angsd_env* using the following commands:

``` bash
#angsd 0.935
#htslib 1.12

cd /gscratch/merlab/software/miniconda3/envs
conda create -n angsd_env
conda activate angsd_env
conda install -c bioconda angsd htslib

```

# Estimate genotype likelihoods and allele frequencies using angsd

I wonder how long this code will take to run...

*Advice from Physalia course: As a general guidance, -GL 1, -doMaf 1/2 and -doMajorMinor 1 should be the preferred choice when data uncertainty is high.*


## Explanation of other terms used in my code:
-uniqueOnly 1 #Discards reads that doesnt map uniquely

-remove_bads 1 #Discard 'bad' reads, (flag >=256) 

-only_proper_pairs 1 #Only use reads where the mate could be mapped

-GL 1 #Estimate genotype likelihoods using the samtools model

-doGlf 2 #output a beagle likelihood file (ending in .beagle.gz)

-doMaf 2 #estimate allele frequencies using allele frequency (fixed major unknown minor)

-doMajorMinor 1 #Infer major and minor alleles from genotype likelihoods

-doCounts 1 #calculate various count statistics

``` bash
#!/bin/bash
#SBATCH --job-name=elp_angsd_variants
#SBATCH --account=merlab
#SBATCH --partition=compute-hugemem
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=10-12:00:00
## Memory per node
#SBATCH --mem=100G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=elpetrou@uw.edu


##### ENVIRONMENT SETUP ##########
MYCONDA=/gscratch/merlab/software/miniconda3/etc/profile.d/conda.sh # path to conda installation on our Klone node. Do NOT change this.
MYENV=angsd_env #name of the conda environment containing samtools software. 

## Specify directories with data
DATADIR=/mmfs1/gscratch/scrubbed/elpetrou/bam #directory with realigned bam files
REFGENOME=/gscratch/merlab/genomes/atlantic_herring/GCF_900700415.1_Ch_v2.0.2_genomic.fna #path to fasta genome
MYBAMLIST=bam.filelist # name of text file with bam files
OUTNAME=all_samples_maf0.01 #output file name

## Specify filtering values for angsd
QUAL=20 #quality threshold for minMapQ and minQ filtering options
MAXDEPTH=3000 # maximum total depth (across all individuals. non-zero mean depth +2sd = 5. So if all individuals are sequenced 5x at a site, the global max depth would be 2750)
MINDEPTH=10 #minimum total depth (across all individuals)
MININD=275 #minimum number of individuals for a genomic site to be included in output (half of the individuals, in my case)
MINMAF=0.01 #retain only SNPs with this global minor allele frequency
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

```

# Summary of results with filtering parameters used above :


``` 
Done reading data waiting for calculations to finish
	-> Done waiting for threads
	-> Output filenames:
		->"all_samples_maf0.01.arg"
		->"all_samples_maf0.01.beagle.gz"
		->"all_samples_maf0.01.mafs.gz"
	-> Mon Jun 14 04:59:57 2021
	-> Arguments and parameters for all analysis are located in .arg file
	-> Total number of sites analyzed: 688371635
	-> Number of sites retained after filtering: 11380359 
	[ALL done] cpu-time used =  1377495.38 sec
	[ALL done] walltime used =  407206.00 sec
```

Wow, so ~11.3 million SNPs were preent at > 0.1 MAF and genotyped in over 50% of samples. Not bad! I moved these output files to this folder: /gscratch/scrubbed/elpetrou/angsd


## Create a stringently filtered data set by using the -sites filter in angsd. 

For a SNP to be reatined in the stringently filtered data set, it had to have a maf > 0.05 and less than 30% missing data. I also removed SNPs that were in mtDNA. This is how I made the -sites file from a .mafs file:

``` bash
# filter_angsd_sites.sh
# Make a sites file for angsd

# The 8th column of the .mafs output file from angsd contains information about the number of individuals that were genotyped at a particular site. 
# Since I have 549 individuals, a site must be genotyped in 384 individuals to have <= 30% missing genotypes

DATADIR=/gscratch/scrubbed/elpetrou/angsd
ANGSD_MAF=all_samples_maf0.05.mafs.gz #angsd output file
LOCI_FILT=all_samples_maf0.05_miss0.3_NoMtDNA.txt
ANGSD_SITES=all_samples_maf0.05_miss0.3_NoMtDNA.sites

cd $DATADIR

# unzip .mafs.gz file
gunzip $ANGSD_MAF

# The first part of pipe only retains sites with more than 384 indivs genotyped.
# The second part of the pipe removes any sites from mtDNA (labeled as NC_009577.1 in the Atlantic herring genome)


awk '$8 > 384' $ANGSD_MAF | awk -F: '$1 !~ "NC_009577.1"' > $LOCI_FILT

# Open up the outfile and check it with head and tail commands; make sure that everything looks ok. It has 583,107 lines! Heck yeah!
wc -l $LOCI_FILT

# Create the sites file for angsd. To do this,  keep only the first 4 columns of the file and strip the header
cut -f 1,2,3,4 $LOCI_FILT | sed '1d' > $ANGSD_SITES

# output has 583,106 SNPs!

# index the sites file
conda activate angsd_env
angsd sites index $ANGSD_SITES

# re-gzip the ANGSD_MAF file, so you save space.
gzip $ANGSD_MAF

```
 
## re-run angsd with the -sites file to output genotype likelihoods for the stringently filtered data set. 

``` bash

#!/bin/bash
#SBATCH --job-name=elp_angsd_variants
#SBATCH --account=merlab
#SBATCH --partition=compute-hugemem
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=20
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=5-12:00:00
## Memory per node
#SBATCH --mem=600G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=elpetrou@uw.edu


##### ENVIRONMENT SETUP ##########
MYCONDA=/gscratch/merlab/software/miniconda3/etc/profile.d/conda.sh # path to conda installation on our Klone node. Do NOT change this.
MYENV=angsd_env #name of the conda environment containing samtools software. 

## Specify directories with data
DATADIR=/mmfs1/gscratch/scrubbed/elpetrou/bam #directory with realigned bam files
REFGENOME=/gscratch/merlab/genomes/atlantic_herring/GCF_900700415.1_Ch_v2.0.2_genomic.fna #path to fasta genome
MYBAMLIST=bam.filelist # name of text file with bam files
SITES_FILE=/gscratch/scrubbed/elpetrou/angsd/all_samples_maf0.05_miss0.3_NoMtDNA.sites
OUTNAME=all_samples_maf0.05_miss0.3_NoMtDNA #output file name

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
-minMaf $MINMAF -SNP_pval $PVAL -sites $SITES_FILE \
-GL 1 -doGlf 2 -doMaf 2 -doMajorMinor 3 -doCounts 1 -nThreads ${SLURM_JOB_CPUS_PER_NODE}


## Nina's advice: As a general guidance, -GL 1, -doMaf 1/2 and -doMajorMinor 1 should be the preferred choice when data uncertainty is high (unless you have a sites file, in which case -doMajorMinor 3)

## Explanation of other terms used in my code:
##-uniqueOnly 1 #Discards reads that doesnt map uniquely
##-remove_bads 1 #Discard 'bad' reads, (flag >=256) 
##-only_proper_pairs 1 #Only use reads where the mate could be mapped
##-GL 1 #Estimate genotype likelihoods using the samtools model
##-doGlf 2 #output a beagle likelihood file (ending in .beagle.gz)
##-doMaf 2 #estimate allele frequencies using allele frequency (fixed major unknown minor)
##-doMajorMinor 1 #Infer major and minor alleles from genotype likelihoods
##-doMajorMinor3: use major and minor from a file (requires -sites file.txt)
## -doCounts 1 #calculate various count statistics

```



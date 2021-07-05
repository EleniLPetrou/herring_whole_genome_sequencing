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

Update 20210705: Upon further investigation, I don't think that this segmentation error was entirely a memory issue. I filtered the dataset stringently (maf > 0.05 , max missing data per SNP = 30%) to get 607,998 SNPs and the program crashed again. Next I tried the following: I removed the mtDNA loci at the end of file and ran pcangsd on an interactive node. I am not sure of there was something amiss with the last character of the file or if pcangsd can only handle diploid loci. At any rate, moving forward I decided to create a beagle file with no mtDNA loci and analyze that with pcangsd.

Update: 20210705 noon: pcangsd will only run to completion on an interactive node. It gives a the segmentation error when I try to run it through an sbatch script. I have no idea why that is, but I guess running it on an interactive node is fine. Whatever. At least I got it to run.


## Run pcangsd via an interactive node on Klone.

``` bash
# The purpose of this script is to calculate a covriance matrix for PCA.
# It uses a beagle file created from angsd to do this.
# For some odd reason I could only get pcangsd to work on an interactive node.

# Request an interactive node on Klone
srun -p compute-hugemem -A merlab --nodes=1 --ntasks-per-node=1 --time=02:00:00 --mem=100G --pty /bin/bash

#####################################################################
##### ENVIRONMENT SETUP ##########

## software information
MYCONDA=/gscratch/merlab/software/miniconda3/etc/profile.d/conda.sh # path to conda installation on our Klone node. Do NOT change this.
MYENV=pcangsd_env #name of the conda environment containing samtools software. 
PCANGSD=/gscratch/merlab/software/miniconda3/envs/pcangsd/pcangsd.py #path to pcangsd software on Klone

## data information
DATADIR=/gscratch/scrubbed/elpetrou/angsd #path to input files (beagle file)
OUTDIR=/gscratch/scrubbed/elpetrou/angsd #path to output files
MYINFILE=all_samples_maf0.05_miss0.3.nuclear.beagle.gz #name of beagle file
OUTPREFIX=results_pca_all_samples_maf0.05_miss0.3.nuclear #prefix for output files

##################################################################
## Activate the conda environment:
## start with clean slate
module purge

## This is the filepath to our conda installation on Klone. Source command will allow us to execute commands from a file in the current shell
source $MYCONDA

## activate the conda environment
conda activate $MYENV

## run pcangsd
python $PCANGSD -beagle $DATADIR'/'$MYINFILE -o $OUTDIR'/'$OUTPREFIX -threads 16

```

Here is what printed to stdout:

PCAngsd v.1.02
Using 16 thread(s).

Parsing Beagle file.
Loaded 607980 sites and 550 individuals.
Estimating minor allele frequencies.
EM (MAF) converged at iteration: 12
Number of sites after MAF filtering (0.05): 607980

Estimating covariance matrix.
Using 1 principal components (MAP test).
Individual allele frequencies estimated (1).
Individual allele frequencies estimated (2). RMSE=0.0019361632690195003
Individual allele frequencies estimated (3). RMSE=0.0014555362674571876
Individual allele frequencies estimated (4). RMSE=0.0010982040617531592
Individual allele frequencies estimated (5). RMSE=0.0008110332153153621
Individual allele frequencies estimated (6). RMSE=0.0005924548419604714
Individual allele frequencies estimated (7). RMSE=0.0004328266703818499
Individual allele frequencies estimated (8). RMSE=0.0003176452371260005
Individual allele frequencies estimated (9). RMSE=0.00023500501464837205
Individual allele frequencies estimated (10). RMSE=0.00017544957001603954
Individual allele frequencies estimated (11). RMSE=0.0001322901088926976
Individual allele frequencies estimated (12). RMSE=0.00010066557501316355
Individual allele frequencies estimated (13). RMSE=7.744369874595447e-05
Individual allele frequencies estimated (14). RMSE=6.016301896403817e-05
Individual allele frequencies estimated (15). RMSE=4.714383588702117e-05
Individual allele frequencies estimated (16). RMSE=3.728905354265265e-05
Individual allele frequencies estimated (17). RMSE=2.9704038973510887e-05
Individual allele frequencies estimated (18). RMSE=2.3925885101893462e-05
Individual allele frequencies estimated (19). RMSE=1.9365940158795353e-05
Individual allele frequencies estimated (20). RMSE=1.5799205179940233e-05
Individual allele frequencies estimated (21). RMSE=1.2974865771266258e-05
Individual allele frequencies estimated (22). RMSE=1.0721352148058067e-05
Individual allele frequencies estimated (23). RMSE=8.941152664693092e-06
PCAngsd converged.
Saved covariance matrix as /gscratch/scrubbed/elpetrou/angsd/results_pca_all_samples_maf0.05_miss0.3.nuclear.cov (Text).



# Estimating population-specific allele frequencies and site frequency spectra

## Install stable version of angsd (0.921) that can handle -sites flag

My goal is to calculate population-specific allele frequencies and site frequency spectra for each population separately, so I can estimate pairwise FST values and look for signatures of natural selection. I want to do this using the 607K SNPs that I discovered across all individuals. Unfortunately, the most recent version of angsd has an error (related to compatibility with htslib), such that the -sites argument yields 0 sites at the end of the analysis. After much searching on the issues page of angsd on GitHub, I determined that the most recent version of angsd in which the -sites flag works is version 0.921 (with htslib v1.9). Here is how I installed this software on klone:

``` bash
# Try installing a different version that can handle the -sites filter for the sfs analyses
cd /gscratch/merlab/software/miniconda3/envs
conda create -n angsd_env_0.921
conda activate angsd_env_0.921
conda install -c bioconda angsd=0.921 htslib=1.9

```

## Generate site frequency likelihoods for each population

## Estimate the site frequency spectrum (1-dimensional) for each population

## Estimate pairwise FST between two populations

- estimate the 2-dimensional frequency spectrum for each pair of populations
- 

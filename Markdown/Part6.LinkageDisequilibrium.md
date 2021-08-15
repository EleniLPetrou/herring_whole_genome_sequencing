# Analyses of linkage disequilibrium using ngsLD

I estimated the extent of linkage disequilibrium  using the program ngsLD and genotype likelihoods estimated by angsd.

## Install ngsLD on Klone cluster

## Run LD analysis

## Parse results of LD analysis
The output file was immense (500 Gb), so I split the results by chromosome to make plotting and manipulating the results easier. 

## Interpret the ngsLD results
ngsLD outputs a TSV file with LD results for all pairs of sites for which LD was calculated, where the first two columns are positions of the SNPs, the third column is the distance (in bp) between the SNPs, and the following 4 columns are the various measures of LD calculated (r^2 from pearson correlation between expected genotypes, D from EM algorithm, D' from EM algorithm, and r^2 from EM algorithm). 

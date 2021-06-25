# filter_angsd_sites.sh
#Make a sites file for angsd

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
# The seond part of the pipe removes any sites from mtDNA (NC_009577.1 in the genome I used)


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
# The purpose of this script is to subset a beagle (or a mafs file) produced by angsd, using a subset of SNPs stored in a -sites file (angsd format)
# In the beagle file, SNP information is stored as NC_045152.1_148592 (chrom_position). So create a txt file with a single column containing this information about your SNPs of interest.

# request interactive node on Klone
srun -p compute-hugemem -A merlab --nodes=1 --ntasks-per-node=8 --time=24:00:00 --mem=100G --pty /bin/bash

# Specify file names and data directories
DATADIR=/gscratch/scrubbed/elpetrou/angsd # directory with input data files
OUTDIR=/gscratch/scrubbed/elpetrou/gtseq #output directory
FILE1=snpid_gtseq_candidates.txt #file containing snpids of snps of interest
FILE2=all_samples_maf0.05_miss0.3.nuclear.beagle #name of beagle file that you would like to subset (without gz esxtension)
OUTFILE=all_samples_maf0.05_miss0.3.nuclear.gtseq_candidates.beagle

# Unzip the beagle file
cd $DATADIR
gunzip $FILE2'.gz'

# Use awk programming language to print lines in FILE2 that match specific columns in FILE1
#Look for keys (first word of line) in file2 that are also in file1.

#Step 1: fill array a with the first word of file 1:
#awk '{a[$1];}' file1

#Step 2: Fill array a and ignore file 2 in the same command. For this check the total number of records until now with the number of the current input file.
#awk 'NR==FNR{a[$1]}' file1 file2

#Step 3: Ignore actions that might come after } when parsing file 1
#awk 'NR==FNR{a[$1];next}' file1 file2 

#Step 4: print key of file2 when found in the array a
#awk 'NR==FNR{a[$1];next} $1 in a' $FILE1 $FILE2 > $OUTDIR/$OUTFILE

# Step 5:print the header of file2. 

awk 'NR==FNR{a[$1];next} FNR==1{print $0; next} $1 in a' $FILE1 $FILE2 > $OUTDIR/$OUTFILE

# Gzip the beagle files
gzip $FILE2

cd $OUTDIR
gzip $OUTFILE

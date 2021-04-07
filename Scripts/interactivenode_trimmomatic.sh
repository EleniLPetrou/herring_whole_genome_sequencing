# Run trimmomatic on interactive compute node on Klone


# Use interactive node to check that singularity is working
srun -p compute-hugemem -A merlab --nodes=1 \
--ntasks-per-node=1 --time=02:00:00 \
--mem=100G --pty /bin/bash


# Specify the paths to input files and directories
DATADIR=/mmfs1/gscratch/scrubbed/elpetrou/fastq/WA_herring
SAMPLELIST=trimmomatic_list.txt
SUFFIX1=_R1_001.fastq # Suffix to raw fastq files. The forward reads with paired-end data.
SUFFIX2=_R2_001.fastq # Suffix to raw fastq files. The reverse reads with paired-end data. 
ADAPTERFILE=/mmfs1/home/elpetrou/scripts/NexteraPE_EP.fa # File with adapter sequences. This is based on the file that was provided in the Physalia course, and double-checked using the Illumina Adapter Sequences pdf
OUTDIR=/mmfs1/gscratch/scrubbed/elpetrou/fastq_trimmed #where to store output files


##############################################################################
# Save the sample names of the forward reads into a text file (for looping thru samples later)
mkdir $OUTDIR

cd $DATADIR
ls *$SUFFIX1 > $SAMPLELIST  

##############################################################################
# Run Trimmomatic. For an explanation of trimmomatic commands, see: 
# http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/TrimmomaticManual_V0.32.pdf
# https://datacarpentry.org/wrangling-genomics/03-trimming/index.html

# Testing this piece of code
for infile in `cat $SAMPLELIST` 
do
	base=`basename --suffix=$SUFFIX1 $infile`
	echo $base
	echo $base$SUFFIX2
done

# Run trimmomatic

for infile in `cat $SAMPLELIST` 
do
	base=`basename --suffix=$SUFFIX1 $infile`
	trimmomatic PE \
	-threads 1 -phred33 \
	${infile} \
	${base}$SUFFIX2 \
	${base}_R1_001.trim.fastq \
	${base}_R1_001.unpaired.trim.fastq \
	${base}_R2_001.trim.fastq \
	${base}_R2_001.unpaired.trim.fastq \
	ILLUMINACLIP:$ADAPTERFILE:2:30:10:1:true \
	SLIDINGWINDOW:4:20 \
	MINLEN:40 
done

# Yaaay! This code is running!!
# Here is an example of some output: Input Read Pairs: 6825779 Both Surviving: 5932557 (86.91%) Forward Only Surviving: 468865 (6.87%) Reverse Only Surviving: 215887 (3.16%) Dropped: 208470 (3.05%)
# For one set of fastq samples, I think it took about 5 min. So it will take about a day to finish trimming one lane on Klone (give it two days as buffer)
#############################################################################
# Move the results files to the output directory

mv *_R1_001.trim.fastq $OUTDIR
mv *_R2_001.trim.fastq $OUTDIR
mv *_R1_001.unpaired.trim.fastq $OUTDIR
mv *_R2_001.unpaired.trim.fastq $OUTDIR

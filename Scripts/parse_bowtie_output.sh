LOGFILE=bowtie2_.out
OUFILE=bowtie2_unique_alignments.txt

grep -w "aligned concordantly exactly 1 time" $LOGFILE >> $OUTFILE
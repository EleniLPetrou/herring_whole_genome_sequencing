#!/bin/bash
#SBATCH --job-name=elp_RealignerTargetCreator
#SBATCH --account=merlab
#SBATCH --partition=compute-hugemem
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=8
## Walltime (days-hours:minutes:seconds format)
#SBATCH --time=7-12:00:00
## Memory per node
#SBATCH --mem=80G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=elpetrou@uw.edu

##### ENVIRONMENT SETUP ####################################################
## Specify the directories and file names containing your data (edit lines 16-20 as needed)
DATADIR=/gscratch/scrubbed/elpetrou/bam #path to the bam files that you want to analyze with GATK3
GENOMEDIR=/gscratch/merlab/genomes/atlantic_herring #directory containing the genome
REFERENCE=GCF_900700415.1_Ch_v2.0.2_genomic.fna # Name of genome
BASEREFERENCE=GCF_900700415.1_Ch_v2.0.2_genomic #Name of genome without file extension
SUFFIX1=_minq20_sorted_dedup_overlapclipped.bam #Suffix of the bam files that you would like to analyze using GATK3

## Specify some information about the conda environments, singularities, and names of intermediate files. You probably do NOT need to edit this information.
BAMLIST=bam_list_dedup_overlapclipped.list # A list of merged, deduplicated, and overlap-clipped bam files. This file has to have a suffix of ".list"!! This list will be made in line 55 and will be saved to the $DATADIR
MYCONDA=/gscratch/merlab/software/miniconda3/etc/profile.d/conda.sh # path to conda installation on our Klone node. Do NOT change this.
GATK3=/gscratch/merlab/software/miniconda3/envs/gatk3_env/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar # the path to the gatk3 jarfile
SAMTOOLS_ENV=samtools_env #name of the conda environment running samtools
PICARD_ENV=picard_env #name of the conda environment running picard
GATK3_ENV=gatk3_env #name of the conda environment running gatk3

###############################################################################
## Clean the environment before starting
module purge

## Source command will allow us to execute commands from a file in the current shell (conda)
source $MYCONDA

###### CODE FOR ANALYSIS ####################################################
## Use samtools to index the genome
conda activate $SAMTOOLS_ENV
samtools faidx $GENOMEDIR'/'$REFERENCE

# Make a text file containing a list of all the bam files you want to analyze
for MYSAMPLEFILE in $DATADIR'/'*$SUFFIX1
do
echo $MYSAMPLEFILE >> $BAMLIST
done

# Use samtools to index each bam file - this works!!
for MYSAMPLEFILE in $DATADIR'/'*$SUFFIX1
do
samtools index $MYSAMPLEFILE
done

#leave the samtools conda environment
conda deactivate 

###########################################
# activate the picard conda environment
conda activate $PICARD_ENV

# create a sequence dictionary for the reference genome (for some ridiculous reason, GATK3 needs this file)

picard CreateSequenceDictionary --REFERENCE $GENOMEDIR'/'$REFERENCE --OUTPUT $GENOMEDIR'/'$BASEREFERENCE.dict
#leave the picard conda environment
conda deactivate

##############################################
# activate the GATK3 conda environment
conda activate $GATK3_ENV
cd $DATADIR

# Create a list of potential indels
java -jar $GATK3 \
-T RealignerTargetCreator \
-R $DATADIR'/'$REFERENCE \
-I $DATADIR'/'$BAMLIST \
-nt ${SLURM_JOB_CPUS_PER_NODE} \
-o $DATADIR'/'all_samples_for_indel_realigner.intervals \
-drf BadMate


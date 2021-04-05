20210405:

# WGS data

## Data download and backup

Sequencing data were downloaded from the NW Genomics Center using Globus software. The raw data (.tar files) have been saved to three locations:
  1. An external hard drive in my office
  2. The HauserLab fireproof external hard drive
  3. The /gscratch/scrubbed/elpetrou directory on Klone

* We should also back up the data on LOLO archive

For each of these data backups, I used the MD5sum file to verify that the data were not corrupted. 

## Unzip data

I unzipped the data on Klone [using this script](https://github.com/EleniLPetrou/herring_whole_genome_sequencing/blob/102c8f2fcdacae63b32a074be61be1d13fdb52a1/Scripts/gunzip.sh)

## Run FastQC

To check the quality of the raw sequence data I ran the software FastQC [using this script](https://github.com/EleniLPetrou/herring_whole_genome_sequencing/blob/102c8f2fcdacae63b32a074be61be1d13fdb52a1/Scripts/fastqc.sh) on Klone

## Visualize FastQC output using MultiQC

I visualized the voluminous FastQC output using MultiQC software on Klone. See [this script](https://github.com/EleniLPetrou/herring_whole_genome_sequencing/blob/102c8f2fcdacae63b32a074be61be1d13fdb52a1/Scripts/multiqc.sh)

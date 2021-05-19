#Create a conda environment for GATK3
conda create -n gatk3_env

# enter the conda environment and download GATK3 from the web
conda activate gatk3_env
cd gatk3_env
wget https://storage.googleapis.com/gatk-software/package-archive/gatk/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef.tar.bz2
tar xjf GenomeAnalysisTK-3.8-1-0-gf15c1c3ef.tar.bz2
 
#Test the installation:
GATK3=/gscratch/merlab/software/miniconda3/envs/gatk3_env/GenomeAnalysisTK-3.8-1-0-gf15c1c3ef/GenomeAnalysisTK.jar
java -jar $GATK3 -h 

#This should print out some version and usage information, as well as a list of the tools included in the GATK. As the Usage line states, to use GATK you will always build your command lines like this: java -jar GenomeAnalysisTK.jar -T  [arguments] 



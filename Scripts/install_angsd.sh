#angsd 0.935
#htslib 1.12
cd /gscratch/merlab/software/miniconda3/envs
conda create -n angsd_env
conda activate angsd_env
conda install -c bioconda angsd htslib

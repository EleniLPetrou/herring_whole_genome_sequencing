# PCA using angsd output files

First, I downloaded and installed pcangsd version 1.02 software on Klone:

``` bash
# Directions from: http://www.popgen.dk/software/index.php/PCAngsdv2

# Go to the directory where you will install your software
cd /gscratch/merlab/software/miniconda3/envs

# create a conda environment for pcangsd and activate it
conda create -n pcangsd_env
conda activate pcangsd_env

# install cython v0.29.23 (needed for pcangsd installation)
conda install -c anaconda cython

# install numpy v1.20.2 (needed for pcangsd installation)
conda install -c anaconda numpy

#install pcangsd Version 1.02 (done on 20210617)
#Download the source code:
git clone https://github.com/Rosemeis/pcangsd.git

#Configure, Compile and Install:
cd pcangsd/
python setup.py build_ext --inplace

#Install dependencies: The required set of Python packages are easily installed using the pip command and the requirements.txt file included in the pcangsd folder.

pip install --user -r requirements.txt

# Path to PCANGSD: /gscratch/merlab/software/miniconda3/envs/pcangsd

# Get help
python pcangsd.py -h
# woohoo! installation worked!!

```

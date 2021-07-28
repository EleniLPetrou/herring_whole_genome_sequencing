# This script documents how I installed ngsLD version 1.1.1 and its dependencies in a conda environment on our lab's Klone node on 20210726. 

#Create a conda environment for ngsLD
conda create -n ngsLD_env

# enter the conda environment and download ngsLD from GitHub
conda activate ngsLD_env
cd ngsLD_env
git clone https://github.com/fgvieira/ngsLD.git

# install dependencies
#gcc: >= 4.9.2 tested on Debian 7.8 (wheezy)
conda install -c anaconda gcc_linux-64 # version 9.3.0 was available on conda and that is what I installed
#zlib: v1.2.7 tested on Debian 7.8 (wheezy). Version 1.2.11 was available on conda and that is what I installed
conda install -c conda-forge zlib
#gsl : v1.15 tested on Debian 7.8 (wheezy)
conda install -c conda-forge gsl ## version 2.7 was available on conda and that is what I installed

# PKG_CONFIG_PATH is a environment variable that specifies additional paths in which pkg-config will search for its .pc files.
#The pkg-config program is used to retrieve information about installed libraries in the system. 
#The primary use of pkg-config is to provide the necessary details for compiling and linking a program to a library

# To set the PKG_CONFIG_PATH value use
export PKG_CONFIG_PATH=/gscratch/merlab/software/miniconda3/envs/ngsLD_env/lib/pkgconfig

# Check
echo $PKG_CONFIG_PATH

# Compile ngsLD
cd /gscratch/merlab/software/miniconda3/envs/ngsLD_env/ngsLD
make #The purpose of the make utility is to determine automatically which pieces of a large program need to be recompiled, and issue the commands to recompile them.

#Test the installation:
cd /gscratch/merlab/software/miniconda3/envs/ngsLD_env/ngsLD
./ngsLD

# Got this error message:
#./ngsLD: error while loading shared libraries: libgsl.so.25: cannot open shared object file: No such file or directory

# Thus, I have to specify path to libgsl.so.25. You will probably have to include this in all of the future scripts running ngsLD

LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/gscratch/merlab/software/miniconda3/envs/ngsLD_env/lib 
export LD_LIBRARY_PATH

# test out the program again:
./ngsLD

# Success! It works!!

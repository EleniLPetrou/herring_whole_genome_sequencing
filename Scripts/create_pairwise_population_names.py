#!/usr/bin/env python3

#Name of script: create_pairwise_population_names.py

# Modules
from itertools import combinations
import os

# Get current working directory
#os.getcwd()

mypath = 'C:\\Users\\elpet\\OneDrive\\Documents\\herring_postdoc\\scripts' #path to working directory containing data
input_file = "population_base_names.txt" #text file with each population name on one line
output_file = "pairwise_population_comparisons.txt" #name of output file

# Set the current path to the working directory
os.chdir(mypath)

#initialize an empty list to hold data
mylist = []

# read in the file line by line and save each line to the list
with open(input_file, "r") as the_file:
    for line in the_file:
        mypop = line.strip('\n')
        mylist.append(mypop)


# Use the combinations function to create all pairwise (not redundant) combinations from your initial list, and save those to a file.

lengthOfStrings = 2
       
with open(output_file, "w") as the_file:
    for mytuple in combinations(mylist, lengthOfStrings):
        mystring = "\t".join(mytuple)
        print(mystring)
        the_file.write(mystring + '\n')
        

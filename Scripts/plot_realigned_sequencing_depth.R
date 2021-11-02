# The purpose of this script is to plot data on sequencing read depth
# As input it takes the file produced by parse_realigned_sequencing_depth.R

################################################################################
# Load libraries
library(tidyverse)

# Specify the directory containing a tab-delimited text file with sequencing depth for each individual sample
DATADIR <- "E:/Dropbox (MERLAB)/Eleni/postdoc_wgs/results"

# Specify names of files
INFILE <- "sequencing_depth_after_realignment_concatenated_results.txt" #input file
OUTFILE <- "sequencing_depth_after_realignment.pdf" #output file
METAFILE <- "E:/Dropbox (MERLAB)/Eleni/postdoc_wgs/sample_metadata/mapping_metadata.txt" # full path to sampling location metadata

# set working directory
setwd(DATADIR)

##############################################################################
# Read in the data
depth_df <- read.delim(INFILE)
meta_df <- read.delim(METAFILE)

# Specify that the populations should appear in a specific order
mylevels <- c("Squaxin", "Pt. Orchard", "Skagit", "Quilcene", "Elliott Bay", "Cherry Pt.", 
              "Craig", "Krestof","Sitka", "W. Crawfish", "Olga Pt.", "Berners Bay")



# Join these data frames for plotting

plotting_df <- left_join(depth_df, meta_df, by = "population")
plotting_df$full_name <- factor(plotting_df$full_name, levels = mylevels)


# Allow scientific notation
options(scipen = 0) 



plot1 <- ggplot(plotting_df, aes(x = full_name, color = state)) +
  geom_point(aes(x = full_name, y = mean_depth)) +
  geom_boxplot(aes(x = full_name, y = mean_depth)) +
  ylab("sequencing depth") +
  xlab("population") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90))

plot1


# save the plot as a pdf
ggsave(OUTFILE, plot1)



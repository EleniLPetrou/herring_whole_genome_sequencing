# The purpose of this script is to compile and plot data on sequencing read depth
# after bam files have been filtered and indel realignment has taken place. 
# As input is takes the .depth files that are output from samtools depth.

################################################################################
# Load libraries
library(tidyverse)

################################################################################
# read in the files and start data processing

command_args <- commandArgs(trailingOnly = TRUE)
fileName <- command_args[1]

# For each file, read in the depth data and calculate summary statistics
# Compute sequencing depth summary statistics

depth <- read_tsv(fileName, col_names = F)$X1
mean_depth <- mean(depth)
sd_depth <- sd(depth)
mean_depth_nonzero <- mean(depth[depth > 0])
mean_depth_within2sd <- mean(depth[depth < mean_depth + 2 * sd_depth])
median <- median(depth)
presence <- as.logical(depth)
proportion_of_reference_covered <- mean(presence)
  
# save these results to a dataframe
output <- data.frame(fileName, mean_depth, sd_depth, 
                       mean_depth_nonzero, mean_depth_within2sd, 
                       median, proportion_of_reference_covered)
  
output_df <- output %>%
    mutate(across(where(is.numeric), round, 3)) %>%
    separate(fileName, "population", sep = "_", remove = FALSE,  extra = "drop")
  
# write the output_df to a text file
write.table(output_df, file = paste0(fileName,"depth_results.txt"), 
              append = FALSE, quote = FALSE, sep = "\t",
              eol = "\n", na = "NA", dec = ".", row.names = FALSE,
              col.names = TRUE)
  
#remove the giant intermediate files that take up a lot of memory
remove(depth)
remove(presence)
  
#clean up the workspace memory
gc()
  


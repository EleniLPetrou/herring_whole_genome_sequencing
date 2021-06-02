# The purpose of this script is to compile and plot data on sequencing read depth
# after bam files have been filtered and indel realignment has taken place. 
# As input is takes the .depth files that are output from samtools depth.

################################################################################
# Load libraries
library(tidyverse)

# To run this code, put all of your depth files in a single directory
#DATADIR <- "C:/Users/elpet/OneDrive/Documents/herring_postdoc/realigned_bam"
DATADIR <- "/gscratch/scrubbed/elpetrou/bam/"

# set working directory
setwd(DATADIR)
#list.files()

# Specify the names of data files used
fileNames <- Sys.glob("*.gzdepth_results.txt") #this is R's version of a wildcard


################################################################################
# Part 1: Create a concatenated dataframe and save it as a text file
# read in the files and start data processing

output_df = data.frame() #initialize empty dataframe


for (fileName in fileNames) {
  print(fileName) #counter
  df <- read.delim(fileName)
  output_df <- rbind(output_df, df) # add each individual dataframe to a big dataframe
}


# Mean depth and standard deviation over all individuals
output_df$mean_depth <- as.numeric(output_df$mean_depth)
output_df$sd_depth <- as.numeric(output_df$sd_depth)

# save the dataframe as a text file
write.table(output_df, file = "sequencing_depth_after_realignment_concatenated_results.txt", 
            append = FALSE, quote = FALSE, sep = "\t",
            eol = "\n", na = "NA", dec = ".", row.names = FALSE,
            col.names = TRUE)


################################################################################
# Part2 : Plot the depth distribution

# read in the concatenated dataframe

#output_df <- read.delim("sequencing_depth_after_realignment_concatenated_results.txt")

#allow scientific notation
options(scipen = 0) 

plot1 <- ggplot(output_df, aes(x = population, color = population)) +
  geom_point(aes(x = population, y = mean_depth)) +
  geom_boxplot(aes(x = population, y = mean_depth)) +
  ylab("sequencing depth") +
  xlab("population") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 90))

plot1


# save the plot as a pdf
ggsave("sequencing_depth_after_realignment.pdf", plot1)



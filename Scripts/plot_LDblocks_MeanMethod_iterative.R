# The purpose of this script is to  plot summary data on linkage disequilibrium
# for each chromosome. As input, the script takes the mean estimate of LD, summarized over a certain blocksize.

################################################################################
# Load libraries

library(tidyverse)
library(RColorBrewer)

# To run this code, put all of your depth files in a single directory
#DATADIR <- "/gscratch/scrubbed/elpetrou/bam/ngsld"
DATADIR <- "E:/Dropbox (MERLAB)/Eleni/postdoc_wgs/results/ngsld"

# set working directory
setwd(DATADIR)

# Specify the names of data files used
fileNames <- Sys.glob("*.1000.quant.txt") #this is R's version of a wildcard
file_list <- as.list(fileNames)

# Specify the name of the outpt file (pdf)
OUTFILE <- "plot_LDblocks_QuantMethod.pdf"

################################################################################
# Part 1: Create a concatenated dataframe and save it as a text file
ld_df <- file_list %>%
  set_names(nm = c(1:length(file_list))) %>%
  map_dfr(
    ~ read_delim(.x, col_types = cols(), col_names = TRUE, delim = "\t"),
    .id = "linkage_group"
  )


# Part 2: Plot the data

# Triangle heatmap to visualize LD blocks

plot1 <- ggplot(ld_df, aes(Pos1, Pos2)) +
  theme_bw() +
  xlab('Position on LG (Mb)') +
  ylab('Position on LG (Mb)') +
  geom_tile(aes(fill = R2)) +
  scale_fill_gradientn(colors = brewer.pal(7,"YlGnBu"), na.value = "grey90") +
  facet_wrap(~factor(linkage_group, levels=c(1:length(file_list)))) +
  #scale_fill_gradient(low = 'grey95', high = 'darkblue', space = 'Lab') +
  theme(axis.text.x = element_text(angle = 90),
        axis.ticks = element_blank(),
        axis.line = element_blank(),
        panel.border = element_blank(),
        panel.grid.major = element_line(color = '#eeeeee'))

plot1


# save the plot as a pdf
ggsave(OUTFILE, plot1)

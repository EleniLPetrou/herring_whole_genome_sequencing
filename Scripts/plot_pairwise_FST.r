# Load libraries
library(tidyverse)
library(reshape2)

# Specify data directory containing input file
DATADIR <- "E:/Dropbox (MERLAB)/Eleni/postdoc_wgs/results/angsd/all_samples_maf0.05_miss_0.3"

# Specify name of input file
INFILE <- "pairwise_population_FST_concatenated_results.txt" #tab-delimited text file containing fst data
METAFILE <- "E:/Dropbox (MERLAB)/Eleni/postdoc_wgs/sample_metadata/mapping_metadata.txt" # full path to sampling location metadata

OUTFILE <- "pairwise_population_FST_all_samples_maf0.05_miss0.3.nuclear.pdf" # Specify name of output file

# Specify a custom order for the populations in the heatmap (WA by spawn time, then AK by spawn time)

my_levels <- c("SQUA14", "PORT14", "SMBY15", "QLBY19", "ELBY15", "CHPT16", 
               "CRAIG18", "KRES19", "SITKA17", "CRAW20", "OLGA19", "BERN16")

my_levels2 <- c("Squaxin", "Pt. Orchard", "Skagit", "Quilcene", "Elliott Bay", "Cherry Pt.", 
                "Craig", "Krestof","Sitka", "W. Crawfish", "Olga Pt.", "Berners Bay")

##############################################################################
# set working directory
setwd(DATADIR)

# Read in the data and manipulate it for plotting
fst_df <- read.table(INFILE, header = TRUE)
meta_df <- read.delim(METAFILE)
mini_df <- meta_df %>%
  select(population, full_name)


# make a temporary df with the population names joined and bind them together, 
# to make the full pairwise matrix.

temp_df <- fst_df %>%
  rename(Pop1 = Pop2, Pop2 = Pop1)

full_df <- rbind(fst_df, temp_df)

full_df$weighted_fst <- round(full_df$weighted_fst, digits = 3)

# Order the levels according to a custom order  

full_df$Pop1 <- factor(x = full_df$Pop1,
                       levels = my_levels, 
                       ordered = TRUE)

full_df$Pop2 <- factor(x = full_df$Pop2,
                       levels = my_levels, 
                       ordered = TRUE)

###Part 2: remove duplicate pairwise-columns

# Turn the dataframe into a matrix

my_mat <- acast(full_df, Pop1~Pop2, value.var = "weighted_fst")

## Specify some functions to retrieve upper part of matrix
# Get lower triangle of the correlation matrix

get_lower_tri <- function(Fstmat){
  Fstmat[upper.tri(Fstmat)] <- NA
  return(Fstmat)
}

## subset the matrix
lower_tri <- get_lower_tri(my_mat)
lower_tri

##Use the package reshape to melt the matrix into a df again:
final_df <- melt(lower_tri, value.name = "weighted_fst")

plotting_df <- left_join(final_df, mini_df, by = c("Var1" = "population")) %>%
  rename(Pop1 = full_name) %>%
  left_join(mini_df, by = c("Var2" = "population")) %>%
  rename(Pop2 = full_name)


plotting_df$Pop1 <- factor(plotting_df$Pop1, levels = my_levels2)
plotting_df$Pop2 <- factor(plotting_df$Pop2, levels = my_levels2)

# Make a heatmap and visualize the FST values

heatmap_plot <- ggplot(data = plotting_df, aes(Pop1, Pop2, fill = weighted_fst)) +
  geom_raster() +
  geom_text(aes(label = weighted_fst), size = 3) +
  scale_fill_distiller(palette = "Spectral", na.value = "white") +
  theme_classic() +
  theme(axis.text.x = element_text(angle = 90, vjust = 1, size = 10, hjust = 1),
        axis.text.y = element_text(angle = 0, vjust = 1, size = 10, hjust = 1)) +
  ylab("Population A") +
  xlab("Population B") +
  labs(fill = expression(italic(F[ST]))) +
  coord_fixed() 

heatmap_plot

# save pdf to file

ggsave(OUTFILE, heatmap_plot)

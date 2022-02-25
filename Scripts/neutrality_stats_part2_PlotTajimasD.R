# Load libraries
library(tidyverse)
library(mgcv)

# Specify data directory and file names
BASEDIR <- "E:/Dropbox (MERLAB)/Eleni/postdoc_wgs/results/angsd/all_samples_maf0.05_miss_0.3/sfs"

# Specify suffix of filenames containing output of angsd Tajimas D calculations (ends in .thetasWindow.pestPG)
SUFFIX <- "*.thetasWindow.pestPG"

# Tab-delimited table that has refseq chrom name and simplified name ( Chr 1, etc.)
CHROMFILE <- "E:/Dropbox (MERLAB)/Eleni/postdoc_wgs/chrom_lookup_table.txt" 

# Full path to sampling location metadata
METAFILE <- "E:/Dropbox (MERLAB)/Eleni/postdoc_wgs/sample_metadata/mapping_metadata.txt" 

# Specify the basename of the outpt file (pdf)
#OUTFILE <- "NAME"

################################################################################
setwd(BASEDIR)

# Define headers for the input file
# The .pestPG file is a 14 column file (tab seperated). The first column contains information about the region. The second and third column is the reference name and the center of the window.We then have 5 different estimators of theta, these are: Watterson, pairwise, FuLi, fayH, L. And we have 5 different neutrality test statistics: Tajima's D, Fu&Li F's, Fu&Li's D, Fay's H, Zeng's E. The final column is the effetive number of sites with data in the window.If you don't have the ancestral states, you can still calculate the Watterson and Tajima theta, which means you can perform the Tajima's D neutrality test statistic. But this requires you to use the folded sfs. The output files will have the same format, but only the thetaW and thetaD, and tajimas D is meaningful

thetas.headers <- c("(indexStart,indexStop)(firstPos_withData,lastPos_withData)(WinStart,WinStop)", "Chr","WinCenter", "tW", "tP", "tF", "tH", "tL", "Tajima", "fuf", "fud", "fayh", "zeng", "nSites")


# Make a list of all files in the current directory that end with a specific suffix
FILENAMES <- Sys.glob(SUFFIX) #this is R's version of a wildcard
file_list <- as.list(FILENAMES)

# Read in all of the data
chrom_df <- read.table(CHROMFILE, header = TRUE)

meta_df <- read.delim(METAFILE, header = TRUE) 

# Specify the order of some factors in coord_df for plotting later
meta_df$pop <- factor(meta_df$pop, levels = meta_df$pop)
meta_df$location <- factor(meta_df$location, levels = meta_df$location)

POPLIST <- meta_df$pop


# Part 1: Create a concatenated dataframe and save it as a text file
# This part of the code is just parsing the angsd files, concatenating them, and adding some information that will make plotting easier. 

thetas_df <- file_list %>%
  set_names(nm = FILENAMES) %>%
  map_dfr(
    ~ read_delim(.x, skip = 1, col_types = cols(), col_names = thetas.headers, delim = "\t"),
    .id = "filename"
  )

head(thetas_df)

# Append information about simplified chromosome names (from RefSeq to numeric)

thetas_df <- thetas_df %>%
  filter(Chr %in% chrom_df$chr)

thetas_df <- left_join(thetas_df, chrom_df, by = c("Chr" = "chr"))
nCHR <- length(unique(thetas_df$Chr))

# Calculate the distance along chromosomes in Mb and get the population name from the original file name
thetas_df <- thetas_df %>%
  mutate(midpos_Mb = WinCenter/1000000) %>%
  mutate(Population = gsub(".theta.thetasWindow.pestPG", "", filename))

# Make the linkage_group column in the thetas_df into a factor with a specific order
thetas_df$linkage_group <- factor(thetas_df$linkage_group, levels = chrom_df$linkage_group)

# Filter the invariant sites based on Watterson's theta statistic (tW), and then
# correct theta estimators like nucleotide diversity by dividing "the sum of per-site pi by the number of variant and invariant sites in a given window": https://github.com/ANGSD/angsd/issues/329 
# Kick out windows that have less than 10,000 sites.

thetas_df <- thetas_df %>%
  filter(tW != 0) %>%
  filter(nSites > 10000) %>%
  mutate(tP_corrected = tP/nSites) %>%
  mutate(tW_corrected = tW/nSites)

# Add metadata to the thetas_df for plotting
thetas_df <- left_join(thetas_df, meta_df, by = c("Population" = "pop"))

# Plot the data
mycols <- c("#0D0887FF", "#D14E72FF", "#FA9E3BFF")
mylines <- rep(1,12)

# Look at a density plot of the distribution of sites
plot1 <- ggplot(data = thetas_df) +
  geom_density(aes(x = nSites, color = category, linetype = Population)) +
  scale_color_manual(values = mycols) +
  scale_linetype_manual(values = mylines , guide = "none") +
  theme_classic()

plot1

# Tajima's D

TajD_plot <- ggplot() +
  
  # Add dotted lines to mark inversion boundaries
  geom_vline(aes(xintercept = inversion1_start), thetas_df, linetype = 3, color = "darkgray", size = 1) +
  geom_vline(aes(xintercept = inversion1_stop), thetas_df, linetype = 3, color = "darkgray", size = 1) +
  geom_vline(aes(xintercept = inversion2_start), thetas_df, linetype = 3, color = "darkgray", size = 1) +
  geom_vline(aes(xintercept = inversion2_stop), thetas_df, linetype = 3, color = "darkgray", size = 1) +
  
  
  # plot Tajimas D
  geom_smooth(data = thetas_df, aes(x = midpos_Mb, y = Tajima, linetype = Population, color = category), 
             alpha = 0.4, size = 0.3, method = "gam", formula = y ~ s(x, bs = "cs")) +
  facet_wrap(~linkage_group) +
  theme_classic() +
  ylab("Tajima's D") +
  xlab("Chromosome position (Mb)") +
  
  # set tick mark spacing
  scale_x_continuous(breaks = c(0,15,30)) +
  scale_color_manual(values = mycols, name = "Spawn Group") +
  scale_linetype_manual(values = mylines, guide = "none")

TajD_plot


mod_gam1 <- gam(Tajima ~ s(midpos_Mb, bs = "cr"), data = thetas_df)
summary(mod_gam1)

# Tajima's D as point plot

TajD_points <- ggplot() +
  geom_point(data = thetas_df, aes(x = midpos_Mb, y = Tajima,  color = category), 
              alpha = 0.2, size = 0.2) +
  #geom_hline( yintercept = 0, color = "red") +
  facet_wrap(~linkage_group) +
  theme_classic() +
  ylab("Tajima's D") +
  xlab("Chromosome position (Mb)") +
  # set tick mark spacing
  #scale_y_continuous(breaks = c(0.0, 0.3)) +
  scale_x_continuous(breaks = c(0,15,30)) +
  scale_color_manual(values = mycols)

# Look at a density plot of Tajima's D
plot2 <- ggplot(data = thetas_df) +
  geom_density(aes(x = Tajima, color = category, linetype = Population)) +
  scale_color_manual(values = mycols) +
  scale_linetype_manual(values = mylines) +
  theme_classic()

plot2


# Nucleotide diversity

W_plot <- ggplot() +
  geom_smooth(data = thetas_df, aes(x = midpos_Mb, y = tW_corrected, linetype = Population, color = category), 
             alpha = 0.4, size = 0.4, method = "gam", formula = y ~ s(x, bs = "cs")) +
  facet_wrap(~linkage_group) +
  theme_classic() +
  ylab(expression(hat(theta[W]))) +
  xlab("Chromosome position (Mb)") +
  # set tick mark spacing
  #scale_y_continuous(breaks = c(0.0, 0.3)) +
  scale_x_continuous(breaks = c(0,15,30)) +
  scale_color_manual(values = mycols, name = "Spawn Group") +
  scale_linetype_manual(values = mylines, guide = "none")

W_plot

# Make a table of genome-wide summary statistics
thetas_df$Population <- factor(thetas_df$Population, levels = meta_df$pop)

summary_df <- thetas_df %>%
  group_by(Population) %>%
  summarise(mean(Tajima), mean(tW_corrected), sd(Tajima), sd(tW_corrected))


# Save the output

ggsave("plot_TajD_GeomSmooth.pdf", plot = TajD_plot, width = 10, height = 6, units = "in")


library(tidyverse)
library(RColorBrewer)


setwd("~/herring_postdoc/data/LD")
list.files()

FILENAME <- "all_samples_maf0.05_miss0.3.nuclear.ld.NC_045163.1.ldblock.mean.1000.txt"

ld_df <- read.delim(FILENAME)
head(ld_df)



# Triangle heatmap to visualize LD blocks
ggplot(ld_df, aes(Pos1, Pos2)) +
  theme_bw() +
  xlab('Position on LG (Mb)') +
  ylab('Position on LG (Mb)') +
  geom_tile(aes(fill = R2), color = 'white') +
  scale_fill_gradientn(colors = brewer.pal(7,"YlGnBu"), na.value = "grey90") +
  #scale_fill_gradient(low = 'grey95', high = 'darkblue', space = 'Lab') +
  theme(axis.text.x = element_text(angle = 90),
        axis.ticks = element_blank(),
        axis.line = element_blank(),
        panel.border = element_blank(),
        panel.grid.major = element_line(color = '#eeeeee'))

library(tidyverse)
library(RColorBrewer)
library(gtools)


setwd("~/herring_postdoc/data/LD")
list.files()

FILENAME <- "all_samples_maf0.05_miss0.3.nuclear.ld.NC_045163.1.ldblock.sampled.txt"

r <- read.table(FILENAME, header = FALSE, stringsAsFactors = FALSE,
                col.names = c("V1", "V2" ,"dist", "r2p", "D", "Dp", "r2"))

head(r)

r <- r %>% 
  separate(V1, c(NA,"snp1"), sep = ':',) %>%
  separate(V2, c(NA,"snp2"), sep = ':',) 

r$snp1 <- as.numeric(r$snp1)
r$snp2 <- as.numeric(r$snp2)

#id <- unique(mixedsort(c(r[,"snp1"],r[,"snp2"])))
#posStart <- head(id,1)
#posEnd <- tail(id,1)

head(r)

# Sort by vector name [z] then [x]
r_sorted <- r[with(r, order(snp1, snp2)),]
class(r_sorted$r2)

# Triangle heatmap to visualize LD blocks
(myplot <- ggplot(r_sorted, aes(snp1, snp2)) +
  theme_bw() +
  xlab('Position on LG (Mb)') +
  ylab('Position on LG (Mb)') +
  geom_tile(aes(fill = r2), width = 100000, height = 100000) +
  scale_fill_gradientn(colors = brewer.pal(7,"YlGnBu"), na.value = "grey90") +
  #scale_fill_gradient(low = 'grey95', high = 'darkblue', space = 'Lab') +
  theme(axis.text.x = element_text(angle = 90),
        axis.ticks = element_blank(),
        axis.line = element_blank(),
        panel.border = element_blank(),
        panel.grid.major = element_line(color = '#eeeeee')))

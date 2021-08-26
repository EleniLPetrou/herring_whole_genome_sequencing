# This R  script was written by Eleni Petrou on 20191003 using  "R version 3.6.1 (2019-07-05)"
# Its purpose is to make a map of sampling locations using GPS data

###########################################################
# Load R libraries

# Libraries
library(tidyverse)
library(ggrepel)
library(viridis)
library(lubridate)
library(grid)
library(cowplot)

# Specify directory names and file names
BASE_DIR <- "E:/Dropbox (MERLAB)/Eleni/postdoc"
META_DIR <- paste0(BASE_DIR, '/', 'sample_metadata')
OUT_DIR <- paste0(BASE_DIR, '/', 'plots')

IN_FILE <- "mapping_metadata_AK.txt"
OUT_FILE <- "map_sequenced_samples_AK.pdf"

###########################################################
# Read in your data frame with longitude, latitude, and other metadata.
my_data <- read.delim(paste0(META_DIR, '/', IN_FILE))
head(my_data)

# calculate the julian date
my_data$date <- as.Date(my_data$date, "%m/%d/%y%y")
head(my_data)

my_data <- my_data %>%
  mutate(julian_date = yday(date))

head(my_data)

# Get the world polygon and extract USA and Canada

USA <- map_data("world") %>% 
  filter(region=="USA")

Canada <- map_data("world") %>% 
  filter(region=="Canada")


Mexico<- map_data("world")%>% 
  filter(region=="Mexico")

###########################################################
# Make some plots

# set the breaks for your color ramp
mylabels = c("April","", "", "May")


plot1a <- ggplot() +
  geom_polygon(data = USA, aes(x=long, y = lat, group = group), fill=" grey47", alpha=0.3) +
  geom_polygon(data = Canada, aes(x=long, y = lat, group = group), fill=" grey17", alpha=0.3)+
  geom_point(data=my_data, aes(x= longitude, y= latitude, color= julian_date),
              size = 6, alpha = 0.8) +
  coord_map(xlim = c(-129, -137), ylim = c(55,59)) +
  labs(x = "Longitude", y = "Latitude") +
  geom_text_repel( data= my_data, aes(x=longitude, y=latitude, label= location), 
                  size= 6,
                   min.segment.length = 0,
                  segment.size = 1,
                  point.padding = 0.6) +
  scale_color_viridis(option="plasma", 
                      name="Spawning date", 
                      begin = 0.4, 
                      end = 0.9,
                      labels = mylabels) +
  theme(panel.background = element_rect(fill = "aliceblue"), 
      panel.grid.major = element_line(colour = NA), 
      axis.text=element_text(size=12),
      axis.title =element_text(size=14),
      legend.title=element_text(size=10),
      legend.text=element_text(size=10)) 

plot1a


# Make a little insert plot of North America

insert_map <- ggplot() +
  geom_polygon(data = USA, aes(x=long, y = lat, group = group), fill=" grey37", alpha=0.3) +
  geom_polygon(data = Canada, aes(x=long, y = lat, group = group), fill=" grey17", alpha=0.3) +
  geom_polygon(data = Mexico, aes(x=long, y = lat, group = group), fill=" grey17", alpha=0.3) +
  coord_map(xlim= c(-140, -55),  ylim = c(60,20))+
  theme(panel.background = element_rect(fill = "aliceblue"), 
        panel.grid.major = element_line(colour = NA), 
        axis.text = element_blank(),
        axis.title = element_blank(),
        axis.ticks = element_blank(),
        legend.title = element_text(size=11),
        legend.text = element_text(size=10))+
  annotate("rect", xmin = -127, xmax = -139, ymin = 54, ymax = 60, color = "black", alpha = 0, size = 1.5)

insert_map


# Plot with multiple panels

multiplot <- ggdraw() +
  draw_plot(plot1a, x = 0, y = 0.1, width = 0.8, height = 0.8) + #sampling locations
  draw_plot(insert_map, x = 0.68, y = 0.66, width = .24, height = .25) + #world map
  draw_plot_label(label = c("A", "B"), size = 14,
                  x = c(0.04, 0.67), y = c(0.95, 0.95))

multiplot


# Save plot to file

ggsave(OUT_FILE, plot = multiplot, path = OUT_DIR)



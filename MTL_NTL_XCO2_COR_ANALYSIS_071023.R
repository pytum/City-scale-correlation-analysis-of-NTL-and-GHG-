library(ggplot2)
library(ggpmisc)
library(ggpubr)
library(dplyr)

#big bounding box:

# lonmin -76, latmin 44,
# lonmax -71, latmin 44,
# lonmax -71, latmax 47,
# lonmin -76, latmax 47

#small bounding box:

#   lonmin -73.9966, latmin 45.3854
#   lonmax -73.4739, latmin 45.3854
#   lonmax -73.4739, latmax 45.7076
#   lonmin -73.9966, latmax 45.7076


#big bounding box:
#setwd("D:/Privat/Uni/Masterthesis/Data/correlation_analysis_210923")
#NTL_MTL=read.csv("ntl_210923.csv")

#small bounding box:
setwd("D:/Privat/Uni/Masterthesis/Data/cor_analysis_071023/")
#data=read.csv("MTL_NTL_small_boundingbox_071023_b.csv")

#big bounding box:
data=read.csv("xco2_ntl_191023_b.csv")


x = data$date_c
y = data$nW_c

p <- ggplot(data, aes(x, y)) +  
  geom_point() +
  theme_gray(base_size = 18)

p + geom_point() +
  stat_poly_line() +
  stat_poly_eq(use_label("eq")) +
  stat_poly_eq(label.y = 0.9) +
  geom_line(aes(group = 1), colour = "red") + 
  geom_smooth(aes(group = 1), linewidth = 2, method = "lm", se = FALSE) +
  labs(x = "Months (Sept 2015 - Nov 2022)", y = "nW/cm²/sr", 
       title = "Nighttimelights in MTL") +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),  # Set the angle to 45 degrees
        panel.border = element_blank(), 
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(), 
        axis.line = element_line(colour = "black"))


GHG_MTL=read.csv("xco2_210923.csv")

a = GHG_MTL$date
b = GHG_MTL$XCO2

ggplot(mpg, aes(x = hwy, y = cty, color = class)) +
  geom_point() +
  theme_gray(base_size = 18)

p2 <- ggplot(GHG_MTL, aes(a, b))+
  geom_point() +
  theme_gray(base_size = 18)

p2 + geom_point() +
  stat_poly_line() +
  stat_poly_eq(use_label("eq")) +
  stat_poly_eq(label.y = 0.9) +
  geom_line(aes(group = 1), colour = "red") + 
  geom_smooth(aes(group = 1), linewidth = 2, method = "lm", se = FALSE) +
  labs(x = "Months (Jan 2014 - Jan 2022)", y = "XCO2 monthly mean", 
       title = "XCO2 monthly mean in MTL") +
  theme(axis.text.x=element_blank()) + theme(panel.border = element_blank(), panel.grid.major = element_blank(),
                                             panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

c = cor.test(data$nW_c, data$XCO2_c,method="pearson")
c

ggscatter(data, x = "XCO2_c", y = "nW_c", 
          add = "reg.line", conf.int = TRUE, 
          add.params = list(color = "blue",
                            fill = "lightgray"),
          cor.coef = TRUE, cor.method = "pearson",
          xlab = "XCO2 (ppm)", ylab = "NTL (nW)")

growth_rate = data %>%
  # first sort by year
  arrange(date) %>%
  mutate(Diff_date = data$date - lag(data$date),  # Difference in time (just in case there are gaps)
         Diff_growth = data$XCO2 - lag(data$XCO2), # Difference in route between years
         Rate_percent = (Diff_growth / Diff_date)/route * 100) # growth rate in percent

Average_growth = mean(growth_rate$Rate_percent, na.rm = TRUE)

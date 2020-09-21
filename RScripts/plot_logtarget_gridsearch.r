# plot target density from grid search

target <- readRDS("../results/gridsearch_2020-07-08")

griddim = 25
gseq = seq(1e-1, 3.49, length.out=griddim)
phi0seq = seq(1.5, 14, length.out = griddim)
Mseq = seq(1e5, 1.5e5, length.out = griddim)
rhseq = seq(1e-2, 30, length.out = griddim)

pargrid = expand.grid(g = gseq, phi0 = phi0seq, M = Mseq, rh = rhseq)

pargrid$target = target

# replace -Inf with NAs for plotting purposes
pargrid$target <- na_if(x = pargrid$target, y = -Inf)

library(ggplot2)

library(dplyr)

conditional = mutate(pargrid, gbin = ggplot2::cut_interval(x = pargrid$g, n = 5) ) %>% 
  mutate(phi0bin = ggplot2::cut_interval(x = pargrid$phi0, n=5)) %>%
    group_by(M, rh, gbin, phi0bin) %>%
      summarize(target = mean(target, na.rm = TRUE)) 


# Base Plot
g <- ggplot(conditional, aes(x=rh, y=M, fill=target)) + 
  geom_raster()

pdf("../results/log_target_LIMEPYin_LIMEPYandPRIORSout.pdf")

g + facet_grid( gbin ~ phi0bin ) + labs(title="Total Mass vs half-light radius", caption = "LIMEPY data, LIMPEY model", subtitle="log target density") + theme_bw() + theme(strip.text = element_text(size = 14), text = element_text(size=14), panel.grid.major = element_blank(), panel.grid.minor = element_blank()) 

dev.off()
  



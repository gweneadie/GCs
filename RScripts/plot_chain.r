# read in results

results = readRDS(file = paste("../results/prelim_mcmc_truncnorm-rh-prior_normin", nsamp, Sys.Date(), sep="_") )

# plot the posterior distribution
plot(results$chain)


# 

# density of total mass
plot( density( results$chain[,4]), xlab=expression(M[total]), main="Marginal Distribution", cex.lab=2, cex.axis=2)
grid()
abline(v=1e5, lty=2)

plot( density( rnorm(5e3, mean = 10^5, sd=0.6)), col="blue", lty=3)

lines(density( results$chain[,4]) )
summary(results$chain)


plot()

source("function_pairsplot.r")
library(coda)
chain <- readRDS(file = "../results/paper1results/RegenCompact/chain_limepy_subsamp500_m5r3g1.5phi3.0_9_2020-12-02.rds")

plot(as.mcmc(chain$chain))

summary(chain$chain)

plotposterior(filename = "../results/paper1results/chain_limepy_m5r3g1.5phi5.0_0_2020-11-02_2020-11-03.rds", makepdf = FALSE, n=2 )
plotposterior(filename = "../results/paper1results/RegenCompact/chain_limepy_subsamp500_m5r3g1.5phi3.0_9_2020-12-02.rds", makepdf = FALSE, n=2 )

#making contour plots
Chain_gphimr<- data.frame(chain$chain)
View(Chain_gphimr)
a<- ggplot(Chain_gphimr, aes(r_h,M)) +geom_point(alpha=0.5)  
a+ stat_density_2d(aes(fill = stat(nlevel)), geom = "polygon") + scale_fill_viridis_c()




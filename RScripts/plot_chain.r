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
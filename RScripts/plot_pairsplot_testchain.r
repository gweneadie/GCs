library(ggplot2)
library(RColorBrewer)

test = runanother$chain
plotn = seq(1, nrow(test), by=10)

pairs(test[plotn, ], col=rev(heat.colors(nrow(test[plotn, ]))) )

pdf(file = paste("../results/prelim_mcmc_NOrmin_", Sys.Date(), ".pdf", sep=""))

pairs(test[plotn, ], col=rgb(0.3,0.5,0.8, 0.2), pch=19, cex.labels = 6, cex.axis = 1.3)


dev.off()

pdf(file = paste("../results/traceplots_narrow-rh-prior_rmin0_", Sys.Date(), ".pdf", sep=""))
plot(as.mcmc(test[plotn, ]))
dev.off()

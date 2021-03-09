# read a mass profile file
allmassprofiles <- readRDS('../results/paper1results/RegenAll/massprofiles_chain_limepy_subsamp500_m5r3g1.5phi5.0_2_2020-11-10_2021-03-04.rds')

# max M for plotting
library(dplyr)
bigmassdataframe <- bind_rows(allmassprofiles, .id = "column_label")
maxM <- max(bigmassdataframe$mass)
maxr <- max(allmassprofiles[[1]]$r)

# plot these
# png(filename = paste0("../results/Figures/mass_profile_", Sys.Date(), ".png"), width = 900)

par(mar=c(5,6,2,2))
plot(allmassprofiles[[1]]$r, allmassprofiles[[1]]$mass, type="l", xlab="r (pc)", ylab=expression(M(r<R)~(M['\u0298'])), cex.lab=2.5, cex.axis=2, xlim = c(0,maxr), ylim=c(0,maxM))
grid()
lapply(X = allmassprofiles, FUN = function(X) lines(X$r, X$mass, col=rgb(0,0,0,0.01)) )

abline(h=median(target$chain[,3]), col="blue", lty=2)

abline(h=truepars[3], col="darkgreen", lty=3, lwd=3)
# lines(truemodel$r, truemodel$mc, col="red", lwd=2)

lines(altmodel$r, altmodel$mc, col="red", lwd=2)

legend("bottomright", lty=c(1,1,2,2), lwd=c(1, 1.5, 2,3), legend = c("posterior profiles", "true profile", "median mass estimate", "true total mass"), col=c("black", "red", "blue", "darkgreen"))
dev.off()
# script to plot mass profiles with credible regions

library(tidyverse)
source("function_profiles.r")
# folder
folder <- "ExtendedGC/subsamp500_inner/"

filenamelist <- list.files(path = paste0("../results/paper1results/", folder), pattern = "massprofile")

filename <- strsplit(filenamelist, split = ".rds")[[1]]

library(stringr)
# take filename and split up by _ separaters to get parameter info ### NOTE TO SELF: MAKE THIS EASIER NEXT TIME BY SAVING THE TRUE PARS IN THE DATA FILE!!!
temp <- strsplit(filename, "_")[[1]][5]
parnums <- str_extract_all(temp, "\\d")[[1]]
truepars = as.numeric( c( paste0(parnums[3], ".", parnums[4]), paste0(parnums[5], ".", parnums[6]), paste0("1e", parnums[1]), parnums[2] ) )


# load the mass profiles for this particular GC
allmassprofiles <- readRDS(paste0("../results/paper1results/", folder, filenamelist))

# max M for plotting
bigmassdataframe <- bind_rows(allmassprofiles, .id = "column_label")
maxM <- max(bigmassdataframe$mass)
maxr=15

# true model mass profile
truemodel <- limepy$limepy(g=truepars[1], phi0=truepars[2], M=truepars[3], rh=truepars[4])

# plot these
png(paste0("../Figures/", filename, ".png"), res = 300, width = 2500, height=1500 )

par(mar=c(5,7,2,2))
plot(allmassprofiles[[1]]$r, allmassprofiles[[1]]$mass, xlab="r (pc)", ylab=expression(M(r<R)~(M['\u2609'])), xlim = c(0,maxr), ylim=c(0,maxM), yaxt="n", xaxt="n", type="n", main=folder)

axis(side = 1, at=0:15)
axis(side = 2, las=1, at = seq(0,1e5, length.out = 5))

grid()

lapply(X = allmassprofiles, FUN = function(X) lines(X$r, X$mass, col=rgb(0,0,0,0.008)) )

#abline(h=median(results$chain[,3]), col="blue", lty=2)

abline(h=truepars[3], col="darkgreen", lty=3, lwd=3)
lines(truemodel$r, truemodel$mc, col="red", lwd=2)

# lines(altmodel$r, altmodel$mc, col="red", lwd=2)

legend("bottomright", lty=c(1,1,2), lwd=c(1, 1.5, 3), legend = c("posterior profiles", "true profile", "true total mass"), col=c("black", "red", "darkgreen"))


dev.off()

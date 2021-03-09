# read a mass profile file
foldertype <- "RegenAll"

# grab filename
filename <- list.files(path = paste0("../results/paper1results/", foldertype, "/"), pattern = "massprofiles_chain_limepy_")

allmassprofiles <- readRDS(paste0('../results/paper1results/', foldertype, "/", filename))

# max M for plotting
library(dplyr)
bigmassdataframe <- bind_rows(allmassprofiles, .id = "column_label")
maxM <- max(bigmassdataframe$mass)
maxr <- max(allmassprofiles[[1]]$r)


library(stringr)
# take filename and split up by _ separaters to get parameter info ### NOTE TO SELF: MAKE THIS EASIER NEXT TIME BY SAVING THE TRUE PARS IN THE DATA FILE!!!
temp <- strsplit(filename, "_")[[1]][5]
parnums <- str_extract_all(temp, "\\d")[[1]]
truepars = as.numeric( c( paste0(parnums[3], ".", parnums[4]), paste0(parnums[5], ".", parnums[6]), paste0("1e", parnums[1]), parnums[2] ) )

# get important part of filename for saving
gcIDpart <- strsplit(filename, ".rds")[[1]]


png(filename = paste0("../Figures/", gcIDpart, "_", Sys.Date(), ".png"), width = 900)

par(mar=c(5,6,2,2))
plot(allmassprofiles[[1]]$r, allmassprofiles[[1]]$mass, type="l", xlab="r (pc)", ylab=expression(M(r<R)~(M['\u0298'])), cex.lab=2.5, cex.axis=2, xlim = c(0,maxr), ylim=c(0,maxM), main = foldertype)
grid()
lapply(X = allmassprofiles, FUN = function(X) lines(X$r, X$mass, col=rgb(0,0,0,0.01)))

# abline(h=median(target$chain[,3]), col="blue", lty=2)

abline(h=truepars[3], col="green", lty=3, lwd=3)
# lines(truemodel$r, truemodel$mc, col="red", lwd=2)

lines(altmodel$r, altmodel$mc, col="red", lwd=2)

legend("bottomright", lty=c(1,1,2,2), lwd=c(1, 1.5, 2,3), legend = c("posterior profiles", "true profile", "median mass estimate", "true total mass"), col=c("black", "red", "blue", "darkgreen"))
dev.off()

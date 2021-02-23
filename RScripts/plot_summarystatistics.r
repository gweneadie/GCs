library(coda)

foldername = "CompactGC/subsamp500_outer/"
mypath = paste0("../results/paper1results/", foldername)

# get summary statistics
summaryfilename <- list.files(mypath, pattern = "summarystatistics")
summarylist <- readRDS(paste0(mypath, summaryfilename))
df <- summarylist$dfsummaries
truepars <- summarylist$truepars

gwithin <- summarylist$within[1]
Phi0within <- summarylist$within[2]
Mwithin <- summarylist$within[3]
rwithin<- summarylist$within[4]

rm(summarylist)

# function to plot quantiles
source("function_plotquantiles.R")

# sequence 1 to 50 for plotting
y <- 1:50
# expansion factor
xfactor = 1.2



pdf(paste0("../Figures/", foldername, "_limepy_subsamp500_interquartiles_", Sys.Date(), ".pdf"), width=9, height=7, useDingbats = FALSE)

# set up plotting area
par(mfrow=c(1,4))

par(mar=c(5,5,2,0))
# g
with(df, plot(Mean[Parameter=="g"], y, type="n", panel.first = TRUE, xlab = "g", cex.lab=xfactor, cex.axis=xfactor, ylab="GC id", yaxt="n",
              xlim = c(truepars["g"]-1, truepars["g"]+1), main = bquote("within interquartile"~.(gwithin)/50) ))
axis(side = 2, at = y, labels=y)
grid()
abline(v=truepars["g"], col="blue")
with(df, points(df$Mean[Parameter=="g"], y) )
quants(df, parameter="g", length=0.1)

# Phi_0

par(mar=c(5,2,2,2))

with(df, plot(Mean[Parameter=="Phi_0"], y, type="n", panel.first = TRUE, xlab = expression(Phi[0]), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n",
              xlim = c(0, truepars["Phi_0"]+1.75), main = bquote("within interquartile"~.(Phi0within)/50) ))
grid()

abline(v=truepars["Phi_0"], col="blue")
with(df, points(df$Mean[Parameter=="Phi_0"], y) )
quants(df, parameter="Phi_0", length=0.1)

# M
par(mar=c(5,2,2,2))

with(df, plot(Mean[Parameter=="M"], y, type="n", panel.first = TRUE, xlab = expression(M[total]~(10^5~M['\u0298'])), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n", xaxt="n",
              xlim = c( min(Mean[Parameter=="M"]),  max(Mean[Parameter=="M"])), main = bquote("within interquartile"~.(Mwithin)/50)) )
grid()
axis(side = 1, at=seq(9e4,11e4, length.out = 5), labels = c(0.9, 0.95, 1.0, 1.05, 1.1))
abline(v=truepars["M"], col="blue")
with(df, points(df$Mean[Parameter=="M"], y) )
quants(df, parameter="M", length=0.1)

# rh
par(mar=c(5,2,2,2))

with(df, plot(Mean[Parameter=="r_h"], y, type="n", panel.first = TRUE, xlab = expression(r[h]~(pc)), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n",
              xlim = c( min(Mean[Parameter=="r_h"]), max(Mean[Parameter=="r_h"])), main = bquote("within interquartile"~.(rwithin)/50)) )
grid()

abline(v=truepars["r_h"], col="blue")
with(df, points(df$Mean[Parameter=="r_h"], y) )
quants(df, parameter="r_h", length=0.1)

dev.off()






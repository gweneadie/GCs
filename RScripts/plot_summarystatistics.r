library(coda)

foldername = "Regen_lowPhi0"
mypath = paste0("../results/paper1results/", foldername, "/")

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

# function to get limits for plotting, to automate for each file
xrange <- function(param, dframe=df, truep=truepars){

  truep = truep[param]
  
  out = c(0.85*truep, 1.15*truep)
  if( any( dframe$X25.[dframe$Parameter==param]<out[1] ) ){ out[1] =  min( dframe$X25.[dframe$Parameter==param] ) }
  if( any( dframe$X75.[dframe$Parameter==param]>out[2] ) ){ out[2] = max( dframe$X75.[dframe$Parameter==param] ) }
  
  out
}


pdf(paste0("../Figures/", foldername, "_limepy_subsamp500_interquartiles_", Sys.Date(), ".pdf"), width=9, height=7, useDingbats = FALSE)

# set up plotting area
par(mfrow=c(1,4), oma=c(0,0,5,0))

par(mar=c(5,5,2,0))


with(df, plot(Mean[Parameter=="g"], y, type="n", panel.first = TRUE, xlab = "g", cex.lab=xfactor, cex.axis=xfactor, ylab="GC id", yaxt="n",
              xlim = xrange(param="g"), main = bquote("within interquartile"~.(gwithin)/50) ))
title(main = foldername, outer = TRUE)
axis(side = 2, at = y, labels=y)
grid()
abline(v=truepars["g"], col="blue")
with(df, points(df$Mean[Parameter=="g"], y) )
quants(df, parameter="g", length=0.1)

# Phi_0

par(mar=c(5,2,2,2))

with(df, plot(Mean[Parameter=="Phi_0"], y, type="n", panel.first = TRUE, xlab = expression(Phi[0]), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n", xlim = xrange("Phi_0"), main = bquote("within interquartile"~.(Phi0within)/50) ))
grid()

abline(v=truepars["Phi_0"], col="blue")
with(df, points(df$Mean[Parameter=="Phi_0"], y) )
quants(df, parameter="Phi_0", length=0.1)

# M
par(mar=c(5,2,2,2))

with(df, plot(Mean[Parameter=="M"], y, type="n", panel.first = TRUE, xlab = expression(M[total]~(M['\u0298'])), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n", xaxt="n", xlim = xrange("M"), main = bquote("within interquartile"~.(Mwithin)/50)) )
grid()
axis(side=1)
abline(v=truepars["M"], col="blue")
with(df, points(df$Mean[Parameter=="M"], y) )
quants(df, parameter="M", length=0.1)

# rh
par(mar=c(5,2,2,2))

with(df, plot(Mean[Parameter=="r_h"], y, type="n", panel.first = TRUE, xlab = expression(r[h]~(pc)), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n", xlim = xrange("r_h"), main = bquote("within interquartile"~.(rwithin)/50)) )
grid()

abline(v=truepars["r_h"], col="blue")
with(df, points(df$Mean[Parameter=="r_h"], y) )
quants(df, parameter="r_h", length=0.1)

dev.off()






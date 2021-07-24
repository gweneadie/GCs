library(coda)
library(Cairo)

# make a vector of the folders in the order that you want them plotted
resultsfolders <- c("CompactGC/subsamp500_outer/", "CompactGC/subsamp500_inner/",
                    "RegenOutsideCore/", "RegenInsideCore/",
                    "ExtendedGC/subsamp500_outer/", "ExtendedGC/subsamp500_inner/",
                    "Regen_highPhi0/subsamp500_outer/", "Regen_highPhi0/subsamp500_inner/",
                    "Regen_lowPhi0/subsamp500_outer/", "Regen_lowPhi0/subsamp500_inner/")

mockdatafolders <- c("CompactGC/subsamp500_outer/", "CompactGC/subsamp500_inner/",
                     "RegenAll/subsamp500_outsidecore/", "RegenAll/subsamp500_insidecore/",
                     "ExtendedGC/subsamp500_outer/", "ExtendedGC/subsamp500_inner/",
                     "Regen_highPhi0/subsamp500_outer/", "Regen_highPhi0/subsamp500_inner/",
                     "Regen_lowPhi0/subsamp500_outer/", "Regen_lowPhi0/subsamp500_inner/")

outin <- c("stars sampled outside core", "stars sampled inside core")

plottitles <- c(paste0("Compact GCs, ", outin),
                paste0("Average GCs, ", outin),
                paste0("Extended GCs, ", outin),
                paste0("High ", expression(Phi[0]), ", ", outin),
                paste0("Low ", expression(Phi[0]), ", ", outin))
                    
whichone <- 7  

foldername = resultsfolders[whichone]
title = plottitles[whichone]

# if you want to set ranges explicitly
grange = c(0,3)
Phi0range = c(1,8)
Mrange = c(0.9, 1.3)
rhrange  =c(0, 6) # need to change for each type of cluster if using this

# plot 50% or 95%??
# thisquant <- c("X25.", "X75.")
thisquant <- c("X2.5.", "X97.5.")

mypath = paste0("../results/paper1results/", foldername, "/")

# get summary statistics
summaryfilename <- list.files(mypath, pattern = "summarystatistics")
summarylist <- readRDS(paste0(mypath, summaryfilename))
df <- summarylist$dfsummaries
truepars <- summarylist$truepars

# name depending on thisquant
if( all(thisquant== c("X25.", "X75.")) ){
  quantname = "50credint"
  
  # use this if you want to plot 50%
  gwithin <- summarylist$within[1]
  Phi0within <- summarylist$within[2]
  Mwithin <- summarylist$within[3]
  rwithin<- summarylist$within[4]
  
  }else{ # this is the default
    
  quantname = "95credint"
  # use this if you want to plot 95%
  gwithin <- summarylist$within95[1]
  Phi0within <- summarylist$within95[2]
  Mwithin <- summarylist$within95[3]
  rwithin <- summarylist$within95[4]
  
}



rm(summarylist)

# function to plot quantiles
source("function_plotquantiles.R")

# sequence 1 to 50 for plotting
y <- 1:50
# expansion factor
xfactor = 1.2

# function to get limits for plotting, to automate for each file
xrange <- function(param, dframe=df, truep=truepars, interval = c("X25.", "X75.")){

  truep = truep[param]
  
  out = c(0.85*truep, 1.15*truep)
  if( any( (dframe[interval[1]])[dframe$Parameter==param, 1]<out[1] ) ){ out[1] =  min( dframe[interval[1]][dframe$Parameter==param, 1] ) }
  if( any( dframe[interval[2]][dframe$Parameter==param, 1]>out[2] ) ){ out[2] = max( dframe[interval[2]][dframe$Parameter==param, 1] ) }
  
  out
}


######### plot the quantiles for every GC ##############
pdf(paste0("../Figures/", foldername, "_limepy_subsamp500_", quantname, "_", Sys.Date(), ".pdf"), width=9, height=7)


# set up plotting area
par(oma=c(5,5,5,3), mai=c(0,0,0,0), cex.lab=xfactor, cex.axis=xfactor)

layout(mat = matrix(c(1,2,3,4), nrow = 1, byrow = TRUE))

par(mar=c(0,1.5,3,0))


with(df, plot(Mean[Parameter=="g"], y,
              type="n", panel.first = TRUE,
              xlab = "g", cex.lab=xfactor, cex.axis=xfactor, yaxt="n",
              # xlim = xrange(param="g",interval = thisquant), 
              xlim = grange,
              main = bquote(.(gwithin)/50) ))

mtext(text = "GC ID", side = 2, outer = TRUE, line = 3)

if( foldername=="Regen_highPhi0"){
  title(expression("High"~Phi[0]~" GCs, stars randomly sampled"), outer = TRUE, line = -0.05)
}else{
  if( foldername=="Regen_lowPhi0" ){
    title(expression("Low"~Phi[0]~" GCs, stars randomly sampled"), outer = TRUE, line = -0.05)
  }else{
    title(main = plottitle, outer = TRUE, line = -0.05)
  }
}

axis(side = 2, at = y, labels=y)
grid()
abline(v=truepars["g"], col="blue")
with(df, points(df$Mean[Parameter=="g"], y) )
quants(df, parameter="g", length=0.1, quantiles = thisquant)

# Phi_0

# par(mar=c(5,2,2,2))

with(df, plot(Mean[Parameter=="Phi_0"], y, type="n", panel.first = TRUE, xlab = expression(Phi[0]), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n", 
              # xlim = xrange("Phi_0", interval = thisquant), 
              xlim = Phi0range,
              main = bquote(.(Phi0within)/50) ))
grid()

abline(v=truepars["Phi_0"], col="blue")
with(df, points(df$Mean[Parameter=="Phi_0"], y) )
quants(df, parameter="Phi_0", length=0.1, quantiles = thisquant)

# M
# par(mar=c(5,2,2,2))

with(df, plot(Mean[Parameter=="M"]/1e5, y, type="n", panel.first = TRUE, xlab = expression(M[total]~(10^5~M["sun"])), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n", xaxt="n", 
              # xlim = xrange("M", interval = thisquant), 
              xlim = Mrange,
              main = bquote(.(Mwithin)/50)) )
grid()
axis(side=1)
abline(v=truepars["M"], col="blue")
with(df, points(df$Mean[Parameter=="M"], y) )
quants(df, parameter="M", length=0.1, quantiles = thisquant)

# rh
# par(mar=c(5,2,2,2))

with(df, plot(Mean[Parameter=="r_h"], y, type="n", panel.first = TRUE, xlab = expression(r[h]~(pc)), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n", 
              # xlim = xrange("r_h", interval = thisquant), 
              xlim = rhrange,
              main = bquote(.(rwithin)/50)) )
grid()

abline(v=truepars["r_h"], col="blue")
with(df, points(df$Mean[Parameter=="r_h"], y) )
quants(df, parameter="r_h", length=0.1, quantiles = thisquant)

dev.off()






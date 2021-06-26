library(coda)
library(Cairo)

foldername = "Regen_lowPhi0"
plottitle = "____ GCs, stars randomly sampled"
# if you want to set ranges explicitly
grange = c(1,2)
Phi0range = c(1,4)
Mrange = c(9e4, 1.1e5)
rhrange  =c(2, 4) # need to change for each type of cluster if using this

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


# pdf(paste0("../Figures/", foldername, "_limepy_subsamp500_interquartiles_", Sys.Date(), ".pdf"), width=9, height=7)

windowsFonts(SolarSymbol = windowsFont("Arial Unicode MS"))

pdf(paste0("../Figures/", foldername, "_limepy_subsamp500_", quantname, "_", Sys.Date(), ".pdf"), width=9, height=7, family="SolarSymbol")


# set up plotting area
par(mfrow=c(1,4), oma=c(0,0,5,0))

par(mar=c(5,5,2,0))


with(df, plot(Mean[Parameter=="g"], y, type="n", panel.first = TRUE, xlab = "g", cex.lab=xfactor, cex.axis=xfactor, ylab="GC id", yaxt="n",
              # xlim = xrange(param="g",interval = thisquant), 
              xlim = grange,
              main = bquote(.(gwithin)/50) ))

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

par(mar=c(5,2,2,2))

with(df, plot(Mean[Parameter=="Phi_0"], y, type="n", panel.first = TRUE, xlab = expression(Phi[0]), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n", 
              # xlim = xrange("Phi_0", interval = thisquant), 
              xlim = Phi0range,
              main = bquote(.(Phi0within)/50) ))
grid()

abline(v=truepars["Phi_0"], col="blue")
with(df, points(df$Mean[Parameter=="Phi_0"], y) )
quants(df, parameter="Phi_0", length=0.1, quantiles = thisquant)

# M
par(mar=c(5,2,2,2))

with(df, plot(Mean[Parameter=="M"], y, type="n", panel.first = TRUE, xlab = expression(M[total]~(M["?"])), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n", xaxt="n", 
              # xlim = xrange("M", interval = thisquant), 
              xlim = Mrange,
              main = bquote(.(Mwithin)/50)) )
grid()
axis(side=1)
abline(v=truepars["M"], col="blue")
with(df, points(df$Mean[Parameter=="M"], y) )
quants(df, parameter="M", length=0.1, quantiles = thisquant)

# rh
par(mar=c(5,2,2,2))

with(df, plot(Mean[Parameter=="r_h"], y, type="n", panel.first = TRUE, xlab = expression(r[h]~(pc)), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n", 
              # xlim = xrange("r_h", interval = thisquant), 
              xlim = rhrange,
              main = bquote(.(rwithin)/50)) )
grid()

abline(v=truepars["r_h"], col="blue")
with(df, points(df$Mean[Parameter=="r_h"], y) )
quants(df, parameter="r_h", length=0.1, quantiles = thisquant)

dev.off()






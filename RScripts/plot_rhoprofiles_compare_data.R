source("function_logLike_LIMEPY.r")
source("function_profiles.r")

# one sample GC results to make example CMP
j=13

# r range for each type of GC
xrangeplot = list(c(0.15,8), c(0.1,3), c(0.15,10), c(0.1,5), c(0.1,10))
yrangeplot = list(c(0,3500), c(0,1.25e5), c(0,150), c(0,5e4), c(0,2e3))
xrange = list(c(0,20), c(0,9), c(0,45), c(0,40), c(c(0,16)))

# custom r sequence for plotting
rseq = lapply(xrange, FUN = function(x) seq(from=x[1], to=x[2], length.out=1e2))

regions=c(0.5, 0.75, 0.95)
# credible region bounds
drop.perc = (1 - regions)/2

# colours for credible region bounds and true mass profile
solids = c("cadetblue1", "cadetblue3", "cadetblue4")
truecol = "red"

# labels for plots and legends
myylab = c(expression(rho(r)), "", "", expression(rho(r)), "")
myxlab="r (pc)"
mymar = c(5,7,0.5,5)
myexp=1.35
mylegend = c(paste0(regions*100, "% c.r."))

# make a vector of the folders in the order that you want them plotted
resultsfoldersRandom <- c("RegenAll/",
                          "RegenCompact/",
                          "RegenExtended/",
                          "Regen_highPhi0/",
                          "Regen_lowPhi0/")

# mock data folders
mockdatafolders <- c("RegenAll/subsamp500_random/", 
                     "CompactGC/subsamp500/",
                     "ExtendedGC/subsamp500/",
                     "Regen_highPhi0/subsamp500/",
                     "Regen_lowPhi0/subsamp500/")

# plot titles
plotTitle <- c("Average", "Compact", "Extended", expression("High"~Phi[0]), expression("Low"~Phi[0]))


png(filename = paste0("../Figures/rhoprofiles_", Sys.Date(), ".png"), width=9.5, height=7, res=300, units="in")

layout(mat = matrix(c(1,1,2,2,3,3,
                      0,4,4,5,5,0), nrow = 2, byrow = TRUE))

# set up the outer margins, inner margins, grid, etc.
par(oma=c(0,4,3,3), mai=c(1,0.75,0,0), cex.lab=myexp, cex.axis=myexp)

for(i in 1:length(resultsfoldersRandom)){
  
  # grab folder name and path
  foldername = resultsfoldersRandom[i]
  mypath = paste0("../results/paper1results/", foldername)
  
  # load file that contains all mass profiles from chains and limepy
  filename <- list.files(path = mypath, pattern = "^rhoprofile")
  
  allrhoprofiles <- readRDS(paste0(mypath, filename))
  
  # load the particular data set used
  mockdatafilename <- list.files(path = paste0("../mockdata/paper1data/", mockdatafolders[i]))[j]
  mydata <- readRDS(paste0("../mockdata/paper1data/", mockdatafolders[i], mockdatafilename))
  
  # calculate Bayesian credible regions
  temp = rhocredreg(rhos = allrhoprofiles, r.values = rseq[[i]])

  # split into lower and upper creds
  lower.creds <- temp[, 1:(ncol(temp)/2)]
  upper.creds <- temp[, rev((ncol(temp)/2+1):ncol(temp)) ] #put in reverse so columns line up properly with lower.creds
  
  # load the true parameter values
  truepars <- readRDS(paste0("../results/paper1results/", resultsfoldersRandom[i], "truepars.rds"))
  # convert mass to units of 10^5
  truepars["M"] <- truepars["M"]/1e5
  
  # calculate true model and add to plot true model mass profile
  truemodel <- limepy$limepy(g=truepars[1], phi0=truepars[2], M=truepars[3], rh=truepars[4])
  
  # r values for drawing cred. region bounds (pass to polygon)
  poly.r = c(rseq[[i]], rev(rseq[[i]]) )
  
  # credible bound M(r) values for plotting (pass to polygon)
  polyRho = rbind( lower.creds, upper.creds[ nrow(upper.creds):1 , ] )
  
  # r values for plotting
  rs = c(rseq[[i]], rev(rseq[[i]]))
  Rhos = rep(0, length(rseq[[i]]))
  
  p = plot(rseq[[i]], (Rhos), type="n",
           xlab = myxlab, ylab=myylab[i], main = "",
           ylim=yrangeplot[[i]],
           xlim=xrangeplot[[i]], 
           # log="x",
           cex.lab=myexp)
  #add a background grid
  grid()
  
  mtext(text = plotTitle[i], side = 3, line=1)
  
  # add credible regions
  for( k in 1:length(regions) ){
    polygon(x=rs, y=polyRho[,k], col=solids[k], border=solids[k]) 
  }
  
    grid()
  lines(truemodel$r, truemodel$rho, col=truecol, lwd=1.5)
  
  # add the real data along the bottom
  rug(mydata$r[mydata$r<(xrangeplot[[i]])], col=rgb(0,0,0))
  
  # if it's the last plot, then add a legend
  if(i==1){
    legend("topright", legend = c(mylegend, "true profile"), col=c(solids, truecol), lty=1, lwd=2, bg = "white")
  }
  
  box()
}

dev.off()

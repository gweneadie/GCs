source("function_logLike_LIMEPY.r")
source("function_profiles.r")

# one sample GC results to make example CMP
j=13

# r range for each type of GC
xrangeplot = list(c(0,20), c(0,9), c(0,45), c(0,40), c(c(0,16)))
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
myylab = c(expression(M(r<R)~(10^5~M["sun"])), "", "", expression(M(r<R)~(10^5~M["sun"]), "") )
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
# plot titles
plotTitle <- c("Average", "Compact", "Extended", expression("High"~Phi[0]), expression("Low"~Phi[0]))

# make a vector of the folders in the order that you want them plotted
resultsfoldersBiased <- c("CompactGC/subsamp500_outer/", "CompactGC/subsamp500_inner/",
                          "RegenOutsideCore/", "RegenInsideCore/",
                          "ExtendedGC/subsamp500_outer/", "ExtendedGC/subsamp500_inner/",
                          "Regen_highPhi0/subsamp500_outer/", "Regen_highPhi0/subsamp500_inner/",
                          "Regen_lowPhi0/subsamp500_outer/", "Regen_lowPhi0/subsamp500_inner/")


mockdatafolders <- c("RegenAll/subsamp500_random/", 
                     "CompactGC/subsamp500/", 
                     "ExtendedGC/subsamp500/",
                     "Regen_highPhi0/subsamp500/",
                     "Regen_lowPhi0/subsamp500/")

png(filename = paste0("../Figures/CMPs_randomsampling_", Sys.Date(), ".png"), res=300, width = 9.5, height = 7, units = "in")

layout(mat = matrix(c(1,1,2,2,3,3,
                      0,4,4,5,5,0), nrow = 2, byrow = TRUE))

# set up the outer margins, inner margins, grid, etc.
par(oma=c(0,4,3,3), mai=c(1,0.75,0,0), cex.lab=myexp, cex.axis=myexp)

for(i in 1:length(resultsfoldersRandom)){
  
  # grab folder name and path
  foldername = resultsfoldersRandom[i]
  mypath = paste0("../results/paper1results/", foldername)
 
  # load file that contains all mass profiles from chains and limepy
  filename <- list.files(path = mypath, pattern = "^massprofile")

  allmassprofiles <- readRDS(paste0(mypath, filename))

  # calculate Bayesian credible regions
  temp = CMPcredreg(CMPs = allmassprofiles, r.values = rseq[[i]])
  # change to units of 10^5 Msun
  temp = temp/1e5
  
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
  polyM = rbind( lower.creds, upper.creds[ nrow(upper.creds):1 , ] )
  
  # r values for plotting
  rs = c(rseq[[i]], rev(rseq[[i]]))
  Ms = rep(0, length(rseq[[i]]))
  
  p = plot(rseq[[i]], (Ms), type="n",
           xlab = myxlab, ylab=myylab[i], main = "",
           ylim=c(0,1.5),
           xlim=xrangeplot[[i]], cex.lab=myexp)
  #add a background grid
  grid()
  
  mtext(text = plotTitle[i], side = 3, line=1)
  
  # add credible regions
  for( k in 1:length(regions) ){
    polygon(x=rs, y=polyM[,k], col=solids[k], border=solids[k]) 
  }
  grid()
  # lines(truemodel$r, truemodel$mc/1e5, col=truecol, lwd=1.5)
  
  # add an empirical cdf of the stars in r
  # load the particular data set used
  datafilename <- list.files(paste0("../mockdata/paper1data/", mockdatafolders[i]))[j]
  
  mydata <- readRDS(paste0("../mockdata/paper1data/", mockdatafolders[i], datafilename))
  
  # add a line showing the cumulative fraction of stars
  lines(ecdf(mydata$r), col="black", do.points=FALSE)
  
  # if it's the last plot, then add a legend
  if(i==1){
    legend("topright", legend = c(mylegend, "ECDF of stars"), col=c(solids, "black"), lty=1, lwd=2, bg = "white")
  }
  
  box()
}

dev.off()

# if( makelegend ){
#   # add legend without rmin/rmax
#   legend( "topleft",  paste(colnames(lower.creds), "%" ), bg="white",
#           lwd=c(8,8,8), lty=c(1,1,1), col=solids,  cex=0.8)
#   
#   # use if want to plot min/max of data position and key in legend
#   if( plotdataminmax ){ 
#     abline(v=max(dat[,"Rgc"]), lty=2)
#     abline(v=min(dat[,"Rgc"]), lty=2)
#     #covers previous legend
#     legend( "topleft",  c(paste(colnames(lower.creds), "%" ), expression(r[min/max~data])), bg="white",
#             lwd=c(8,8,8,1.3), lty=c(1,1,1,2), col=c(solids,"black"),  cex=0.8)
#     
#   }
# }
# 

# add true M(r) if needed
# if( plottrue & !othersim ){
#   lines(x=rseq[[i]], y=sapply(rseq[[i]], FUN=M.r, pars=truepars), col="red", cex=1.3) 
# }
# if( plottrue & othersim ){
#   lines(x=r.true, y=M.true, col="red", cex=1.3)
# }
# 
# 
# print(p)
# 
# if(printpdf){  dev.off() }
# 
  
### Script to make a plot of three types of clusters

set.seed(753)

source("function_distancespeed.r")

# filenames of compact, average, and extended GCs
GCsIwant <- c("m5r1g1.5phi5.0", "m5r3g1.5phi5.0", "m5r9g1.5phi5.0", "/Regen_highPhi0/m5r3g1.5phi8.0_0", "/Regen_lowPhi0/m5r3g1.5phi2.0_0")
xyznames <- c("x", "y", "z", "vx", "vy", "vz")

GClist <- list(compsamp=NULL, avgsamp=NULL, extsamp=NULL, highPhi0samp=NULL, lowPhi0samp=NULL)

nplot=1e4
myalpha = 0.08
xrange <- c(-10, 10)
yrange <- c(-20, 20)
rrange <- c(0, 20)
vrange <- c(0,30)
mycex = 1.6

plottitles = c("Compact", "Average", "Extended", expression("High "~Phi[0]), expression("Low "~Phi[0]))

# write a loop to read in all the data and sample random stars to plot
for(i in 1:length(GClist)){
  # read in file
  temp <- read.table(paste0("../mockdata/paper1data/", GCsIwant[i], ".dat"), col.names = xyznames)
  
  # randomly sample stars
  GClist[[i]] <- temp[ sample(x = nrow(temp), size = nplot, replace=FALSE), ]
  
  # calculate distance from center and total speed
  GClist[[i]][, c("r", "v")] <- distancespeed(GClist[[i]])
  
  
}
# compact <- read.table(paste0("../mockdata/paper1data/", GCsIwant[1], ".dat"), col.names = xyznames)
# 
# average <- read.table(paste0("../mockdata/paper1data/", GCsIwant[2], ".dat"), col.names = xyznames)
# 
# extended <- read.table(paste0("../mockdata/paper1data/", GCsIwant[3], ".dat"), col.names = xyznames)
# 
# highPhi0 <- read.table(paste0("../mockdata/paper1data/Regen_highPhi0/", GCsIwant[4], ".dat"), col.names=xyznames)
# 
# lowPhi0 <- read.table(paste0("../mockdata/paper1data/Regen_lowPhi0/", GCsIwant[5], ".dat"), col.names = xyznames)

# compsamp <- compact[ sample(x = nrow(compact), size = nplot, replace = FALSE), ]
# avgsamp <- average[ sample(x = nrow(average), size = nplot, replace = FALSE), ]
# extsamp <- extended[ sample(x = nrow(extended), size = nplot, replace = FALSE), ]
# highPhi0samp <- highPhi0[ sample(nrow(highPhi0), nplot, FALSE), ]
# lowPhi0samp <- lowPhi0[ sample(nrow(lowPhi0), nplot, FALSE), ]
#   
#   
# calculate total distance from center and total speed
# source('function_distancespeed.r')
# compsamp[, c("r", "v")] <- distancespeed(compsamp)
# avgsamp[, c("r", "v")] <- distancespeed(avgsamp)
# extsamp[, c("r", "v")] <- distancespeed(extsamp)
# highPhi0samp[, c("r","v")] <- distancespeed(highPhi0samp)
# lowPhi0samp[, c("r", "v")] <- distancespeed(lowPhi0samp)

  
pdf(file = paste0("../Figures/Example_ThreeGCs", "_", Sys.Date(), ".pdf"), useDingbats = FALSE, height=7, width = 9)
par(mfrow=c(2,3), mar=c(5,0,2,0), oma=c(0,6,2,2))

for(i in 1:3){
  plot(GClist[[i]]$x, GClist[[i]]$y, asp=1, xlab="x (pc)", ylab="", type="n", xlim=xrange, ylim=yrange, axes=FALSE, cex.lab=mycex, main=plottitles[i], cex.main=mycex, cex.axis=mycex)
  
  grid()
  with(GClist[[i]], points(x,y, col=rgb(0,0,0,myalpha)))
  axis(1, cex.axis=mycex)
  box()

  if(i==1){  
    axis(2, cex.axis=mycex)
    mtext(text = "y (pc)", side = 2, line = 4, cex = 1.25)
  }
  
}

for(i in 1:3){
  plot(GClist[[i]]$r, GClist[[i]]$v, xlab = "r (pc)", ylab = "", cex.lab=mycex, type="n", xlim=rrange, ylim=vrange, cex.axis=mycex, axes=FALSE)
 
  grid()
  with(GClist[[i]], points(r,v, col=rgb(0,0,0,myalpha)))
  axis(1, cex.axis=mycex)
  box()
  
  if(i==1){  
    axis(2, cex.axis=mycex)
    mtext(text = "v (km/s)", side = 2, line = 4, cex = 1.25)
  }
  
}

dev.off()

########### plot for different Phi_0 #########################

pdf(file = paste0("../Figures/Example_ThreeGCs_Phi0_", Sys.Date(), ".pdf"), useDingbats = FALSE, height=7, width = 9)
par(mfrow=c(2,3), mar=c(5,0,2,0), oma=c(0,6,2,2))

# 5 is low Phi, 2 is average, 4 is low Phi0
for(i in c(5,2,4)){
  plot(GClist[[i]]$x, GClist[[i]]$y, asp=1, xlab="x (pc)", ylab="", type="n", xlim=xrange, ylim=yrange, axes=FALSE, cex.lab=mycex, main=plottitles[i], cex.main=mycex, cex.axis=mycex)
  
  grid()
  with(GClist[[i]], points(x,y, col=rgb(0,0,0,myalpha)))
  axis(1, cex.axis=mycex)
  box()
  
  if(i==5){  
    axis(2, cex.axis=mycex)
    mtext(text = "y (pc)", side = 2, line = 4, cex = 1.25)
  }
  
}

for(i in c(5,2,4)){
  plot(GClist[[i]]$r, GClist[[i]]$v, xlab = "r (pc)", ylab = "", cex.lab=mycex, type="n", xlim=rrange, ylim=vrange, cex.axis=mycex, axes=FALSE)
  
  grid()
  with(GClist[[i]], points(r,v, col=rgb(0,0,0,myalpha)))
  axis(1, cex.axis=mycex)
  box()
  
  if(i==5){  
    axis(2, cex.axis=mycex)
    mtext(text = "v (km/s)", side = 2, line = 4, cex = 1.25)
  }
  
}

dev.off()




################ old plotting #################
# plot(compsamp$x, compsamp$y, asp=1, xlab="x (pc)", ylab="", type="n", xlim=xrange, ylim=yrange, cex.lab=mycex, main="Compact", cex.main=mycex, cex.axis=mycex)
# grid()
# with(compsamp, points(x,y, col=rgb(0,0,0,myalpha)))
# mtext(text = "y (pc)", side = 2, line = 4, cex = 1.25)
# 
# plot(avgsamp$x, avgsamp$y, asp=1, xlab="x (pc)", ylab="", type="n", xlim=xrange, ylim=yrange, cex.lab=mycex, main="Average", cex.main=mycex, axes=FALSE, cex.axis=mycex)
# grid()
# axis(1, cex.axis=mycex)
# box()
# with(avgsamp, points(x,y, col=rgb(0,0,0,myalpha)))
# 
# plot(extsamp$x, extsamp$y, asp=1, xlab="x (pc)", ylab="", type="n", xlim=xrange, ylim=yrange, cex.lab=mycex, main="Extended", cex.main=mycex, axes=FALSE, cex.axis=mycex)
# grid()
# axis(1, cex.axis=mycex)
# box()
# with(extsamp, points(x,y, col=rgb(0,0,0,myalpha)))

# plot(compsamp$r, compsamp$v, xlab = "r (pc)", ylab = "", cex.lab=mycex, type="n", xlim=rrange, ylim=vrange, cex.axis=mycex)
# grid()
# points(compsamp$r, compsamp$v, col=rgb(0,0,0,myalpha))
# mtext(text = "v (100km/s)", side = 2, line = 4, cex = 1.25)
# 
# plot(avgsamp$r, avgsamp$v, xlab = "r (pc)", ylab = "", cex.lab=mycex, type="n", xlim=rrange, ylim=vrange, axes=FALSE, cex.axis=mycex)
# grid()
# axis(1, cex.axis=mycex)
# box()
# grid()
# points(avgsamp$r, avgsamp$v, col=rgb(0,0,0,myalpha))
# 
# plot(extsamp$r, extsamp$v, xlab = "r (pc)", ylab = "", cex.lab=mycex, type="n", xlim=rrange, ylim=vrange, axes=FALSE, cex.axis=mycex)
# grid()
# axis(1, cex.axis=mycex)
# box()
# points(extsamp$r, extsamp$v, col=rgb(0,0,0,myalpha))
# 
# plot(highPhi0samp$r, highPhi0samp$v, xlab = "r (pc)", ylab = "", cex.lab=mycex, type="n", axes=FALSE, cex.axis=mycex, xlim=rrange, ylim=vrange, cex.axis=mycex)
# grid()
# axis(1, cex.axis=mycex)
# box()
# points(highPhi0samp$r, highPhi0samp$v, col=rgb(0,0,0,myalpha))
# 
# dev.off()

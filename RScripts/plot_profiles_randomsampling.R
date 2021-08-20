# script to make 1 1x3 grid of mass profiles for average cluster
library(Cairo)
source("function_logLike_LIMEPY.r")

# we will plot the 13th file as an example for each case
example = 13

# set a character string vectors for the y-axes and x-axes
Ylab = c(expression(M(r<R)~(10^5~M["sun"])), "", "", expression(M(r<R)~(10^5~M["sun"]), "") )
Ylabvel = c( expression( bar(v^2)~(km^2~s^-2), "" , "", bar(v^2)~(km^2~s^-2), ""))
Xlab = "r (pc)"

# set the x range for each type of GC
# set the y and x range for all plots
yrange = list(c(0,1.5), c(0,1.5), c(0,1.5), c(0,1.5), c(0,1.5))
xrange = list(c(0,20), c(0,9), c(0,45), c(0,40), c(c(0,16)))
yrangevelPhi0 = list(c(0,100),c(0,300),c(0,50), c(0,150), c(0,150))
xrangevelPhi0 = list(c(0,20), c(0,9), c(0,45), c(0,40), c(c(0,16)))

# colour for true mass profile
truecol = "red"
# colour for mean mass profile
meancol = "lightblue"
# true total mass
truetotalcol = "darkgreen"
# colour for posterior mass profiles
postcol = rgb(0,0,0,0.006)
postlegend = "black"

# expansion factor for labels
myexp = 1.35

# plot titles
plotTitle <- c("Average", "Compact", "Extended", expression("High"~Phi[0]), expression("Low"~Phi[0]))

# make a vector of the folders in the order that you want them plotted
resultsfolders <- c("RegenAll/", "RegenCompact/", "RegenExtended/", "Regen_highPhi0/", "Regen_lowPhi0/")

mockdatafolders <- c("RegenAll/subsamp500_random/", "CompactGC/subsamp500/", "ExtendedGC/subsamp500/", "Regen_highPhi0/subsamp500/", "Regen_lowPhi0/subsamp500/")


####### 1. Plot MASS PROFILES for Average, Compact, Extended, High Phi0 and Low Phi0 #######

# open file to write to
# png(filename = paste0("../Figures/massprofiles_randomsampling", Sys.Date(), ".png"), res=300, width = 8, height = 3, units = "in")

pdf(paste0("../Figures/massprofiles_randomsampling", Sys.Date(), ".pdf"), width = 9, height = 7)

# create a plotting grid that is 2x6, and make each plot take up 2 cells, so we can have 3 plots in the first row and 2 plots in the second row.
layout(mat = matrix(c(1,1,2,2,3,3,
                      0,4,4,5,5,0), nrow = 2, byrow = TRUE))

# set up the outer margins, inner margins, grid, etc.
par(oma=c(0,4,3,3), mai=c(1,0.75,0,0), cex.lab=myexp, cex.axis=myexp)

# plot average, compact, and extended first
for(i in 1:3){
  
  # get ID for the GC
  filename <- list.files(path = paste0("../mockdata/paper1data/", mockdatafolders[i]))[example]
  ID <- strsplit(x = filename, split = ".rds")[[1]][1]
  
  # load the particular data set used
  mydata <- readRDS(paste0("../mockdata/paper1data/", mockdatafolders[i], filename))
  
  # load the true parameter values
  truepars <- readRDS(paste0("../results/paper1results/", resultsfolders[i], "truepars.rds"))
  
  # get the filename for the mass profiles from this GC
  resultsfile <- list.files(path = paste0("../results/paper1results/", resultsfolders[i]), pattern = paste0("massprofiles_chain_limepy_", ID))
  # load the mass profile posterior samples
  results <- readRDS(paste0("../results/paper1results/", resultsfolders[i],  resultsfile))
  
  # make the plot!
  plot(results[[1]]$r, results[[1]]$mass/1e5, xlab=Xlab, ylab=Ylab[i], xlim = xrange[[i]], ylim=yrange[[i]],  type="n", main="", las=1)
  
  grid()
  
  mtext(text = plotTitle[i], side = 3, line=1)
  
  # if it's the last plot, then add a legend
  if(i==1){
    legend("topright", legend = c("posterior profiles", "true profile"), col=c(postlegend, truecol), lty=1, lwd=2, bg = "white")
  }
  
  # add all the different mass profiles from the posterior
  lapply(X = results, FUN = function(X) lines(X$r, X$mass/1e5, col=postcol) )
  
  # abline(h=truepars[3]/1e5, col="darkgreen", lty=3, lwd=3)
  
  # calculate true model and add to plot true model mass profile
  truemodel <- limepy$limepy(g=truepars[1], phi0=truepars[2], M=truepars[3], rh=truepars[4])
  lines(truemodel$r, truemodel$mc/1e5, col="red", lwd=2)
  
}

# plot the high and low Phi0 results next
for(i in 4:length(resultsfolders)){
  
  # get ID for the GC
  filename <- list.files(path = paste0("../mockdata/paper1data/", mockdatafolders[i]))[example]
  ID <- strsplit(x = filename, split = ".rds")[[1]][1]
  
  # load the particular data set used
  mydata <- readRDS(paste0("../mockdata/paper1data/", mockdatafolders[i], filename))
  
  # load the true parameter values
  truepars <- readRDS(paste0("../results/paper1results/", resultsfolders[i], "truepars.rds"))
  
  # get the filename for the mass profiles from this GC
  resultsfile <- list.files(path = paste0("../results/paper1results/", resultsfolders[i]), pattern = paste0("massprofiles_chain_limepy_", ID))
  # load the mass profile posterior samples
  results <- readRDS(paste0("../results/paper1results/", resultsfolders[i],  resultsfile))
  
  # make the plot!
  plot(results[[1]]$r, results[[1]]$mass/1e5, xlab=Xlab, ylab=Ylab[i], xlim = xrange[[i]], ylim=yrange[[i]],  type="n", main="", las=1)
  
  grid()
  
  mtext(text = plotTitle[i], side = 3, line=1)
  
  # add all the different mass profiles from the posterior
  lapply(X = results, FUN = function(X) lines(X$r, X$mass/1e5, col=postcol) )
  
  # calculate true model and add to plot true model mass profile
  truemodel <- limepy$limepy(g=truepars[1], phi0=truepars[2], M=truepars[3], rh=truepars[4])
  lines(truemodel$r, truemodel$mc/1e5, col="red", lwd=2)
  
}

# turn off device
dev.off()

####### 2. Plot VELOCITY PROFILES for Average, Compact, Extended, High Phi0 and Low Phi0 #######

# open file to write to
pdf(paste0("../Figures/velocityprofiles_randomsampling_", Sys.Date(), ".pdf"), width = 9, height = 7)

layout(mat = matrix(c(1,1,2,2,3,3,
                      0,4,4,5,5,0), nrow = 2, byrow = TRUE))

# set up the outer margins, inner margins, grid, etc.
par(oma=c(2,3,3,3), mar=c(5,5,3,0), cex.lab=myexp, cex.axis=myexp)

for(i in 1:3){
  
  # get ID for the GC
  filename <- list.files(path = paste0("../mockdata/paper1data/", mockdatafolders[i]))[example]
  ID <- strsplit(x = filename, split = ".rds")[[1]][1]
  
  # load the particular data set used
  mydata <- readRDS(paste0("../mockdata/paper1data/", mockdatafolders[i], filename))
  
  # load the true parameter values
  truepars <- readRDS(paste0("../results/paper1results/", resultsfolders[i], "truepars.rds"))
  
  # get the filename for the mass profiles from this GC
  resultsfile <- list.files(path = paste0("../results/paper1results/", resultsfolders[i]), pattern = paste0("velocityprofiles_chain_limepy_", ID))
  # load the velocity profile posterior samples
  results <- readRDS(paste0("../results/paper1results/", resultsfolders[i],  resultsfile))
  
  # make the plot!
  plot(results[[1]]$r, results[[1]]$v2, xlab=Xlab, ylab=Ylabvel[i], xlim = xrangevelPhi0[[i]], ylim=yrangevelPhi0[[i]],  type="n", main="", las=1)
  
  grid()
  
  mtext(text = plotTitle[i], side = 3, line=1)
  
  # if it's the last plot, then add a legend
  if(i==1){
    legend("topright", legend = c("posterior profiles", "true profile"), col=c(postlegend, truecol), lty=1, lwd=2, bg = "white")
  }
  
  # add all the different mass profiles from the posterior
  lapply(X = results, FUN = function(X) lines(X$r, X$v2, col=postcol) )
  
  # calculate true model and add to plot true model mass profile
  truemodel <- limepy$limepy(g=truepars[1], phi0=truepars[2], M=truepars[3], rh=truepars[4])
  lines(truemodel$r, truemodel$v2, col="red", lwd=2)
  
  rug(mydata$r, col=rgb(0,0,0,0.05))
}

for(i in 4:length(resultsfolders)){
  
  # get ID for the GC
  filename <- list.files(path = paste0("../mockdata/paper1data/", mockdatafolders[i]))[example]
  ID <- strsplit(x = filename, split = ".rds")[[1]][1]
  
  # load the particular data set used
  mydata <- readRDS(paste0("../mockdata/paper1data/", mockdatafolders[i], filename))
  
  # load the true parameter values
  truepars <- readRDS(paste0("../results/paper1results/", resultsfolders[i], "truepars.rds"))
  
  # get the filename for the mass profiles from this GC
  resultsfile <- list.files(path = paste0("../results/paper1results/", resultsfolders[i]), pattern = paste0("velocityprofiles_chain_limepy_", ID))
  # load the velocity profile posterior samples
  results <- readRDS(paste0("../results/paper1results/", resultsfolders[i],  resultsfile))
  
  # make the plot!
  plot(results[[1]]$r, results[[1]]$v2, xlab=Xlab, ylab=Ylabvel[i], xlim = xrangevelPhi0[[i]], ylim=yrangevelPhi0[[i]],  type="n", main="", las=1)
  
  grid()
  
  mtext(text = plotTitle[i], side = 3, line=1)
  
  # add all the different mass profiles from the posterior
  lapply(X = results, FUN = function(X) lines(X$r, X$v2, col=postcol) )
  
  # calculate true model and add to plot true model mass profile
  truemodel <- limepy$limepy(g=truepars[1], phi0=truepars[2], M=truepars[3], rh=truepars[4])
  lines(truemodel$r, truemodel$v2, col="red", lwd=2)
  
  rug(mydata$r, col=rgb(0,0,0,0.05))
}

# turn off device
dev.off()






# script to make 1 1x3 grid of mass profiles for average cluster
library(Cairo)
source("function_logLike_LIMEPY.r")

# we will plot the 13th file as an example for each case
example = 13

# make a vector of the folders in the order that you want them plotted
resultsfolders <- c("RegenAll/", "RegenCompact/", "RegenExtended/")

mockdatafolders <- c("RegenAll/subsamp500_random/", "CompactGC/subsamp500/", "ExtendedGC/subsamp500/")

# plot titles
plotTitle <- c("Average", "Compact", "Extended")

# set a character string vectors for the y-axes and x-axes
Ylab = expression(M(r<R)~(10^5~M['\u2609']))
Xlab = "r (pc)"

# set the x range for each type of GC
# set the y and x range for all plots
yrange = list(c(0,1.5), c(0,1.5), c(0,1.5))
xrange = list(c(0,15), c(0,8), c(0,30))

# colour for true mass profile
truecol = "red"
# colour for mean mass profile
meancol = "lightblue"
# true total mass
truetotalcol = "darkgreen"
# colour for posterior mass profiles
postcol = rgb(0,0,0,0.006)
postlegend = "black"

# open file to write to
png(filename = paste0("../Figures/massprofiles_randomsampling", Sys.Date(), ".png"), res=300, width = 8, height = 3, units = "in")

# set up the outer margins, inner margins, grid, etc.
par(mfrow=c(1,3), oma=c(0,1,3,3), mai=c(1,0.6,0,0))

for(i in 1:length(resultsfolders)){
  
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
  if(i==length(resultsfolders)){
    legend("topright", legend = c("posterior profiles", "true profile"), col=c(postlegend, truecol), lty=1, lwd=2)
  }
  
  # add all the different mass profiles from the posterior
  lapply(X = results, FUN = function(X) lines(X$r, X$mass/1e5, col=postcol) )
  
  # abline(h=truepars[3]/1e5, col="darkgreen", lty=3, lwd=3)
  
  # calculate true model and add to plot true model mass profile
  truemodel <- limepy$limepy(g=truepars[1], phi0=truepars[2], M=truepars[3], rh=truepars[4])
  lines(truemodel$r, truemodel$mc/1e5, col="red", lwd=2)
  
}

# turn off device
dev.off()


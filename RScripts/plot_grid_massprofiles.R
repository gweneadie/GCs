# script to make 3x3 grid of mass profiles for paper
library(Cairo)
# source functions needed
source('function_logLike_LIMEPY.r')

# we will plot the 13th file as an example for each case
example = 13

# make a vector of the folders in the order that you want them plotted
resultsfolders <- c("RegenAll/", "RegenOutsideCore/", "RegenInsideCore/",
             "RegenCompact/", "CompactGC/subsamp500_outer/", "CompactGC/subsamp500_inner/",
             "RegenExtended/", "ExtendedGC/subsamp500_outer/", "ExtendedGC/subsamp500_inner/")

mockdatafolders <- c("RegenAll/subsamp500_random/", "RegenAll/subsamp500_outsidecore/", "RegenAll/subsamp500_insidecore/",
                     "CompactGC/subsamp500/", "CompactGC/subsamp500_outer/", "CompactGC/subsamp500_inner/",
                     "ExtendedGC/subsamp500/", "ExtendedGC/subsamp500_outer/", "ExtendedGC/subsamp500_inner/")

plotTitle <- c("Random", "Outside Core", "Inside Core","","","","","","")
outermarginleft <- c("Average", "", "", "Compact", "", "", "Extended", "", "")
outermarginbottom <- c(rep("", 6), "", "r (pc)", "")

# set a character string vectors for the y-axes and x-axes
Ylab = expression(M(r<R)~(10^5~M['\u2609']))
Ylab = c(Ylab, "", "", Ylab, "","", Ylab, "", "")
Xlab = ""

# set the y and x range for all plots
yrange = list(c(0,1.5), c(0,1.5), c(0,1.5))
xrange = list(c(0,10), c(0,10), c(0,30))

# set the x range for each type of GC
# colour for true mass profile
truecol = "red"
# colour for mean mass profile
meancol = "lightblue"
# true total mass
truetotalcol = "darkgreen"

# open file to write to
png(filename = paste0("../Figures/grid_massprofiles_", Sys.Date(), ".png"), res=100, width=900, height=800)

# set up the outer margins, inner margins, grid, etc.
par(mfrow=c(3,3), oma=c(3,5,3,5), mai=c(0.5,0.6,0,0))

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
  plot(results[[1]]$r, results[[1]]$mass/1e5, xlab=Xlab, ylab=Ylab[i], xlim = xrange[[ceiling(i/3)]], ylim=yrange[[ceiling(i/3)]], yaxt="n", xaxt="n", type="n", main="")
  
  axis(side = 1)
  axis(side = 2)
  grid()
  
  mtext(text = outermarginleft[i], side = 2, line=5)
  mtext(text = outermarginbottom[i], side=1, line=3)
  mtext(text = plotTitle[i], side = 3, line=1)
  
  # add all the different mass profiles from the posterior
  lapply(X = results, FUN = function(X) lines(X$r, X$mass/1e5, col=rgb(0,0,0,0.006)) )
  
  abline(h=truepars[3]/1e5, col="darkgreen", lty=3, lwd=3)
  
  # calculate true model and add to plot true model mass profile
  truemodel <- limepy$limepy(g=truepars[1], phi0=truepars[2], M=truepars[3], rh=truepars[4])
  lines(truemodel$r, truemodel$mc/1e5, col="red", lwd=2)
  
}

# turn off device
dev.off()


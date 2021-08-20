# script to make 3x2 grid of mass profiles for paper
library(Cairo)
source("function_logLike_LIMEPY.r")

# we will plot the 13th file as an example for each case
example = 15


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

plotTitle <- c("Outside Core", "Inside Core", rep("",7))

outermarginleft <- c( "Compact", "",
                      "Average", "",
                      "Extended", "",
                     expression("High "~Phi[0]), "",
                     expression("Low "~Phi[0]), ""
                     )

outermarginbottom <- c(rep("", 8), "r (pc)", "r (pc)")

# set a character string vectors for the y-axes and x-axes
Ylab = expression(M(r<R)~(10^5~M["sun"]))
Ylab = rep( c(Ylab, "") , 5)
Xlab = rep("", 10)
Ylabvel = rep( c(expression(bar(v^2)~(km^2~s^-2), "")), 5)

# set the y and x range for all plots
yrange = list(c(0,1.5), c(0,1.5), c(0,1.5), c(0,1.5), c(0,1.5))
xrange = list(c(0,7.5), c(0,20), c(0,45), c(0,40), c(c(0,12.5)))
# yrangevel = list(c(0,400), c(0,200),c(0,60), c(0,200), c(0,200))
yrangevel = list(c(0,300), c(0,100),c(0,40), c(0,150), c(0,125))
xrangevel = list( c(0,7.5), c(0,20), c(0,45), c(0,40), c(c(0,12.5)))

# colour for profile
truecol = "red"
# colour for posterior mass profiles
postcol = rgb(0,0,0,0.006)
postlegend = "black"


########## plot the mass profiles for different r_h and Phi_0 #########
# open file to write to
pdf(paste0("../Figures/massprofiles_biasedsampling", Sys.Date(), ".pdf"), width = 6, height = 8)

# set up the outer margins, inner margins, grid, etc.
par(mfrow=c(5,2), oma=c(2,5,3,5), mai=c(0.5,0.6,0,0))

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
  plot(results[[1]]$r, results[[1]]$mass/1e5, xlab=Xlab, ylab=Ylab[i], xlim = xrange[[ceiling(i/2)]], ylim=yrange[[ceiling(i/2)]], type="n", main="", las=1)
  
  grid()
  
  mtext(text = outermarginleft[i], side = 2, line=5)
  mtext(text = outermarginbottom[i], side = 1, line=3, cex=0.75)
  mtext(text = plotTitle[i], side = 3, line=1)
  
  # add all the different mass profiles from the posterior
  lapply(X = results, FUN = function(X) lines(X$r, X$mass/1e5, col=rgb(0,0,0,0.006)) )
  
  # abline(h=truepars[2]/1e5, col="darkgreen", lty=3, lwd=3)
  
  # calculate true model and add to plot true model mass profile
  truemodel <- limepy$limepy(g=truepars[1], phi0=truepars[2], M=truepars[3], rh=truepars[4])
  
  # add curve of true model
  lines(truemodel$r, truemodel$mc/1e5, col="red", lwd=2)
  
  # if it's the upper-right plot, then add a legend
  if(i==2){
    legend("topright", legend = c("posterior profiles", "true profile"), col=c(postlegend, truecol), lty=1, lwd=2, cex = 0.75, bg="white")
  }
  
}


# turn off device
dev.off()


########## plot the mean square VELOCITY profiles for different r_h and Phi_0 #######

# open file to write to
pdf(paste0("../Figures/velocityprofiles_biasedsampling_", Sys.Date(), ".pdf"), width = 6, height = 8)
# set up the outer margins, inner margins, grid, etc.
par(mfrow=c(5,2), oma=c(2,5,3,5), mai=c(0.5,0.6,0,0))

for(i in 1:length(resultsfolders)){
  
  # get ID for the GC
  filename <- list.files(path = paste0("../mockdata/paper1data/", mockdatafolders[i]))[example]
  ID <- strsplit(x = filename, split = ".rds")[[1]][1]
  
  # load the particular data set used
  mydata <- readRDS(paste0("../mockdata/paper1data/", mockdatafolders[i], filename))
  
  # load the true parameter values
  truepars <- readRDS(paste0("../results/paper1results/", resultsfolders[i], "truepars.rds"))
  
  # get the filename for the mass profiles from this GC
  resultsfile <- list.files(path = paste0("../results/paper1results/", resultsfolders[i]), pattern = paste0("velocityprofiles_chain_limepy_", ID))
  # load the mass profile posterior samples
  results <- readRDS(paste0("../results/paper1results/", resultsfolders[i],  resultsfile))
  
  # make the plot!
  plot(results[[1]]$r, results[[1]]$v2, 
       xlab=Xlab, ylab=Ylabvel[i],
       xrangevel[[ceiling(i/2)]], ylim=yrangevel[[ceiling(i/2)]],
       type="n", main="", las=1)
  
  grid()
  
  mtext(text = plotTitle[i], side = 3, line=1)
  mtext(text = outermarginleft[i], side = 2, line=5)
  mtext(text = outermarginbottom[i], side = 1, line=3, cex=0.75)

  # add all the different mass profiles from the posterior
  lapply(X = results, FUN = function(X) lines(X$r, X$v2, col=postcol) )
  
  # calculate true model and add to plot true model mass profile
  truemodel <- limepy$limepy(g=truepars[1], phi0=truepars[2], M=truepars[3], rh=truepars[4])
  lines(truemodel$r, truemodel$v2, col="red", lwd=2)
  
  abline(v=1.5, col="lightblue", lty=2)
  rug(mydata$r, col=rgb(0,0,0,0.05))
  
  # if it's the upper-right plot, then add a legend
  if(i==2){
    legend("topright", legend = c("posterior profiles", "true profile", expression(r[cut])), col=c(postlegend, truecol, "lightblue"), lty=c(1,1,2), lwd=2, cex = 0.75, bg = "white")
  }
  
  
}


# turn off device
dev.off()

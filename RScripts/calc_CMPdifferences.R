# source limepy functions and library for limepy
source("function_logLike_LIMEPY.r")
source("function_profiles.r")

# make a vector of the folders in the order that you want them plotted
resultsfolders <- c("RegenAll/", "RegenOutsideCore/", "RegenInsideCore/",
                    "RegenCompact/", "CompactGC/subsamp500_outer/", "CompactGC/subsamp500_inner/",
                    "RegenExtended/", "ExtendedGC/subsamp500_outer/", "ExtendedGC/subsamp500_inner/",
                    "Regen_highPhi0/", "Regen_highPhi0/subsamp500_outer/", "Regen_highPhi0/subsamp500_inner/",
                    "Regen_lowPhi0/", "Regen_lowPhi0/subsamp500_outer/", "Regen_lowPhi0/subsamp500_inner/")

mockdatafolders <- c("RegenAll/subsamp500_random/", "RegenAll/subsamp500_outsidecore/", "RegenAll/subsamp500_insidecore/",
                     "CompactGC/subsamp500/", "CompactGC/subsamp500_outer/", "CompactGC/subsamp500_inner/",
                     "ExtendedGC/subsamp500/", "ExtendedGC/subsamp500_outer/", "ExtendedGC/subsamp500_inner/",
                     "Regen_highPhi0/subsamp500/", "Regen_highPhi0/subsamp500_outer/", "Regen_highPhi0/subsamp500_inner/",
                     "Regen_lowPhi0/subsamp500/", "Regen_lowPhi0/subsamp500_outer/", "Regen_lowPhi0/subsamp500_inner/")


# 95% quantile
thisquant <- c("X2.5.", "X97.5.")


# function to calculate limepy model for every row of parameters in markov chain

# for each GC type
for(i in 1:length(resultsfolders)){
  
  # grab folder name and path
  foldername = resultsfolders[i]
  mypath = paste0("../results/paper1results/", foldername, "/")
  
  # get summary statistics
  summaryfilename <- list.files(mypath, pattern = "summarystatistics")
  summarylist <- readRDS(paste0(mypath, summaryfilename))
  df <- summarylist$dfsummaries
  # get true parameter values
  truepars <- summarylist$truepars
  # convert mass to units of 10^5
  truepars["M"] <- truepars["M"]/1e5
  
  # parameter names
  parnames <- levels(df$Parameter)
  
  # convert mass to units of 10^5
  df[df$Parameter=="M", c("Mean", "SD", "X2.5.", "X25.", "X50.", "X75.", "X97.5.")] <- df[df$Parameter=="M", c("Mean", "SD", "X2.5.", "X25.", "X50.", "X75.", "X97.5.")]/1e5
  
  meanpars <- as.data.frame(matrix(df$Mean, ncol=4, byrow=TRUE ))
  colnames(meanpars) <- levels(df$Parameter)
  
  # for every set of mean parameter values, calculate the mass profile
  estimates <- apply(X = meanpars, MARGIN = 1, FUN = simplemassprofile)
  
  # for every set of mean parameter values, calculate the mean-square velocity profile
  velest <- apply(X = meanpars, MARGIN = 1, FUN = velocityprofile)
  
  # calculate true model and add to plot true model mass profile
  truemodel <- limepy$limepy(g=truepars[1], phi0=truepars[2], M=truepars[3], rh=truepars[4])
  
  # r values 
  plot(estimates[[i]]$r, estimates[[i]]$mass, ylim=c(0,1.2), type="l")
  lines(truemodel$r, truemodel$mc, col="red", lwd=2)
  for(j in 2:50){
    lines(estimates[[j]]$r, estimates[[j]]$mass, col=rgb(0,0,0.3, 0.3))
  }
}

# calculte difference between true CMP and mean CMP, save values



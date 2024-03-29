# source limepy functions and library for limepy
source("function_logLike_LIMEPY.r")
source("function_profiles.r")

library(dplyr)
library(matrixStats)
library(Hmisc)

# make a vector of the folders in the order that you want them plotted
resultsfolders <- c("RegenAll/", "RegenOutsideCore/", "RegenInsideCore/",
                    "RegenCompact/", "CompactGC/subsamp500_outer/", "CompactGC/subsamp500_inner/",
                    "RegenExtended/", "ExtendedGC/subsamp500_outer/", "ExtendedGC/subsamp500_inner/",
                    "Regen_highPhi0/", "Regen_highPhi0/subsamp500_outer/", "Regen_highPhi0/subsamp500_inner/",
                    "Regen_lowPhi0/", "Regen_lowPhi0/subsamp500_outer/", "Regen_lowPhi0/subsamp500_inner/")

# what quantiles do you want
thisquant <- c(0.025, 0.975) # 95%


# sequence of r values for calculations and plotting
# xrange = list(c(0,7.5), c(0,20), c(0,45), c(0,40), c(c(0,12.5)))
rseq = seq(0,45, length.out=2e2)

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
  
  # calculate true model
  truemodel <- limepy$limepy(g=truepars[1], phi0=truepars[2], M=truepars[3], rh=truepars[4])
  
  
  # for every profile estimate, create a spline function for the CMP so we can calculate at any M(r)
  funCMPs <- lapply(X = estimates, FUN = splineprofile, columns=c("r", "mass"))
  
  # for the true model, create a spline function for the true CMP
  funtrue <- splinefun(x = truemodel$r, y = truemodel$mc)
  
  # get estimates at custom r values
  CMPs <- lapply(funCMPs, FUN = function(x) data.frame(r=rseq, mass=x(rseq)))
  truemass <- funtrue(rseq)
  
  # calculate difference between true CMP and mean CMP, save values
  diffCMPs <- lapply(CMPs, FUN = function(x) data.frame(r=x$r, diffs=(x$mass - truemass)) )
  
  # put all the diffs into a single dataframe so the r values match up
  temp <- bind_cols(diffCMPs)  
  # grab all columns with differences
  temp <- temp %>% dplyr:: select(starts_with("diff")) 
  
  # lower and upper 95% ci
  ci95 <- t( apply(X = as.matrix(temp), MARGIN = 1, FUN = function(x) quantile(x, probs=thisquant)) )
  
  # calculate stats of difference across rows (i.e., at each r)
  diffStats <- data.frame(xbar=rowMeans(x = temp), ci95lower = ci95[, 1], ci95higher = ci95[, 2])
  # add a column for the r values
  diffStats$rseq <- rseq
  
  # save everything as a list
  everything <- list(diffStats, diffCMPs)
  names(everything) = c("diffStats", "diffCMPs")
  
  # save object
  saveRDS(everything,file = paste0("../results/paper1results/", resultsfolders[i], "CMPdifferences_", Sys.Date(), ".rds" ) )

}

# plot the estimated CMPs
# plot(estimates[[i]]$r, estimates[[i]]$mass, ylim=c(0,1.2), type="l", col=rgb(0,0,0.3, 0.3))
# for(j in 2:50){
#   lines(estimates[[j]]$r, estimates[[j]]$mass, col=rgb(0,0,0.3, 0.3))
# }
# # add the true profile
# lines(truemodel$r, truemodel$mc, col="red", lwd=2)

# 
# plot(diffCMPs[[i]]$r, diffCMPs[[i]]$diffs, 
#      col=rgb(0,0,0.3, 0.3), type="l", 
#      ylim=range(diffStats),
#      ylab=expression(M[true](r)-M[estimated](r))
#      )
# polygon(x = c(rseq, rev(rseq)), y = c(diffStats$ci95lower, rev(diffStats$ci95higher)), col=rgb(0,0.4,0.7, alpha = 0.25), border = NA )
# # make figure of xbar
# lines(rseq, diffStats$xbar)
# for(j in 2:50){
#   lines(diffCMPs[[j]]$r, diffCMPs[[j]]$diffs, col=rgb(0,0,0.3, 0.3))
# }
# abline(h=0, lty=2)


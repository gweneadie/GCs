# set the relative location of the files where the data are, and where the results will be saved
locale <- "CompactGC/subsamp500_inner/"
modelname = "limepy"

# Get the filenames needed
filenamelist = list.files(path = paste0("../mockdata/paper1data/", locale), pattern = ".rds")

# need to get just the filename for saving in other scripts
filenamelist = unlist(strsplit(filenamelist, split = ".rds"))

#' set prior bounds
gbounds = c(1e-3, 3.5) # bounds for uniform prior on g
phi0bounds = c(1.5, 14) # bounds for uniform prior on phi_0
log10Mpars = c( 5.85, 0.6 ) # mean and standard deviation for log10(M)
rhpars = c(0, 30, 1.1, 0.4) # lower bound, upper bound, mean, sd for r_h


# source functions needed
source('function_logLike_LIMEPY.r')
source('function_priors.r')
source('function_prior-wrapper.r')
source('function_transform-parameters.r')
source('function_logtargetdensity.r')
library(NMOF)


for(i in 1:length(filenamelist)){
  
  # filename of mockdata
  filename <- filenamelist[i]

  mydata <- readRDS( paste0("../mockdata/paper1data/", locale, filename, ".rds") )
  
  # run optimization
  source("script_optimize.r")
  
}




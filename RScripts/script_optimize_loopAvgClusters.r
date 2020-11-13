# Get the filenames needed
filenamelist = list.files(path = "../mockdata/paper1data/Regen/subsamp500_outer/", pattern = ".rds")

filenamelist = unlist(strsplit(filenamelist, split = ".rds"))

#' set prior bounds
gbounds = c(1e-3, 3.5) # bounds for uniform prior on g
phi0bounds = c(1.5, 14) # bounds for uniform prior on phi_0
log10Mpars = c( 5.85, 0.6 ) # mean and standard deviation for log10(M)
rhpars = c(0, 30, 3.0, 0.4) # lower bound, upper bound, mean, sd for r_h


# source functions needed
source('function_logLike_LIMEPY.r')
source('function_priors.r')
source('function_prior-wrapper.r')
source('function_transform-parameters.r')
source('function_logtargetdensity.r')
library(NMOF)

modelname = "limepy"

for(i in 3:length(filenamelist)){
  
  # filename of mockdata
  filename <- filenamelist[i]
  # # sample data set
  # nsamp = 500
  # 
  # # read in snap data
  # alldata = readRDS( paste0("../mockdata/paper1data/Regen/", filename, ".rds") )
  # 
  # # get a random sample of stars, but use the same seed
  # set.seed(123)
  # 
  # mydata = alldata[sample(x = 1:nrow(alldata), size = nsamp, replace = FALSE), ]
  
  mydata <- readRDS( paste0("../mockdata/paper1data/Regen/subsamp500_outer/", filename, ".rds") )
  
  # run optimization
  source("script_optimize.r")
  
}




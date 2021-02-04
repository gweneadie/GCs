############# Source libraries and functions needed
library(MASS)
library(coda)

# set the relative location of the files where the data are, and where the results will be saved
locale <- "CompactGC/subsamp500_inner/"
modelname = "limepy"

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
source("function_GCmcmc.r")
source("function_proposal-distribution-modelpars.r")
source("function_iswhole.r")
source("function_adjustproposal.r")

# Get the filenames needed
filenamelist = list.files(path = paste0("../mockdata/paper1data/", locale), pattern = "subsamp")

filenamelist = unlist(strsplit(filenamelist, split = ".rds"))

# get filenames for optim results
optimfilelist <- list.files(paste0("../results/paper1results/", locale), pattern = "DEoptim")

# make an initial covariance matrix for LIMEPY, which has 4 model parameters
covariancematrix = matrix(c(0.001,0,0,0, 
                            0,0.007,0,0,
                            0,0,5e4,0,
                            0,0,0,0.02), nrow=4)

for(i in 1:length(optimfilelist)){
  # filename of mockdata
  filename <- filenamelist[i]
  
  # load data 
  mydata <- readRDS( paste0("../mockdata/paper1data/", locale, filename, ".rds") )
  
  # load the optimization file that has good starting parameters
  DEoptim <- readRDS(file = paste0("../results/paper1results/", locale, optimfilelist[i]))
  
  source("script_initialrun.r")
  
}

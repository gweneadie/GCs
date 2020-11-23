################# Set-up script for analysis

#' filename of mockdata
filename <- "m5r3g1.5phi5.0_20"
# sample data set
nsamp = 500

#' read in snap data
alldata = readRDS( paste0("../mockdata/paper1data/Regen/", filename, ".rds") )

#' get a random sample of stars
set.seed(123)
mydata = alldata[sample(x = 1:nrow(alldata), size = nsamp, replace = FALSE), ]

#' set prior bounds
gbounds = c(1e-3, 3.5) # bounds for uniform prior on g
phi0bounds = c(1.5, 14) # bounds for uniform prior on phi_0
log10Mpars = c( 5.85, 0.6 ) # mean and standard deviation for log10(M)
rhpars = c(0, 30, 3.0, 0.4) # lower bound, upper bound, mean, sd for r_h


#' make an initial covariance matrix for LIMEPY, which has 4 model parameters
covariancematrix = matrix(c(0.001,0,0,0, 
                            0,0.007,0,0,
                            0,0,5e4,0,
                            0,0,0,0.02), nrow=4)

#' name for model assumption
modelname = "limepy"

rm(alldata)

#' functions needed (I should make a package...)
# source
source('function_logLike_LIMEPY.r')
source('function_priors.r')
source('function_prior-wrapper.r')
source('function_transform-parameters.r')
source('function_logtargetdensity.r')
library(NMOF)

library(MASS)
library(coda)

source("function_GCmcmc.r")
source("function_proposal-distribution-modelpars.r")
source("function_iswhole.r")
source("function_adjustproposal.r")

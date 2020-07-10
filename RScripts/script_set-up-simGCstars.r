# set-up script for analysis

# source limepy function that uses reticulate
source("function_logDFlimepy.r")
library(MASS)
source("function_transform-parameters.r")
source("function_proposal-distribution-modelpars.r")
source("function_GCmcmc.r")
source("function_iswhole.r")
source("function_priors.r")
source("function_prior-wrapper.r")
source("function_adjustproposal.r")

# sample data set
nsamp = 500

# read in snap data
mydata = readRDS("../mockdata/snap_version2_dffix_2020-03-09.rds")

# get a random sample of stars
set.seed(123)
mydata = mydata[sample(x = 1:nrow(mydata), size = nsamp, replace = FALSE), ]

# initial parameters g, phi0, M (in solar masses), rh
initpars = c(1.5, 5., 120000., 3.)


# hyperprior values
gbounds = c(1e-3, 3.5) # assuming truncated uniform prior
phi0bounds = c(1.5, 14) # assuming truncated uniform prior
log10Mpars = c( 5.85, 0.6 ) # for Mpars, gaussian on log10(M)
rhpars = c(0, 30, 3.4, 0.2) # lower bound, upper bound, mean, sd

# covariance matrix (guess)
covariancematrix = matrix(c(0.001,0,0,0, 
                            0,0.007,0,0,
                            0,0,5e4,0,
                            0,0,0,0.02), nrow=4)



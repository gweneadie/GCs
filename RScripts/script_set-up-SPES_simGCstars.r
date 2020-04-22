# set-up script for analysis

# source limepy function that uses reticulate
source("function_logDFlimepy.r")
source("function_logDFspes.r")
library(MASS)
source("function_transform-parameters.r")
source("function_proposal-distribution-modelpars.r")
source("function_GCmcmc.r")
source("function_iswhole.r")
source("function_priors.r")
source("function_prior-wrapper.r")
source("function_adjustproposal.r")


# read in snap data
mydata = readRDS("../mockdata/snap_version2_dffix_2020-03-09.rds")

# get a random sample of stars
set.seed(123)
mydata = mydata[sample(x = 1:nrow(mydata), size = 500, replace = FALSE), ]

mydata = mydata[mydata$r>5, ]

# initial parameters phi0, B, eta, M (in solar masses), rh
initpars = c(5., 0.5, 0.45, 120000., 3.3)


# hyperprior values
phi0bounds = c(1.5, 14) # assuming truncated uniform prior
Bbounds = c(0, 1) # assuming truncated uniform prior
etabounds = c(0, 1) # assuming truncated uniform prior
log10Mpars = c( 5, 0.6 ) # for Mpars, gaussian on log10(M)
rhbounds = c(3.4, 0.2) # assuming Gaussian


# covariance matrix (guess)
covariancematrix = matrix(c(0.001, 0, 0, 0, 0,
                            0, 0.007, 0, 0, 0,
                            0, 0, 0.07, 0, 0,
                            0, 0, 0, 0.1, 0,
                            0, 0, 0, 0, 0.002), nrow=5)



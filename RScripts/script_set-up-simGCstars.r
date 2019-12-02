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

# read in snap data
mydata = readRDS("../mockdata/snap_Rformat_2019-11-25.rds")

# get a random sample of 100 stars
set.seed(123)
mydata = mydata[sample(x = 1:nrow(mydata), size = 100, replace = FALSE), ]


# initial parameters g, phi0, M, rh
initpars = c(2.3,3.,50000.,4.)

# hyperprior values
gbounds = c(1e-3, 3.5) # assuming truncated uniform prior
phi0bounds = c(1.5, 14) # assuming truncated uniform prior
# Mpars = c(10^5.5, 10^4) # assuming log-normal prior
Mpars = c(5.2*2, 0.5*2)
rhbounds = c(3.4, 2.2) # assuming Gaussian

# covariance matrix (guess)
covariancematrix = matrix(c(0.001,0,0,0, 
                            0,0.007,0,0,
                            0,0,5,0,
                            0,0,0,0.002), nrow=4)


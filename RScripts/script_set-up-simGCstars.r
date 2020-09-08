################# Set-up script for analysis

# filename of mockdata
filename <- "m5r1g1.5phi5.0"
# sample data set
nsamp = 500

# read in snap data
alldata = readRDS( paste0("../mockdata/paper1data/", filename, ".rds") )

# get a random sample of stars
set.seed(123)
mydata = alldata[sample(x = 1:nrow(alldata), size = nsamp, replace = FALSE), ]

# set prior bounds
gbounds = c(1e-3, 3.5) # bounds for uniform prior on g
phi0bounds = c(1.5, 14) # bounds for uniform prior on phi_0
log10Mpars = c( 5.85, 0.6 ) # mean and standard deviation for log10(M)
rhpars = c(0, 10, 1.0, 0.4) # lower bound, upper bound, mean, sd for r_h


# make an initial covariance matrix for LIMEPY, which has 4 model parameters
covariancematrix = matrix(c(0.001,0,0,0, 
                            0,0.007,0,0,
                            0,0,5e4,0,
                            0,0,0,0.02), nrow=4)





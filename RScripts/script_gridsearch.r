# calculate log( likelihood*prior ) on a grid to visualize

source('function_logDFlimepy.r')
source('function_logDFspes.r')
source('function_priors.r')
source('function_prior-wrapper.r')
source('function_transform-parameters.r')

# unnormalized target distribution ( log (likelihood times prior) )
target <- function(init, mydat, logDF, priors=prior.wrapper, ... ){
  
  sum( logDF( pars=init, dat=mydat ) ) + sum( log( priors( pars = init, ... ) ) )
  
}

# read in snap data
mydata = readRDS("../mockdata/snap_version2_dffix_2020-03-09.rds")
# get a random sample of stars
set.seed(123)
nsamp = 500
mydata = mydata[sample(x = 1:nrow(mydata), size = nsamp, replace = FALSE), ]

# hyperprior values
gbounds = c(1e-3, 3.5) # assuming truncated uniform prior
phi0bounds = c(1.5, 14) # assuming truncated uniform prior
log10Mpars = c( 5.85, 0.6 ) # for Mpars, gaussian on log10(M)
rhpars = c(0, 30, 3.4, 0.2) # lower bound, upper bound, mean, sd for truncated normal prior

################# first look at regular limepy
# make grid of parameter values
griddim = 25
pargrid = expand.grid(g = seq(1e-1, 3.49, length.out=griddim), phi0 = seq(1.5, 14, length.out = griddim), M = seq(1e5, 1.5e5, length.out = griddim), rh = seq(1e-2, 30, length.out = griddim))

system.time( test <- apply(X = pargrid, FUN = target, MARGIN = 1, mydat = mydata, logDF = logDF.limepy, priorfuncs = list(singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior), ppars = list( gbounds, phi0bounds, log10Mpars, rhpars)))

saveRDS(test, file = paste("../results/gridsearch_", Sys.Date(), sep="") )

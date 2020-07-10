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
gseq = seq(1e-1, 3.49, length.out=griddim)
phi0seq = seq(1.5, 14, length.out = griddim)
Mseq = seq(1e5, 1.5e5, length.out = griddim)
rhseq = seq(1e-2, 30, length.out = griddim)

pargrid = expand.grid(g = gseq, phi0 = phi0seq, M = Mseq, rh = rhseq)

system.time( test <- apply(X = pargrid, FUN = target, MARGIN = 1, mydat = mydata, logDF = logDF.limepy, priorfuncs = list(singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior), ppars = list( gbounds, phi0bounds, log10Mpars, rhpars)))

saveRDS(test, file = paste("../results/gridsearch_", Sys.Date(), sep="") )


################# now try it with SPES
# need a couple different parameters
Bbounds = c(0, 1) # assuming truncated uniform prior
etabounds = c(0, 1) # assuming truncated uniform prior
Bseq = seq(1e-1, 1, length.out = griddim)
etaseq = seq(1e-1, 1, length.out = griddim)

# need a different grid because 5 parameters now
pargridSPES = expand.grid(phi0 = phi0seq, B = Bseq, eta = etaseq, M = Mseq, rh = rhseq)

system.time( SPEStest <- apply(X = pargridSPES, FUN = target, MARGIN = 1, mydat = mydata, logDF = logDF.spes, priorfuncs = list(singleunif.prior, singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior), ppars = list(phi0bounds, Bbounds, etabounds, log10Mpars, rhpars) ) )

saveRDS(SPEStest, file = paste("../results/gridsearchSPES_", Sys.Date(), sep=""))
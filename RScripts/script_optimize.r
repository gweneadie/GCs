
# use optim to find the maximum and the second derivative of the likelihood times prior
source('function_logLike_LIMEPY.r')
source('function_logDFspes.r')
source('function_priors.r')
source('function_prior-wrapper.r')
source('function_transform-parameters.r')

# likelihood times prior function
likeprior <- function(init, mydat, logLike, priors=prior.wrapper, ... ){
  
  sum( logLike( pars=init, dat=mydat ) ) + sum( log( priors( pars = init, ... ) ) )
  
  
}

# read in snap data
mydata = readRDS("../mockdata/snap_version2_dffix_2020-03-09.rds")
# get a random sample of stars
set.seed(123)
nsamp = 500
mydata = mydata[sample(x = 1:nrow(mydata), size = nsamp, replace = FALSE), ]


########### run optim for limepy
# hyperprior values
gbounds = c(1e-3, 3.5) # assuming truncated uniform prior
phi0bounds = c(1.5, 14) # assuming truncated uniform prior
log10Mpars = c( 5.85, 0.6 ) # for Mpars, gaussian on log10(M)
rhpars = c(0, 30, 3.4, 0.2) # lower bound, upper bound, mean, sd for truncated normal prior

# initial parameters g, phi0, M (in solar masses), rh
initpars = c(1.5, 5., 120000., 3.)

# run optim
test = optim(par = initpars, fn = likeprior, mydat = mydata, logLike = logLike.limepy, priorfuncs = list(singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior), ppars = list( gbounds, phi0bounds, log10Mpars, rhpars), control=list(fnscale=-1) )

# run again with starting values where last one ended
test2 = optim(par = test$par, fn = likeprior, mydat = mydata, logLike = logLike.limepy, priorfuncs = list(singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior), ppars = list( gbounds, phi0bounds, log10Mpars, rhpars), control=list(fnscale=-1) )

test2

########### run optim for spes
# hyperprior values
phi0bounds = c(1.5, 14) # assuming truncated uniform prior
Bbounds = c(0, 1) # assuming truncated uniform prior
etabounds = c(0, 1) # assuming truncated uniform prior
log10Mpars = c( 5.85, 0.6 ) # for Mpars, gaussian on log10(M)
rhpars = c(0, 30, 3.4, 0.2) # lower bound, upper bound, mean, sd

initpars = c(5., 0.5, 0.5, 120000., 3.3)

test = optim(par = initpars, fn = likeprior, mydat=mydata, logDF = logDF.spes, priorfuncs = list(singleunif.prior, singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior), ppars = list( phi0bounds, Bbounds, etabounds, log10Mpars, rhpars), control=list(fnscale=-1) )

# testing GCmcmc function (doesn't include measurement uncertainties). Basic.

# source limepy function that uses reticulate
source("function_logDFlimepy.r")
source("../../GME/RScripts/functions_priors.r")
library(MASS)
source("function_transform-parameters.r")
source("function_proposal-distribution-modelpars.r")
source("function_GCmcmc.r")
source("function_iswhole.r")

# make some mock data
#mydata = matrix(data = c(abs(rnorm(10)), rnorm(10)*0.2, rnorm(10))*0.2, nrow = 10, ncol = 3)

mydata = readRDS("../mockdata/snap_Rformat_2019-11-25.rds")

# get a random sample of 100 stars
set.seed(123)
mydata = mydata[sample(x = 1:nrow(mydata), size = 100, replace = FALSE), ]


#mydata = cbind( c(1, 0), c(1., 0.), c(0., 0.) )

# check what limepy gives you
lmodel = limepy$limepy(g=1.,phi0=5.,M=1000.,rh=3.)

# check what logDF.limepy gives you
# logDF.limepy( dat=mydata, pars = log(c(1.,5.,1000.,3.)), transform.pars = transform.func )
# 
#

# initial parameters
initpars = c(2.3,3.,50000.,4.)

head(logDF.limepy( dat=mydata, pars = initpars))
any( !is.finite( logDF.limepy( dat=mydata, pars = initpars) ))

# prior bounds
gbounds = c(0.5, 3.3)
phi0bounds = c(1., 20)
Mpars = c(10^5.5, 10^4)
rhbounds = c(1.,5)

# covariance matrix (guess)
y = 0.2
covariancematrix = matrix(c(y,0,0,0, 
                            0,y,0,0,
                            0,0,y,0,
                            0,0,0,y), nrow=4)




test = GCmcmc(init = log(initpars), mydat = mydata, logDF = logDF.limepy, priors = prior.wrapper,
       N = 1e1,
       transform.pars = transform.func,
       priorfuncs = list( singleunif.prior, singleunif.prior, gaus.prior, singleunif.prior ),
       ppars = list( gbounds, phi0bounds, Mpars, rhbounds ),
       propDF = mypropDF, 
       covmat = covariancematrix
)

plot( as.mcmc( transform.chains(test$chain)) )

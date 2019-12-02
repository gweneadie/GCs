# initial run with snap data

source("script_set-up-simGCstars.r")

library(coda)
# initial run
runinit = GCmcmc(init = log(initpars), mydat = mydata, logDF = logDF.limepy, priors = prior.wrapper,
              N = 5e2,
              transform.pars = transform.func,
              priorfuncs = list( singleunif.prior, singleunif.prior, lnorm.prior, gaus.prior ),
              ppars = list( gbounds, phi0bounds, Mpars, rhbounds ),
              propDF = mypropDF, 
              covmat = covariancematrix
)

# look at the parameter chains
plot( as.mcmc( transform.chains(runinit$chain)) )

newcovmat = cov( runinit$chain )

newinitpars = runinit$chain[ nrow(runinit$chain), ]

runanother = GCmcmc(init = log(initpars), mydat = mydata, logDF = logDF.limepy, priors = prior.wrapper,
                 N = 1e3,
                 transform.pars = transform.func,
                 priorfuncs = list( singleunif.prior, singleunif.prior, .prior, gaus.prior ),
                 ppars = list( gbounds, phi0bounds, Mpars, rhbounds ),
                 propDF = mypropDF, 
                 covmat = newcovmat, parnames = c("Phi_0", "gamma", "alpha", "beta")
)

# plot again
plot( as.mcmc( transform.chains(runanother$chain) ) )

runanother$acceptance.rate


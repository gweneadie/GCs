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
                 priorfuncs = list( singleunif.prior, singleunif.prior, lnorm.prior, gaus.prior ),
                 ppars = list( gbounds, phi0bounds, Mpars, rhbounds ),
                 propDF = mypropDF, 
                 covmat = newcovmat, parnames = c("g", "Phi_0", "M", "r_h")
)

# plot again
plot( as.mcmc( transform.chains(runanother$chain) ) )

runanother$acceptance.rate

test = adjustproposal(acceptrange = c(0.4,0.45), Nsteps = 1e3, yourpatience = 20, initcovmat = newcovmat, initlogpars = log(initpars),
                      mydat = mydata, logDF = logDF.limepy, 
                      priors = prior.wrapper,
                      transform.pars = transform.func,
                      priorfuncs = list( singleunif.prior, singleunif.prior, lnorm.prior, gaus.prior ),
                      ppars = list( gbounds, phi0bounds, Mpars, rhbounds ),
                      propDF = mypropDF, 
                      parnames = c("g", "Phi_0", "M", "r_h"))

plot( as.mcmc( transform.chains(test$chain)))



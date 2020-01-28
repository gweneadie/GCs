# initial run with snap data

source("script_set-up-simGCstars.r")

library(coda)
# initial run
runinit = GCmcmc(init = initpars, mydat = mydata, logDF = logDF.limepy, priors = prior.wrapper,N = 5e2, transform.pars = notransform.func, priorfuncs = list( singleunif.prior, singleunif.prior, l10norm.prior, gaus.prior ), ppars = list( gbounds, phi0bounds, Mpars, rhbounds ), propDF = mypropDF, covmat = covariancematrix
)

# look at the parameter chains
plot( as.mcmc( runinit$chain) ) 

newcovmat = cov( runinit$chain )

newinitpars = runinit$chain[ nrow(runinit$chain), ]

runanother = GCmcmc(init = initpars, mydat = mydata, logDF = logDF.limepy, priors = prior.wrapper, N = 1e3, transform.pars = notransform.func, priorfuncs = list( singleunif.prior, singleunif.prior, l10norm.prior, gaus.prior ), ppars = list( gbounds, phi0bounds, Mpars, rhbounds ), propDF = mypropDF, covmat = newcovmat, parnames = c("g", "Phi_0", "M", "r_h")
)

# plot again
plot( as.mcmc( runanother$chain) )

runanother$acceptance.rate

test = adjustproposal(acceptrange = c(0.4,0.45), Nsteps = 500, yourpatience = 20, initcovmat = newcovmat, initlogpars = initpars, mydat = mydata, logDF = logDF.limepy, priors = prior.wrapper, transform.pars = notransform.func, priorfuncs = list( singleunif.prior, singleunif.prior, l10norm.prior, gaus.prior ), ppars = list( gbounds, phi0bounds, Mpars, rhbounds ), propDF = mypropDF, parnames = c("g", "Phi_0", "M", "r_h"))

plot( as.mcmc( test$chain[5001:1e4, ]) )

nrow(test$chain)


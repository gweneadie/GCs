# initial run with snap data

source("script_set-up-simGCstars.r")

library(coda)

# initial run
runinit = GCmcmc(init = initpars, mydat = mydata, logDF = logDF.limepy, priors = prior.wrapper, N = 5e2, 
                 transform.pars = notransform.func, 
                 priorfuncs = list( singleunif.prior, singleunif.prior, normlog10M.prior, gaus.prior ), ppars = list( gbounds, phi0bounds, log10Mpars, rhbounds ), propDF = mypropDF, covmat = covariancematrix)

# look at the parameter chains
plot( as.mcmc( runinit$chain) ) 

newcovmat = cov( runinit$chain )

newinitpars = runinit$chain[ nrow(runinit$chain), ]

runanother = GCmcmc(init = newinitpars, mydat = mydata, logDF = logDF.limepy, priors = prior.wrapper, N = 1e3, transform.pars = notransform.func, priorfuncs = list( singleunif.prior, singleunif.prior, normlog10M.prior, gaus.prior ), ppars = list( gbounds, phi0bounds, log10Mpars, rhbounds ), propDF = mypropDF, covmat = newcovmat, parnames = c("g", "Phi_0", "M", "r_h")
)

# plot again
plot( as.mcmc( runanother$chain) )

runanother$acceptance.rate

newinitpars = runanother$chain[ nrow(runanother$chain), ]


test = adjustproposal(acceptrange = c(0.26,0.42), Nsteps = 500, yourpatience = 15, initcovmat = newcovmat, initlogpars = newinitpars, mydat = mydata, logDF = logDF.limepy, priors = prior.wrapper, transform.pars = notransform.func, priorfuncs = list( singleunif.prior, singleunif.prior, normlog10M.prior, gaus.prior ), ppars = list( gbounds, phi0bounds, log10Mpars, rhbounds ), propDF = mypropDF, parnames = c("g", "Phi_0", "M", "r_h"))

plot( as.mcmc(test$chain))



saveRDS(object = test, file = paste("../results/prelim_mcmc_", Sys.Date()))

        
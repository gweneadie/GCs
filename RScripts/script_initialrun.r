# initial run with snap data

source("script_set-up-simGCstars.r")

library(coda)

# initial run
runinit = GCmcmc(init = initpars, mydat = mydata, logLike = logDF.limepy, priors = prior.wrapper, N = 1e3, 
                 transform.pars = notransform.func, 
                 priorfuncs = list( singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior ),
                 ppars = list( gbounds, phi0bounds, log10Mpars, rhpars ),
                 propDF = mypropDF, covmat = covariancematrix, n.pars=4,
                 parnames = c("g", "Phi0", "M", "rh"))



# look at the parameter chains
plot( as.mcmc( runinit$chain) ) 

newcovmat = cov( runinit$chain )

newinitpars = runinit$chain[ nrow(runinit$chain), ]

runanother = GCmcmc( init = newinitpars, mydat = mydata, logDF = logDF.limepy, priors = prior.wrapper, N = 5e3,
                transform.pars = notransform.func,
                priorfuncs = list( singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior ),
                ppars = list( gbounds, phi0bounds, log10Mpars, rhpars ),
                propDF = mypropDF, covmat = newcovmat,
                parnames = c("g", "Phi_0", "M", "r_h") )

# plot again
plot( as.mcmc( runanother$chain) )

runanother$acceptance.rate

newinitpars = runanother$chain[ nrow(runanother$chain), ]
newcovmat = cov(runanother$chain)

# test = adjustproposal(initialrun = test, acceptrange = c(0.26,0.35), Nsteps = 500, yourpatience = 15, mydat = mydata, logDF = logDF.limepy, priors = prior.wrapper, transform.pars = notransform.func, priorfuncs = list( singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior ), ppars = list( gbounds, phi0bounds, log10Mpars, rhpars ), propDF = mypropDF, parnames = c("g", "Phi_0", "M", "r_h"))


runfinal = GCmcmc( init = newinitpars, mydat = mydata, logDF = logDF.limepy, priors = prior.wrapper, N = 5e3,
                     transform.pars = notransform.func,
                     priorfuncs = list( singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior ),
                     ppars = list( gbounds, phi0bounds, log10Mpars, rhpars ),
                     propDF = mypropDF, covmat = newcovmat,
                     parnames = c("g", "Phi_0", "M", "r_h"), thinning = 5 )

plot( as.mcmc(runfinal$chain))


saveRDS(object = runfinal, file = paste("../results/prelim_mcmc_", Sys.Date()))

        
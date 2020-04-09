# initial run with snap data

source("script_set-up-SPES_simGCstars.r")

library(coda)

# initial run
runinit = GCmcmc(init = initpars, mydat = mydata, logDF = logDF.spes, priors = prior.wrapper, N = 5e3, 
                 transform.pars = notransform.func, 
                 priorfuncs = list( singleunif.prior, singleunif.prior, singleunif.prior, normlog10M.prior, gaus.prior ), ppars = list( phi0bounds, Bbounds, etabounds, log10Mpars, rhbounds ),
                 propDF = mypropDFspes, covmat = covariancematrix
)

# look at the parameter chains
plot( as.mcmc( runinit$chain) ) 

newcovmat = cov( runinit$chain )

newinitpars = runinit$chain[ nrow(runinit$chain), ]

runanother = GCmcmc(init = newinitpars, mydat = mydata, logDF = logDF.spes, priors = prior.wrapper, N = 1e3, transform.pars = notransform.func, priorfuncs = list( singleunif.prior, singleunif.prior, singleunif.prior, normlog10M.prior, gaus.prior ), ppars = list( phi0bounds, Bbounds, etabounds, log10Mpars, rhbounds ), propDF = mypropDFspes, covmat = newcovmat, parnames = c("Phi_0", "B", "eta", "M", "r_h")
)

# plot again
plot( as.mcmc( runanother$chain) )

runanother$acceptance.rate

newinitpars = runanother$chain[ nrow(runanother$chain), ]


test = adjustproposal(acceptrange = c(0.26,0.42), Nsteps = 500, yourpatience = 15, initcovmat = newcovmat, initlogpars = newinitpars, mydat = mydata, logDF = logDF.spes, priors = prior.wrapper, transform.pars = notransform.func, priorfuncs = list( singleunif.prior, singleunif.prior, singleunif.prior, normlog10M.prior, gaus.prior ), ppars = list( phi0bounds, Bbounds, etabounds, log10Mpars, rhbounds ), propDF = mypropDFspes, parnames = cc("Phi_0", "B", "eta", "M", "r_h"))

plot( as.mcmc(test$chain))



saveRDS(object = test, file = paste("../results/prelim_mcmc_", Sys.Date()))

        


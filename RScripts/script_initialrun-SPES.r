# initial run with snap data

source("script_set-up-SPES_simGCstars.r")

library(coda)

# initial run
runinit = GCmcmc(init = initpars, mydat = mydata, logDF = logDF.spes, priors = prior.wrapper, N = 5e3, 
                 transform.pars = notransform.func, 
                 priorfuncs = list( singleunif.prior, singleunif.prior, singleunif.prior, normlog10M.prior, rhGaussianPrior ), ppars = list( phi0bounds, Bbounds, etabounds, log10Mpars, rhbounds ),
                 propDF = mypropDFspes, covmat = covariancematrix, parnames = c("Phi_0", "B", "eta", "M", "r_h"))

# look at the parameter chains if you want
plot( as.mcmc( runinit$chain) )

# look at the "chain" of values of the likelihood*prior at every step
plot( as.mcmc( runinit$logDFchain) )


# adjust covariance matrix for proposal distribution using automated 
results = adjustproposal(acceptrange = c(0.2,0.4), Nsteps = 500, yourpatience = 10, initialrun = runinit,
                      mydat = mydata, logDF = logDF.spes, priors = prior.wrapper, transform.pars = notransform.func, 
                      priorfuncs = list( singleunif.prior, singleunif.prior, singleunif.prior, normlog10M.prior, rhGaussianPrior ), 
                      ppars = list( phi0bounds, Bbounds, etabounds, log10Mpars, rhbounds ), 
                      propDF = mypropDFspes, parnames = c("Phi_0", "B", "eta", "M", "r_h"))


plot(as.mcmc(results$chain))


# save the chain
saveRDS(object = results, file = paste("../results/prelim_mcmc_narrow-rh-prior_normin", nsamp, Sys.Date(), sep="_"))

        


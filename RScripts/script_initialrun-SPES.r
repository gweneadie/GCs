# initial run with snap data

source("script_set-up-SPES_simGCstars.r")

library(coda)

# initial run
runinit = GCmcmc(init = initpars, mydat = mydata, logDF = logDF.spes, priors = prior.wrapper, N = 1e3, transform.pars = notransform.func, priorfuncs = list( singleunif.prior, singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior ), ppars = list( phi0bounds, Bbounds, etabounds, log10Mpars, rhpars ), propDF = mypropDFspes, covmat = covariancematrix, parnames = c("Phi_0", "B", "eta", "M", "r_h"))

# look at the parameter chains if you want
plot( as.mcmc( runinit$chain), cex.lab=2, cex.main=2, cex.axis=2 )


# adjust covariance matrix for proposal distribution using automated 
results = adjustproposal(acceptrange = c(0.2,0.4), Nsteps = 500, yourpatience = 20, initialrun = runinit,
                      mydat = mydata, logDF = logDF.spes, priors = prior.wrapper, transform.pars = notransform.func, 
                      priorfuncs = list( singleunif.prior, singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior ), 
                      ppars = list( phi0bounds, Bbounds, etabounds, log10Mpars, rhpars ), 
                      propDF = mypropDFspes, parnames = c("Phi_0", "B", "eta", "M", "r_h"))


plot(as.mcmc(results$chain))

# with proposal distribution set, run a longer chain
finalrun = GCmcmc(init = initpars, mydat = mydata, logDF = logDF.spes, priors = prior.wrapper, N = 5e3, 
                 transform.pars = notransform.func, 
                 priorfuncs = list( singleunif.prior, singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior ), ppars = list( phi0bounds, Bbounds, etabounds, log10Mpars, rhpars ),
                 propDF = mypropDFspes, covmat = newcovmat, parnames = c("Phi_0", "B", "eta", "M", "r_h"), thinning = 2)


plot(as.mcmc(finalrun$chain))
# save the chain
saveRDS(object = runinit, file = paste("../results/prelim_mcmc_truncnorm-rh-prior_normin", nsamp, Sys.Date(), sep="_"))

        


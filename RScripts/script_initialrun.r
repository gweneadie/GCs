# load the optimization file that has good starting parameters
# DEoptim <- readRDS(file = paste0("../results/paper1results/DEoptim_", modelname, "_", filename, "_", Sys.Date(), ".rds"))

# use DEopt xbest pars as initial parameters for first mcmc run
initpars <- DEoptim$xbest

############## Initial mcmc run
runinit = GCmcmc(init = initpars, mydat = mydata, logLike = logLike.limepy, priors = prior.wrapper, N = 500, 
                 transform.pars = notransform.func, 
                 priorfuncs = list( singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior ),
                 ppars = list( gbounds, phi0bounds, log10Mpars, rhpars ),
                 propDF = mypropDF, covmat = covariancematrix, n.pars=4,
                 parnames = c("g", "Phi0", "M", "rh"))


# save initial run to file
#saveRDS(object = runinit, file = paste0("../results/paper1results/initrun_", modelname, "_", filename, "_", Sys.Date(), ".rds"))

############## Finite adaptive mcmc run (burn in)
newrun = adjustproposal(initialrun = runinit, acceptrange = c(0.26,0.4), Nsteps = 250, yourpatience = 10, mydat = mydata, logLike = logLike.limepy, priors = prior.wrapper, transform.pars = notransform.func, priorfuncs = list( singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior ), ppars = list( gbounds, phi0bounds, log10Mpars, rhpars ), propDF = mypropDF, parnames = c("g", "Phi_0", "M", "r_h"), n.pars=4, minrun=7)

# save burn-in to file
saveRDS(newrun, file = paste0("../results/paper1results/Regen_highPhi0/burnin_", modelname, "_", filename, "_", Sys.Date(), ".rds") )

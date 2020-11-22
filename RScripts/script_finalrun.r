library(coda)

#burnindate <- Sys.Date()

#burnin <- readRDS(file = paste0("../results/paper1results/burnin_", modelname, "_", filename, "_", burnindate, ".rds") )


# final run after burnin
finalrun <- GCmcmc(init = burnin$newinitpars, mydat = mydata, logLike = logLike.limepy, priors = prior.wrapper, N = 1e4, transform.pars = notransform.func, priorfuncs = list( singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior ), ppars = list( gbounds, phi0bounds, log10Mpars, rhpars ), propDF = mypropDF, parnames = c("g", "Phi_0", "M", "r_h"), n.pars=4, covmat=burnin$newpropsd, thinning = 2)
       

# save chain to file
saveRDS(object = finalrun, file = paste0("../results/paper1results/RegenCompact/chain_", modelname, "_", filename, "_", Sys.Date(), ".rds") )

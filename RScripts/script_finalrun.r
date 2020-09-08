library(coda)

burnindate <- "2020-09-08"

newrun <- readRDS(file = paste0("../results/burnin_LIMEPYdata_500_LIMEPYmodel_", filename, "_", burnindate, ".rds") )


# final run after burnin
finalrun <- GCmcmc(init = newrun$newinitpars, mydat = mydata, logLike = logLike.limepy, priors = prior.wrapper, N = 5e3, transform.pars = notransform.func, priorfuncs = list( singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior ), ppars = list( gbounds, phi0bounds, log10Mpars, rhpars ), propDF = mypropDF, parnames = c("g", "Phi_0", "M", "r_h"), n.pars=4, covmat=newrun$newpropsd)
       

# save chain to file
saveRDS(object = finalrun, file = paste0("../results/chain_LIMEPYdata_500_LIMEPYmodel_", filename, "_", burnindate, "_", Sys.Date(), ".rds") )

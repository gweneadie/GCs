############# Source libraries and functions needed
library(MASS)
library(coda)

source("function_GCmcmc.r")
source("function_proposal-distribution-modelpars.r")
source("function_transform-parameters.r")
source("function_iswhole.r")
source("function_adjustproposal.r")
source("function_priors.r")
source("function_prior-wrapper.r")
# source limepy function that uses reticulate
source("function_logLike_LIMEPY.r")
# log target density that will be used with optim()
source("function_logtargetdensity.r")

############## Optim run to get starting parameters
# some test parameters for g, phi0, M, and rh
gtest = 1.5
phi0test = 5.0
Mtest = 1e5
rhtest = 8.0
testpars <- c(gtest, phi0test, Mtest, rhtest)

test <- optim(par = testpars, fn = targetdensity, mydat = mydata, logLike = logLike.limepy, priorfuncs = list(singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior), ppars = list( gbounds, phi0bounds, log10Mpars, rhpars), control=list(fnscale=-1) )

print(test)

test2 <- optim(par = test$par, fn = targetdensity, mydat = mydata, logLike = logLike.limepy, priorfuncs = list(singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior), ppars = list( gbounds, phi0bounds, log10Mpars, rhpars), control=list(fnscale=-1) )

print(test2)

# save optim results to a file
saveRDS(test2, file = paste0("../results/optim_LIMEPYdata_LIMEPYmodel", filename, Sys.Date(), ".rds"))

# use optim pars as initial parameters for first mcmc run
initpars <- test2$par

############## Initial mcmc run
runinit = GCmcmc(init = initpars, mydat = mydata, logLike = logLike.limepy, priors = prior.wrapper, N = 500, 
                 transform.pars = notransform.func, 
                 priorfuncs = list( singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior ),
                 ppars = list( gbounds, phi0bounds, log10Mpars, rhpars ),
                 propDF = mypropDF, covmat = covariancematrix, n.pars=4,
                 parnames = c("g", "Phi0", "M", "rh"))

# save initial run to file
saveRDS(object = runinit, file = paste0("../results/initrun_LIMEPYdata_500_LIMEPYmodel_", filename, "_", Sys.Date(), ".rds"))

############## Finite adaptive mcmc run (burn in)
newrun = adjustproposal(initialrun = runinit, acceptrange = c(0.26,0.4), Nsteps = 250, yourpatience = 10, mydat = mydata, logLike = logLike.limepy, priors = prior.wrapper, transform.pars = notransform.func, priorfuncs = list( singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior ), ppars = list( gbounds, phi0bounds, log10Mpars, rhpars ), propDF = mypropDF, parnames = c("g", "Phi_0", "M", "r_h"), n.pars=4)

# save burn-in to file
saveRDS(newrun, file = paste("../results/burnin_LIMEPYdata_500_LIMEPYmodel_", filename, "_", Sys.Date(), ".rds", sep="") )

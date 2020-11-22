
# use optim to find the maximum and the second derivative of the likelihood times prior

# initial parameters g, phi0, M (in solar masses), rh
initpars = c(1.45, 5.1, 110000., 1.5)


# DEopt only does minimization, so make a wrapper to targetdensity that gives the negative of targetdensity
temptarg <- function(init, mydat, logLike, priors=prior.wrapper, ... ){
  -targetdensity(init, mydat, logLike, priors=prior.wrapper, ...)
}

test <- DEopt(OF = temptarg, algo = list (min=c(gbounds[1], phi0bounds[1], 1, rhpars[1]), max=c(gbounds[2], phi0bounds[2], 5e6, rhpars[2])), mydat = mydata, logLike = logLike.limepy, priorfuncs = list(singleunif.prior, singleunif.prior, normlog10M.prior, truncnorm.prior), ppars = list( gbounds, phi0bounds, log10Mpars, rhpars))



# save optim results to a file
saveRDS(test, file = paste0("../results/paper1results/RegenCompact/DEoptim_", modelname, "_", filename, "_", Sys.Date(), ".rds"))



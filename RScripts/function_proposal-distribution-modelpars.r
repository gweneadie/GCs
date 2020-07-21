library(MASS)
# proposal distribution
mypropDF <- function(npars, covmat) mvrnorm(Sigma=covmat, mu=rep(0, npars) )


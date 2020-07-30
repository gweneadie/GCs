library(MASS)
# proposal distribution
mypropDF <- function(n.pars, covmat, ...) mvrnorm(Sigma=covmat, mu=rep(0, n.pars) )


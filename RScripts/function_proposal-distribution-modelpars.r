# proposal distribution
mypropDF <- function(covmat, ...) mvrnorm(Sigma=covmat, mu=c(0,0,0,0) )

mypropDFspes <- function(covmat, ...) mvrnorm(Sigma=covmat, mu=c(0,0,0,0,0))

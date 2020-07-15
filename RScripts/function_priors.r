########### Gaussian prior
gaus.prior <- function( pars, ppars ){
  
  dnorm(x = pars, mean = ppars[1], sd = ppars[2])
  
}

########### Log-Normal prior
lnorm.prior <- function( pars, ppars ){
  
  dlnorm(x = pars, meanlog = ppars[1], sdlog = ppars[2])
  
}


########### Normal prior on log10M
normlog10M.prior <- function(pars, ppars ){
  
  if( pars<=0 ){ return(0) }else{
    dnorm(x = log10(pars), mean = ppars[1], sd = ppars[2])/(pars * log(10))
  }
  
}

######### Uniform (truncated) prior function
singleunif.prior <- function( pars, ppars ){
  
  # bounds of truncated prior
  par.min = ppars[1]
  par.max = ppars[2]
  
  # if parameter is held fixed...
  if( par.min==par.max ){ priorvalue = 1 }else{
    # calculated uniform prior value at pars
    priorvalue = 1/(par.max - par.min) * ( par.min <= pars  &  pars <= par.max )
  }
  
  priorvalue
  
}

########### Truncated normal prior
library(truncnorm)
truncnorm.prior <- function(pars, ppars){
  
  # pars must be given in the correct order as shown below
  dtruncnorm(x = pars, a = ppars[1], b = ppars[2], mean = ppars[3], sd = ppars[4])
  
}

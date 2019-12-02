########### Gaussian prior
gaus.prior <- function( pars, ppars ){
  
  dnorm(x = pars, mean = ppars[1], sd = ppars[2])
  
}

########### Log-Normal prior
lnorm.prior <- function( pars, ppars ){
  
  dlnorm(x = pars, meanlog = ppars[1], sdlog = ppars[2])
  
}

######### Uniform (truncated) prior function
singleunif.prior <- function( pars, ppars ){
  
  # bounds of truncated prior
  par.min = ppars[1]
  par.max = ppars[2]
  
  # if parameter is held fixed...
  if( par.min==par.max ){
    priorvalue = 1
  }else{
    # calculated uniform prior value
    priorvalue = 1/(par.max - par.min) * ( par.min <= pars  &  pars <= par.max )
  }
  
  priorvalue
  
}

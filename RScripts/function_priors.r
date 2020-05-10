########### Gaussian prior
gaus.prior <- function( pars, ppars ){
  
  dnorm(x = pars, mean = ppars[1], sd = ppars[2])
  
}

########### Log-Normal prior
lnorm.prior <- function( pars, ppars ){
  
  dlnorm(x = pars, meanlog = ppars[1], sdlog = ppars[2])
  
}

########### Log10-Normal prior
l10norm.prior <- function( pars, ppars ){
  
  log10(exp(1))  / ( pars*ppars[2]*sqrt(2*pi) ) * exp( - ( log10(pars) - ppars[1] )^2 / (2*ppars[2]^2)  )
  
}

########### Normal prior on log10M
normlog10M.prior <- function(pars, ppars ){
  
  if( pars<=0 ){ return(0) }else{
    dnorm(x = log10(pars), mean = ppars[1], sd = ppars[2])
  }
  
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

rhGaussianPrior <- function( pars, ppars ){
  
  if( pars<=0 ){ return(0) }else{
    dnorm(x = pars, mean = ppars[1], sd = ppars[2])
  }
  
}

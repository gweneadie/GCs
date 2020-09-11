# write a function to calculate the log target density
targetdensity <- function(init, mydat, logLike, priors=prior.wrapper, ... ){
  
  if( any( !is.finite(log(priors(pars = init, ...)))) ){ return(-Inf)}
  
  sum( logLike( pars=init, dat=mydat ) ) + sum( log( priors( pars = init, ... ) ) )
}
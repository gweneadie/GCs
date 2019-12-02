######## wrapper for prior when different prior distributions are being used for different model parameters 

prior.wrapper = function(pars, priorfuncs, ppars, ...){
  
  if( length(priorfuncs) != length(pars) ){ stop("Error: number of prior functions doesn't match number of parameters")}
  
  # make object for output
  priorvalues = rep(NA, length=length(pars))
  
  for( i in 1:length(pars) ){
    priorvalues[i] = priorfuncs[[i]](pars[i], ppars[[i]])
  }
  
  priorvalues
  
}

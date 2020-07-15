library("reticulate")

use_python("/usr/bin/python3")
limepy <- import("limepy")


# function to take in limepy$df function and data

# GME logPDF function format:
# logPDF( pars=init, dat=dat.current, DF=DF, pot=pot, transform.pars=transform.pars )

logDF.limepy = function(pars, dat, transform.pars=NULL, pot=NULL, DF=NULL){
 
  # transform parameters 
  if( !is.null( transform.pars ) ){  pars = transform.pars( pars ) }
  
  # if the half-light radius or total mass parameters are negative, then return -Inf for every data point
  if(pars[3]<0 | pars[4]<0){ return( rep( -Inf, nrow(dat) ) ) }
  
  # numerically determine the df given the parameter values
  # here, pars[1] = g ; pars[2] = phi0 ; pars[3] = M, pars[4] = rh
  lmodel = try( limepy$limepy(g=pars[1], phi0=pars[2], M=pars[3], rh=pars[4]), silent = TRUE)
  
  if( any(class(lmodel)=="try-error") ){ output = rep( -Inf, nrow(dat) ) }else{
    
    # calculate log-likelihood (log( DF/M_total) ), using GC-centered coordinates
    output = try( log( ( lmodel$df( dat$r, dat$v ) )/pars[3] ), silent=TRUE )
    
    if( any(class(output)=="try-error") ){ output = rep( -Inf, nrow(dat) ) }
    
  }
    
  output
  
}


library("reticulate")

use_python("/usr/bin/python3")
limepy <- import("limepy")


##### function to take in limepy$df function and dat.try
# pars: vector of model parameter values
# dat: dataframe of data
# transform.pars: list of functionc to transform parameters
 

logDF.spes = function(pars, dat, transform.pars=NULL){
 
  # transform parameters 
  if( !is.null( transform.pars ) ){
    pars = transform.pars( pars )
  }
  
  # pars[1] = phi0 ; pars[2] = B ; pars[3] = eta, pars[4] = M, pars[5] = rh
  
  lmodel = try(limepy$spes(phi0 = pars[1], B = pars[2], eta = pars[3], M = pars[4], rh=pars[5]), silent=TRUE)
 
  # if there is an error then return -Inf
  if( any(class(lmodel)=="try-error") ){
    
    output = -Inf
    
  }else{
    
    # if there is not an error, then pass data (r, v in GC-centered coordinates) to df
    output = try(log( lmodel$df( dat$r, dat$v ) ), silent = TRUE)
    
    if( any(class(output)=="try-error") ){
      output = -Inf
    }
    
  }

  output
  
}


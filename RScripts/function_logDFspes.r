library("reticulate")

use_python("/usr/bin/python3")
limepy <- import("limepy")


# function to take in limepy$df function and dat.try

# GME logPDF function format:
# logPDF( pars=init, dat=dat.current, DF=DF, pot=pot, transform.pars=transform.pars )

logDF.spes = function(pars, dat, transform.pars=NULL, pot=NULL, DF=NULL){
 
  # transform parameters 
  if( !is.null( transform.pars ) ){
    pars = transform.pars( pars )
  }
  
  # pars[1] = phi0 ; pars[2] = B ; pars[3] = eta, pars[4] = M, pars[5] = rh
  
  lmodel = try(limepy$spes(phi0 = pars[1], B = pars[2], eta = pars[3], M = pars[4], rh=pars[5]), silent=TRUE)
 
  # if there is an error
  if( any(class(lmodel)=="try-error") ){
    
    output = -Inf
    
  }else{
    
    # code takes in r, v in GC-centered coordinates
    output = try(log( lmodel$df( dat$r, dat$v ) ), silent = TRUE)
    if( any(class(output)=="try-error") ){
      output = -Inf
    }
    
  }

  output
  
}


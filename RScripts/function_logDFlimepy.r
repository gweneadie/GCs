library("reticulate")

use_python("/usr/bin/python3")
limepy <- import("limepy")


# function to take in limepy$df function and dat.try

# GME logPDF function format:
# logPDF( pars=init, dat=dat.current, DF=DF, pot=pot, transform.pars=transform.pars )

logDF.limepy = function(pars, dat, transform.pars=NULL, pot=NULL, DF=NULL){
 
  # transform parameters 
  if( !is.null( transform.pars ) ){
    pars = transform.pars( pars )
  }
  
  # pars[1] = g ; pars[2] = phi0 ; pars[3] = M, pars[4] = rh
  
  lmodel = limepy$limepy(g=pars[1],phi0=pars[2],M=pars[3],rh=pars[4])
  
  # code takes in r, v in GC-centered coordinates
  output = log( lmodel$df( dat$r, dat$v ) )
  # output = log( lmodel$df( dat[,1], sqrt(dat[,2]^2 + dat[,3]^2) ) )
  
  output
  
}


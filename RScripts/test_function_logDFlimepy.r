library("reticulate")

use_python("/usr/bin/python3")
limepy <- import("limepy")


# function to take in limepy$df function and dat.try

# GME logPDF function format:
# logPDF( pars=init, dat=dat.current, DF=DF, pot=pot, transform.pars=transform.pars )

logDF.limepy = function(dat, pars, transform.pars=NULL, pot=NULL, DF=NULL){
 
  # transform parameters 
  if( !is.null( transform.pars ) ){
    pars = transform.pars( pars )
  }
  
  # pars[1] = g ; pars[2] = phi0 ; pars[3] = M, pars[4] = rh
  
  lmodel = limepy$limepy(g=pars[1],phi0=pars[2],M=pars[3],rh=pars[4])
  
  # r, v = sqrt(v_r^2 + v_t^2)
  output = log( lmodel$df( dat[,1], sqrt(dat[,2]^2 + dat[,3]^2) ) )
  
  output
  
}

# check what limepy gives you
lmodel = limepy$limepy(g=1.,phi0=5.,M=1000.,rh=3.)

log ( lmodel$df( c(5., 1., 0), c(sqrt(10 + 9^2), 1., 0) ) )

# check what logDF.limepy gives you
logDF.limepy( dat=cbind( c(5, 1, 0), c(sqrt(10.), 1., 0.), c(9., 0., 0.) ), pars = c(1.,5.,1000.,3.) )

logDF.limepy(dat = cbind(5., 1., 0.), pars = c(1.,5.,1000.,3.))

# NOTE: default class in R is double precision numeric, not integer. Need to do, e.g. 1L to make something stored as an integer. However, 1:10 will return a sequence of integers

# Questions:
# - is integer default in python 3?
# - what would be appropriate prior distributions for g, phi0, M, and rh for a globular cluster?
# - why do I get a number when r = 0 and v = 0 ?

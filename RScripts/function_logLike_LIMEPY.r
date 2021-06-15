library("reticulate")

yoursystem <- Sys.info()["sysname"]

if(yoursystem=="Windows"){
  # if on my desktop, then use the virtual environment
  use_condaenv("/Users/Gwen/miniconda3/envs/r-reticulate-GCs/") 
}else{ if(yoursystem=="Linux"){
  # if on my laptop, then use this version of Python
  use_python("/usr/bin/python3")
}else{
  stop("It looks like you aren't using one of Gwen's computers. You'll need to set up your own virtual python environment with limepy installed in it, and then tell the R reticulate package where to find the environment. Good luck!")
}
}


limepy <- import("limepy")


# function to take in limepy$df function and data

# logPDF function format in mcmc call expects:
# logPDF( pars=init, dat=mydat, DF=DF, pot=pot, transform.pars=transform.pars )

logLike.limepy = function(pars, dat, transform.pars=NULL, pot=NULL, DF=NULL){
 
  # transform parameters 
  if( !is.null( transform.pars ) ){  pars = transform.pars( pars ) }
  
  # if ANY parameters are negative, then return -Inf for every data point
  if( any(pars<0) ){ return( rep( -Inf, nrow(dat) ) ) }
  
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


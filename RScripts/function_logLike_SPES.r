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


##### distribution function from the SPES model
# pars: vector of model parameter values that must be in this order:
      # pars[1] = phi0 ; pars[2] = B ; pars[3] = eta, pars[4] = M, pars[5] = rh
# dat: dataframe of data with numeric columns distance r and speed v
# transform.pars: list of functionc to transform parameters if sampling in a difference space
 

logLike.spes = function(pars, dat, transform.pars=NULL){
 
  # transform parameters 
  if( !is.null( transform.pars ) ){  pars = transform.pars( pars )  }
  
  # if any parameters are negative, then return -Inf for every data point
  if( any(pars<0) ){ return( rep( -Inf, nrow(dat) ) ) }
  
  # numerically determine the df given the parameter values
  lmodel = try(limepy$spes(phi0 = pars[1], B = pars[2], eta = pars[3], M = pars[4], rh=pars[5]), silent=TRUE)
 
  # if there is an error because of bad parameter values (i.e. unphysical model) then open a browser to see what's happening. Return -Inf
  if( any(class(lmodel)=="try-error") ){ output = rep( -Inf, nrow(dat) ) }else{
    
    # if there is not an error, then calculate likelihood of the data (r, v in GC-centered coordinates)
    output = try( log( (lmodel$df( dat$r, dat$v )) /pars[4] ), silent = TRUE)
    
    if( any(class(output)=="try-error") ){ output = rep( -Inf, nrow(dat) ) }
    
  }

  output
  
}


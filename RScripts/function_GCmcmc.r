##### Globular Cluster mass estimator with mcmc

# init: vector of initial model parameters
# mydat: dataframe of data
# logLike: log of the likelihood
# priors: list of functions for prior distribution that take in argument pars, ...
# N: integer, number of samples in final Markov chain
# transform.pars: list of functions that transform parameters to another space
# propDF: function, proposal distribution
# thinning: integer to thin Markov chain (i.e. if thinning=10, then only every 10th parameter is saved in the chain)
# progressBar: logical, default TRUE. Controls whether the user sees a progress bar
# parnames: optional character vector for the parameter names

library(coda)

GCmcmc <- function(init, mydat, logLike, priors, N, transform.pars, propDF, thinning=1, progressBar=TRUE, parnames = NULL, ...){
  
  # check that initial paramters are OK with the priors
  testpriors = sum( log( priors( pars = transform.pars(init), ... ) ) )

  if( any( !is.finite(testpriors) ) ){ stop("bad initial model parameters for priors")}
  
  # check that initial guess of parameters are OK
  testpars = logLike( pars=init, dat=mydat, transform.pars = transform.pars )

  if( any( !is.finite(testpars) ) ){ stop("bad initial model parameters") }
  

  # get number of data points
  ndat = nrow(mydat)
  
  # get number of parameters
  npars = length(init)
  
  # set up chain
  chain = matrix( ncol=npars, nrow=N )
  chain[1, ] = init
  
  # make a chain of the logLike values
  logLikechain = matrix( ncol=1, nrow=N )

  # counter to keep track of acceptances
  accept = 0
  
  # make a progress bar if asked for
  if( progressBar ){
      pb <- txtProgressBar(min = 0, max = N*thinning, style = 3)
  }
  
  # make the Markov Chain
  for( i in 2:(N*thinning) ){
      
      # draw trial model parameters
      partry = init + propDF(...)
      
      # value of log priors at new parameters
      logpriorstry = sum( log( priors( pars = transform.pars( partry ), ... ) ) )
      
      # if any of the new pars return 0 probability from prior, then reject points
      if( any( !is.finite(logpriorstry) ) ){
        
        if(is.whole(i/thinning)){ 
          chain[i/thinning, ] = init 
        }
        
      }else{
       
        # find value of log likelihood at new parameters
        logLiketry = sum( logLike( pars=partry, dat=mydat, transform.pars=transform.pars ))
        
        # if any of the new pars return -Inf from the log likelihood, then reject points
        if( any( !is.finite(logLiketry) ) ){
          
          if(is.whole(i/thinning)){ 
            chain[i/thinning, ] = init 
          }
          
        }else{
          
          # calculate priors for previous parameters
          logpriorsinit = sum( log( priors( pars = transform.pars( init ), ... ) ) )
          
          # difference of logs of likelihood*prior for init and partry
          difflog = logLiketry + logpriorstry - sum( logLike( pars=init, dat=mydat, transform.pars=transform.pars )) - logpriorsinit 
        
          # if this gives a non-numeric answer, something is up, so open a browser
          if( !is.numeric(difflog) ){ browser() }
          
          # if difflog is positive or if exponential of difflog is greater than a randomly generated number between 0 and 1, then accept
          if( difflog > 0 | ( difflog > log( runif(1) ) ) ){
            
            # if the ith element is a multiple of thinning, then save the value in the chain
            if(is.whole(i/thinning)){ 
              chain[i/thinning, ] = partry 
            }
            
            # update initial value and track the acceptance
            init = partry
            accept = accept + 1
            
          }
            
        }

      }
      
      # print progress bar if progressBar=TRUE
      if( progressBar ){ setTxtProgressBar(pb, i/thinning) }
      
  } # close for loop that makes MC
  
  if( !is.null(parnames) ){ colnames(chain) = parnames }
  
  # OUTPUT    
  out = list(chain=as.mcmc(chain), acceptance.rate = accept/N, dat = mydat, priorfuncs=priors)
  
}

  
  

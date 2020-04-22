### adaptive tuning function 

# acceptrange: vector of length 2 with lower and upper bounds of "acceptable" acceptance rate
# yourpatience: how many iterations of the adaptive algorithm you are willing to wait
# Nsteps: interger, number of steps in each iteration
# initcovmat: the initial covariance matrix to be used for the proposal distribution
# initpars: vector of initial paramter values
# ...: other aguments to be passed to GCmcmc

adjustproposal = function(acceptrange = c(0.2,0.4), yourpatience, Nsteps, initcovmat, initpars, ... ){
  
  # start patience count
  count = 1
  
  # acceptable range for acceptance rates for easier reading
  accept.lower <- acceptrange[1]
  accept.upper <- acceptrange[2]
  
   # run the chain for a bit, using the initial covariance matrix for the parameters
  initialrun = GCmcmc(N = Nsteps, covmat = initcovmat, init = initpars, ...)
  
  # change to new initial values (i.e. where chain stopped)
  newinitpars <- as.numeric( initialrun$chain[Nsteps, ] )
  
  # new covariance matrix from initial run
  newcovmat = cov(initialrun$chain)
  
  # check acceptance rates
  goodacceptancerate = (initialrun$acceptance.rate < accept.upper) & (initialrun$acceptance.rate > accept.lower)
      
  if( goodacceptancerate ){ combinedrun = initialrun$chain}
    
  # while the acceptance rate is bad and the count is less than your patience, or if this is the first iteration.
  while( (!goodacceptancerate) && (count<yourpatience) | count==1 ){
    
    # add to the count for your patrience
    count = 1 + count
    
    # run a new chain, starting where the last one stopped and with the new covariance matrix for the proposal
    newrun = GCmcmc(N = Nsteps, covmat = newcovmat, init = newinitpars, ...)
    
    # save new initial values (i.e. where chain stopped)
    newinitpars <- as.numeric( newrun$chain[Nsteps, ] )

    
    if( count==2 ){
      # combine initial chain and new chain together
      combinedrun = rbind(initialrun$chain, newrun$chain)
    }else{
      # combine new chain with all previous old chains
      combinedrun = rbind(combinedrun, newrun$chain)
    }
    
    # get new covariance matrix using all previous runs
    newcovmat = cov(combinedrun)
    
    # print the count for the user so they know what's happening
    print(paste("count =", count, sep=" "))
    
  }
  
  # output everything of possible value in a list
  out = list(newpropsd = newcovmat, chain = combinedrun, patiencemeter = count, newinitpars = newinitpars, acceptancerate = newrun$acceptance.rate)
  
  out
  
  
}


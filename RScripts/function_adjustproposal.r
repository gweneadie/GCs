### adaptive tuning function 

# acceptrange:    vector of length 2 with lower and upper bounds of "acceptable" acceptance rate
# yourpatience:   how many iterations of the adaptive algorithm you are willing to wait
# Nsteps:         interger, number of steps in each iteration
# initialrun:    a list that was returned from an initial run of GCmcmc()
# ...:            other aguments to be passed to GCmcmc

adjustproposal = function(acceptrange = c(0.2,0.4), yourpatience, Nsteps, initialrun, minrun=5, ... ){
  
  # start patience count
  count = 1
  
  # acceptable range for acceptance rates for easier reading
  accept.lower <- acceptrange[1]
  accept.upper <- acceptrange[2]
  
    # check acceptance rates
  goodacceptancerate = (initialrun$acceptance.rate < accept.upper) & (initialrun$acceptance.rate > accept.lower)
  
  # save only chain to use in next part
  initialchain = initialrun$chain
  
  # while the acceptance rate is bad and the count is less than your patience, or if this is the first to fifth iteration.
  while( (!goodacceptancerate) && (count<yourpatience) | count<=minrun ){
    
    # change to new initial values (i.e. where chain stopped)
    newinitpars <- as.numeric( initialchain[nrow(initialchain), ] )
    
    # new covariance matrix from initial run
    newcovmat = cov(initialchain)
    
    # run a new chain, starting where the last one stopped and with the new covariance matrix for the proposal
    newrun = GCmcmc(N = Nsteps, covmat = newcovmat, init = newinitpars, ...)
    
    # check acceptance rate
    goodacceptancerate = (newrun$acceptance.rate < accept.upper) & (newrun$acceptance.rate > accept.lower)
    
    # combine new run with previous runs
    initialchain = rbind(initialchain, newrun$chain)
    
    # add to the count for your patrience
    count = 1 + count
    
    # print the count for the user so they know what's happening
    print(paste("count =", count, sep=" "))
    
  }
  
  # output everything of possible value in a list
  out = list(newpropsd = newcovmat, chain = initialchain, lastchain = newrun, patiencemeter = count, newinitpars = newinitpars, acceptancerate = newrun$acceptance.rate)
  
  out
  
  
}


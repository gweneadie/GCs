# adaptive tuning function 

adjustproposal = function(acceptrange = c(0.2,0.4), yourpatience, Nsteps, initcovmat, initlogpars, ... ){
  
  # start patience count
  count = 1
  
  # get acceptable range for acceptance rates
  accept.lower <- acceptrange[1]
  accept.upper <- acceptrange[2]
  
   # run the chain for a bit, using the initial covariance matrix for the parameters
  initialrun = GCmcmc(N = Nsteps, covmat = initcovmat, init = initlogpars, ...)
  
  # change to new initial values (i.e. where chain stopped)
  newinitlogpars <- as.numeric( initialrun$chain[Nsteps, ] )
  
  # new covariance matrix from previous run
  newcovmat = cov(initialrun$chain)
  
  # check acceptance rates
  goodacceptancerate = (initialrun$acceptance.rate < accept.upper) & (initialrun$acceptance.rate > accept.lower)
      
  if( goodacceptancerate ){ combinedrun = initialrun$chain}
    
  while( #(!goodacceptancerate) &f
    count<yourpatience | count==1 ){
    
    # add to the count for your patrience
    count = 1 + count
    
    # run a new chain
    newrun = GCmcmc(N = Nsteps, covmat = newcovmat, init = newinitlogpars, ...)
    
    # change to new initial values (i.e. where chain stopped)
    newinitlogpars <- as.numeric( newrun$chain[Nsteps, ] )

    
    if( count==2 ){
      # combine old and new together
      combinedrun = rbind(initialrun$chain, newrun$chain)
      
    }else{
      combinedrun = rbind(combinedrun, newrun$chain)
    }
    
    # new covariance matrix from previous run
    newcovmat = cov(combinedrun)
    
    print(paste("count =", count, sep=" "))
    
  }
  
  out = list(newpropsd = newcovmat, chain = combinedrun, patiencemeter = count, newinitlogpars = newinitlogpars, acceptancerate = newrun$acceptance.rate)
  out
  
  
}


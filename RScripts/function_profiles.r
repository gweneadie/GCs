# function to calculate density profile from limepy model parameters

library("reticulate")

use_python("/usr/bin/python3")
limepy <- import("limepy")


profiles <- function(pars){
  
  # for a set of parameter values, calculate the model, and save the r, phi, and rho values
  
  # calculate the limepy model
  model <- limepy$limepy(g = pars[1], phi0 = pars[2], M = pars[3], rh = pars[4])
  
  # put the r, gravitational potential and density into a data frame
  rphirho <- data.frame(r=model$r, phi=-(model$phi), rho=model$rho)
  
  rphirho
  
}


massprofile <- function(pars){
  
  # for a set of parameter values, calculate the model, and then estimate the cumulative mass profile
  
  # calculate the limepy model
  model <- limepy$limepy(g = pars[1], phi0 = pars[2], M = pars[3], rh = pars[4])
  
  nr <- length(model$r)
 
  # matrix of rs and y to integrate
  output <- data.frame(r=model$r, integrand=4*pi*model$rho*(model$r^2))
  output$mass[1] <- 0
  
  # obtain spline function that will be used to integrate
  myfunction <- splinefun(x = model$r, y = 4*pi*model$rho*(model$r^2), method="natural")
  
  # integrate each section to get cumulative mass profile
    for(i in 2:nr){
   output$mass[i] <- integrate(f = myfunction, lower=output$r[1], upper = model$r[i-1], subdivisions = 100)$value
  }
  
  # integrate using a spline, but this only gives the total
  #mass <- AUC(x = model$r, y = 4*pi*model$rho*(model$r^2), method = "spline", from = 0)
        
  # using trapezoidal rule for integration
  # trapzmass <- 4*pi* cumtrapz(x = model$r, y = as.matrix( model$rho*(model$r^2) ) )
  # 
  # # using right-hand points of bins  
  # RHmass <- 4*pi* cumsum(model$rho[2:nr] * ( model$r[2:nr] )^2 * diff(model$r))
  # 
  # # using left-hand points of bins  
  # RHmass <- 4*pi* cumsum(model$rho[1:(nr-1)] * ( model$r[1:(nr-1)] )^2 * diff(model$r))
  
  output
  
}
  
velocityprofile <- function(pars){
  
  # for a set of parameter values, calculate the model, and output a dataframe of the r and mean square velocity profile
  
  # calculate the limepy model
  model <- limepy$limepy(g = pars[1], phi0 = pars[2], M = pars[3], rh = pars[4])
  
  nr <- length(model$r)
  
  data.frame(r=model$r, v2=model$v2)
  
}


splineprofile <- function(limepymodel, columns){
  
  # function that is passed a limepy model profile (e.g., mass or velocity profile), then fits a spline to the data and returns the spline function so that the value at any r can be calculated
  # limepymodel = estimate of profile (data frame)
  # columns = a vector of columns (numbers or character names) you want to use to fit the spline. The first item should be the x value, and the second the y value
  
  out <- splinefun(x = limepymodel[, columns[1] ], y = limepymodel[, columns[2] ])
  
}

simplemassprofile <- function(pars){
  
  # given model parameters, calculate limepy model and use the mc returned from limepy to return a dataframe with r and cumulative mass
  
  model <- limepy$limepy(g = pars[1], phi0 = pars[2], M = pars[3], rh = pars[4])
  
  data.frame(r=model$r, mass=model$mc)
  
}



CMPcredreg <- function( chain, r.values, regions=c(0.5, 0.75, 0.95), ...){
  ######## function to calculate credible regions for a cumulative mass profile
  # returns a list of lower and upper credible regions, with 50%, 75%, and 95% cred regions being the default
  
  # credible region bounds
  drop.perc = (1 - regions)/2
  
  # for every 10th set of parameter values in chain, calculate the mass profile
  CMPs <- apply(X = chain, MARGIN = 1, FUN = simplemassprofile)
  
  # for every profile estimate, create a spline function for the CMP so we can calculate at any M(r), because limepy doesn't have this flexibility
  funCMPs <- lapply(X = CMPs, FUN = splineprofile, columns=c("r", "mass"))
  
  # get estimates at custom r values
  customCMPs <- t(sapply(funCMPs, FUN = function(x) x(r.values)))
  colnames(customCMPs) = paste( "r", seq(1,length(r.values)), sep="")
  
  # sort the M(r) values
  sorted.Mr = apply(X=customCMPs, MARGIN=2, FUN=sort)
  
  lower.creds = sapply( X=drop.perc, FUN=function(x) ( sorted.Mr[ -( 1:(x*nrow(sorted.Mr)) ) , ] )[1, ] )
  colnames(lower.creds) = as.character(100*regions)
  
  upper.creds = apply( X=cbind( drop.perc, regions ), MARGIN=1,
                       FUN=function(x) ( sorted.Mr[ -( 1:( sum(x) * nrow( sorted.Mr ) ) ), ] )[1, ] )
  colnames(upper.creds) = colnames(lower.creds)
  
  list(lowercreds=lower.creds, uppercreds=upper.creds)
  
}

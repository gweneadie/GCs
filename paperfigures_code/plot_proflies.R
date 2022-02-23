#settings
library("reticulate")
library(tidyverse)
use_python("/usr/local/bin/python3",required = TRUE)
limepy <- import("limepy")

#functions 
#isotropic model, input 4 parameter #anisotropic model, input 5 parameter 
#r phi rho
profiles <- function(pars){
  # for a set of parameter values, calculate the model, and save the r, phi, and rho values
  # calculate the limepy model
  model <- limepy$limepy(g = pars[3], phi0 = pars[4], M = 10^(pars[1]), rh = pars[2])
  #change order, and add ra 
  # put the r, gravitational potential and density into a data frame
  rphirho <- data.frame(r=model$r, phi=-(model$phi), rho=model$rho)
  #rho density #plot r vs rho
  rphirho
}
profiles5 <- function(pars){
  # for a set of parameter values, calculate the model, and save the r, phi, and rho values
  # calculate the limepy model
  model <- limepy$limepy(g = pars[3], phi0 = pars[4], M = 10^(pars[1]), rh = pars[2],ra = 10^(pars[5]))
  rphirho <- data.frame(r=model$r, phi=-(model$phi), rho=model$rho)
  #rho density #plot r vs rho
  rphirho
}
# velocity v2
velocityprofile <- function(pars){
  # for a set of parameter values, calculate the model, and output a dataframe of the r and mean square velocity profile
  # calculate the limepy model
  model <- limepy$limepy(g = pars[3], phi0 = pars[4], M = 10^(pars[1]), rh = pars[2]) 
  nr <- length(model$r)
  data.frame(r=model$r, v2=model$v2)
}
velocityprofile5 <- function(pars){
  # for a set of parameter values, calculate the model, and output a dataframe of the r and mean square velocity profile
  # calculate the limepy model
  model <- limepy$limepy(g = pars[3], phi0 = pars[4], M = 10^(pars[1]), rh = pars[2],ra = 10^(pars[5]))
  nr <- length(model$r)
  data.frame(r=model$r, v2=model$v2)
}
#radial velocity v2r
radialvelocity <- function(pars){
  # for a set of parameter values, calculate the model, and output a dataframe of the r and mean square velocity profile
  # calculate the limepy model
  model <- limepy$limepy(g = pars[3], phi0 = pars[4], M = 10^(pars[1]), rh = pars[2]) 
  nr <- length(model$r)
  data.frame(r=model$r, v2=model$v2r)
}
radialvelocity5 <- function(pars){
  model <- limepy$limepy(g = pars[3], phi0 = pars[4], M = 10^(pars[1]), rh = pars[2],ra = 10^(pars[5]))
  nr <- length(model$r)
  data.frame(r=model$r, v2=model$v2r)
}
#diff mass (non cumulative)
notcum_massprofile <- function(pars){
  # for a set of parameter values, calculate the model, and then estimate the cumulative mass profile
  model <- limepy$limepy(g = pars[3], phi0 = pars[4], M = 10^(pars[1]), rh = pars[2]) 
  ## Since sample output is in log(ra), use exp to transform back 
  nr <- length(model$r)
  output <- data.frame(r=model$r, diffmass=4*pi*model$rho*(model$r^2))
  output
}
notcum_massprofile5 <- function(pars){
  model <- limepy$limepy(g = pars[3], phi0 = pars[4], M = 10^(pars[1]), rh = pars[2],ra = 10^(pars[5]))
  output <- data.frame(r=model$r, diffmass=4*pi*model$rho*(model$r^2))
  output
}


#true parameters 
truean <- c(5,3,1.5,5,0.7427251) #a0.2
trueline <- notcum_massprofile(truep)
#mockdata/m5r3g1.5phi5.0a0.2.dat 5.53   log10(5.53)=0.7427251
#mockdata/m5r3g1.5phi5.0a0.5.dat 3.49   loh10(3.49)=0.5428254
#mockdata/m5r3g1.5phi5.0a0.8.dat 2.64   log10(2.64) = 0.4216039

#read the sampling data 
setwd("~/Desktop/Astro/GCs/PyScripts/mockdata/fits/m5r3g1.5phi5.0a0.2_MCMC_2.7")
x = read.table('samples.txt') [,53:56] #randomly pick some points, index here for example
vec <- c(x[1,1],x[1,2],x[1,3],x[1,4])
y <- notcum_massprofile(vec)
# what's your x and y axis 
plot(y$r,y$diffmass,xlab="r (pc)", ylab="dM(r)", xlim = c(0,30), ylim=c(0,28000),type="n")
grid()
# if fitted into isotropic model 
for (i in 1:2000){
  vec <- c(x[i,1],x[i,2],x[i,3],x[i,4])
  #change your target function here 
  y <- notcum_massprofile(vec)  
  lines(y$r, y$diffmass, col=rgb(0,0,0,0.01),type = "line")
}
# if fitted into anisotropic model 
for (i in 1:2000){
  vec5 <- c(x[i,1],x[i,2],x[i,3],x[i,4],x[i,5])
  y <- notcum_massprofile5(vec5)
  lines(y$r, y$diffmass, col=rgb(0,0,0,0.01),type = "line")
}
# add the cluster distribution over radius 
setwd("~/Desktop/Astro/GCs/PyScripts/mockdata")
m5r3g1.5phi5.0a0.2 <- read.table("m5r3g1.5phi5.0a0.2.dat")
vr2 <- mutate(m5r3g1.5phi5.0a0.2[1:5000,], r= sqrt(V1^2+ V2^2 +V3^2))
for (i in 1:500){rug(vr2$r, col=rgb(0,0,0,alpha=0.008))}
lines(trueline_an$r,trueline_an$diffmass,  col="red",lwd=2)
legend("topright", lty=c(1,1), lwd=c(1, 1.5), legend = c("posterior profiles", "true profile"), col=c("black", "red"))





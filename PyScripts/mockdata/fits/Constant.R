library(ggplot2)
library(plotly)
library(tidyverse)
library(matrixStats)

#IS data 
setwd("~/Documents/Astro/GCs/PyScripts/mockdata/fits/m5r3g1.5phi3.0a0.8_IS_2.7_a")
N2 = 5000
ISlogp <- read.table('logp.txt')
names(ISlogp)[1] <- "ISlogp"
ISlogq <- read.table('logq.txt')
names(ISlogq)[1] <- "ISlogq"
ISdata <- cbind(ISlogp,ISlogq)
ISdata <- mutate(ISdata, l2 = exp(ISlogp - ISlogq)) #numerical error return l2=0
ISdata <- mutate(ISdata, logl2 = (ISlogp - ISlogq)) 
View(ISdata)

#MCMC data
setwd("~/Documents/Astro/GCs/PyScripts/mockdata/fits/m5r3g1.5phi3.0a0.8_MCMC_2.7_a")
N1 = 50000
table1 <-read.table('logp.txt')
MClogp <- scan('logp.txt')
MClogq <- scan('logq.txt')
MCdata <- data.frame(cbind(MClogp,MClogq))
MCdata <- mutate(MCdata, l1 = exp(MClogp - MClogq))
MCdata <- mutate(MCdata, logl1 = (MClogp - MClogq))
View(MCdata)


#use N_eff size
N1 = N1/(1+19.15077)
  
#formula 
s1 = N1/(N1+N2)
s2 = N2/(N1+N2)

#----------------------------
#Thinning #MCMC data
setwd("~/Documents/Astro/GCs/PyScripts/mockdata/fits/m5r3g1.5phi3.0a0.8_MCMC_2.7_a")
N1 = 50000
table1 <-read.table('logp.txt')
MClogp <- c(table1[,13],table1[,26],table1[,39])
table2 <- read.table('logq.txt')
MClogq <- c(table2[,13],table2[,26],table2[,39])
MCdata <- data.frame(cbind(MClogp,MClogq))
MCdata <- mutate(MCdata, l1 = exp(MClogp - MClogq))
MCdata <- mutate(MCdata, logl1 = (MClogp - MClogq))
View(MCdata)


# funcN2 <- function(p){
#   mean(ISdata$l2/(s1*ISdata$l2 +s2*p))
# }
# funcN1 <- function(p){
#   mean(1/(s1*MCdata$l1+s2*p))
# }
# phat = 0
# threshold <- 1e-5
# stop = FALSE
# while (!stop) {
#   phat1 <- funcN2(phat)/funcN1(phat)
#   stop <- abs(phat1 - phat) < threshold 
#   phat <- phat1
# }
 

##Accurate LogSumExp 
logphat = 0
threshold <- 1e-5
stop = FALSE
while (!stop) {
  # compute log(s1 * l2 + s2 * p) using stable log operations
  logxnum = logSumExp(c(s1*ISdata$logl2,s2*logphat))
  # compute log(numerator) using stable log operations
  lognum = logSumExp(ISdata$logl2 - logxnum) - log(N2)
  
  # compute log(s1 * l1 + s2 * p) using stable log operations
  logxdenom = logSumExp(c(s1*MCdata$logl1, s2*logphat))
  # compute log(denominator) using stable log operations
  logdenom = logSumExp(0 - logxdenom) - log(N1)
  
  logphat1 <- lognum - logdenom
  stop <- abs(logphat1 - logphat) < threshold 
  logphat <- logphat1
}
logphat

##Accurate Log SumExp 2 
logphat = 0
threshold <- 1e-5
stop = FALSE
while (!stop){
  # compute log(s1 * l2 + s2 * p) using stable log operations
  logxnum = logSumExp(c(logSumExp(c(log(s1),ISdata$logl2)),logSumExp(c(log(s2),logphat))))
  # compute log(numerator) using stable log operations
  lognum = logSumExp(ISdata$logl2 - logxnum) - log(N2)
  
  # compute log(s1 * l1 + s2 * p) using stable log operations
  logxdenom = logSumExp(c(logSumExp(c(log(s1),MCdata$logl1)),logSumExp(c(log(s2),logphat))))
  # compute log(denominator) using stable log operation
  logdenom = logSumExp(0 - logxdenom) - log(N1)
  
  logphat1 <- lognum - logdenom
  stop <- abs(logphat1 - logphat) < threshold
  logphat <- logphat1
}
logphat



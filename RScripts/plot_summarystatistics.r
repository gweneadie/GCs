library(coda)

mypath = "../results/paper1results/RegenExtended/"
mypath = "../results/paper1results/RegenCompact/"

# get list of files
chainfilelist <- list.files(mypath, pattern = "chain_limepy_subsamp500")

# make a function to do stuff with each file
getsummaries <- function(filename, path = mypath){
  
  # read in chain
  chainobject <- readRDS( paste0(mypath, filename) )$chain
  
  # extract summary statistics
  temp <- summary(chainobject)

    # simplify into one data frame
  data.frame(temp[[1]], temp[[2]])
  
}

library(dplyr)
library(tibble)

# use an apply to get all summary statistics
summaries <- lapply(X = chainfilelist, FUN = getsummaries)

summaries <- lapply(X = summaries, FUN = rownames_to_column, var="Parameter")

# we want to order in increasing estimate of Mass, so get all the M estimates
mymeans <- unlist( lapply(summaries, FUN = function(x){x$Mean[3]} ))
myorder <- order(mymeans)
summaries <- summaries[myorder]

# bind the rows into one data frame using dplyr
df <- bind_rows(summaries)

# change the characters for Parameters column into Factors
df <- df %>% mutate_if(is.character, as.factor)

# true parameter values
# true parameter values
trueg = 1.5
truePhi0 = 3
trueM=1e5
truerh=3
truepars = c(trueg, truePhi0, trueM, truerh)

# does the 95% quantile contain the true parameter value?
df$within95 <- df$X2.5.<truepars & df$X97.5.>truepars
# how about the 50%
df$within50 <- df$X25.<truepars & df$X75.>truepars

gwithin = sum(df$within50[df$Parameter=="g"])
Phi0within = sum(df$within50[df$Parameter=="Phi_0"]) 
Mwithin = sum(df$within50[df$Parameter=="M"])
rwithin = sum(df$within50[df$Parameter=="r_h"])

# sort the dataframe by estimate of Mean 
# function to plot quantiles

quants <- function(x, quantiles=c("X25.", "X75."), parameter, seqy=0:49, ... ){
  
  # quantiles is a character vector of the lower and upper quantiles you want to show, default is 50% quantiles
  # parameter is a character vector indicating which parameter quantiles you want to show
  
  theserows <- x$Parameter==parameter
  x <- x[theserows, ]
  
  arrows( x0 = x[ , quantiles[1]], y0=seqy, x1 = x[ , quantiles[2]], y1=seqy, angle = 0, ...)

  arrows( x1 = x[ , quantiles[1]], y1=seqy, x0 = x[ , quantiles[2]], y0=seqy, angle = 0, ...)
  
}

# sequence 1 to 50 for plotting
y <- 0:49
# expansion factor
xfactor = 1.75


# sort the df sets by g mean estimate


# set up plotting area
par(mar=c(5,5,2,2), mfrow=c(1,4))

# g
with(df, plot(Mean[Parameter=="g"], y, type="n", panel.first = TRUE, xlab = "g", cex.lab=xfactor, cex.axis=xfactor, ylab="GC id", yaxt="n",
              xlim = c(trueg-1, trueg+1), main = bquote("within interquartile"~.(gwithin)~"times out of 50") ))
axis(side = 2, at = y, labels = myorder)
grid()

abline(v=trueg, col="blue")
with(df, points(df$Mean[Parameter=="g"], y) )
quants(df, parameter="g", length=0.1)

# Phi_0
with(df, plot(Mean[Parameter=="Phi_0"], y, type="n", panel.first = TRUE, xlab = expression(Phi[0]), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n",
              xlim = c(truePhi0-1.25, truePhi0+1.25), main = bquote("within interquartile"~.(Phi0within)~"times out of 50") ))
grid()

abline(v=truePhi0, col="blue")
with(df, points(df$Mean[Parameter=="Phi_0"], y) )
quants(df, parameter="Phi_0", length=0.1)

# M
with(df, plot(Mean[Parameter=="M"], y, type="n", panel.first = TRUE, xlab = expression(M[total]), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n",
              xlim = c( trueM-1e4, trueM+1e4), main = bquote("within interquartile"~.(Mwithin)~"times out of 50")) )
grid()

abline(v=trueM, col="blue")
with(df, points(df$Mean[Parameter=="M"], y) )
quants(df, parameter="M", length=0.1)

# rh
with(df, plot(Mean[Parameter=="r_h"], y, type="n", panel.first = TRUE, xlab = expression(r[h]), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n",
              xlim = c( truerh-1, truerh+1), main = bquote("within interquartile"~.(rwithin)~"times out of 50")) )
grid()

abline(v=truerh, col="blue")
with(df, points(df$Mean[Parameter=="r_h"], y) )
quants(df, parameter="r_h", length=0.1)







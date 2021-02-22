library(coda)

foldername = "CompactGC/subsamp500_inner"
mypath = paste0("../results/paper1results/", foldername, "/")

# true parameter values
trueg = 1.5
truePhi0 = 5
trueM=1e5
truerh=1
truepars = c(trueg, truePhi0, trueM, truerh)

# get list of files
chainfilelist <- list.files(mypath, pattern = "chain_limepy_subsamp500")

source("function_summaries.R")

library(dplyr)
library(tibble)

# use an apply to get all summary statistics
summaries <- lapply(X = chainfilelist, FUN = getsummaries)
summaries <- lapply(X = summaries, FUN = rownames_to_column, var="Parameter")

# bind the rows into one data frame using dplyr
df <- bind_rows(summaries)

# change the characters for Parameters column into Factors
df <- df %>% mutate_if(is.character, as.factor)


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

quants <- function(x, quantiles=c("X25.", "X75."), parameter, seqy=1:50, ... ){
  
  # quantiles is a character vector of the lower and upper quantiles you want to show, default is 50% quantiles
  # parameter is a character vector indicating which parameter quantiles you want to show
  
  theserows <- x$Parameter==parameter
  x <- x[theserows, ]
  
  arrows( x0 = x[ , quantiles[1]], y0=seqy, x1 = x[ , quantiles[2]], y1=seqy, angle = 0, ...)

  arrows( x1 = x[ , quantiles[1]], y1=seqy, x0 = x[ , quantiles[2]], y0=seqy, angle = 0, ...)
  
}

# sequence 1 to 50 for plotting
y <- 1:50
# expansion factor
xfactor = 1.2



pdf(paste0("../Figures/", foldername, "_limepy_subsamp500_interquartiles_", Sys.Date(), ".pdf"), width=9, height=7, useDingbats = FALSE)

# set up plotting area
par(mfrow=c(1,4))

par(mar=c(5,5,2,0))
# g
with(df, plot(Mean[Parameter=="g"], y, type="n", panel.first = TRUE, xlab = "g", cex.lab=xfactor, cex.axis=xfactor, ylab="GC id", yaxt="n",
              xlim = c(trueg-1, trueg+1), main = bquote("within interquartile"~.(gwithin)/50) ))
axis(side = 2, at = y, labels=y)
grid()
abline(v=trueg, col="blue")
with(df, points(df$Mean[Parameter=="g"], y) )
quants(df, parameter="g", length=0.1)

# Phi_0

par(mar=c(5,2,2,2))

with(df, plot(Mean[Parameter=="Phi_0"], y, type="n", panel.first = TRUE, xlab = expression(Phi[0]), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n",
              xlim = c(0, truePhi0+1.75), main = bquote("within interquartile"~.(Phi0within)/50) ))
grid()

abline(v=truePhi0, col="blue")
with(df, points(df$Mean[Parameter=="Phi_0"], y) )
quants(df, parameter="Phi_0", length=0.1)

# M
par(mar=c(5,2,2,2))

with(df, plot(Mean[Parameter=="M"], y, type="n", panel.first = TRUE, xlab = expression(M[total]~(10^5~M['\u0298'])), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n", xaxt="n",
              xlim = c( min(Mean[Parameter=="M"]), trueM+1e4), main = bquote("within interquartile"~.(Mwithin)/50)) )
grid()
axis(side = 1, at=seq(9e4,11e4, length.out = 5), labels = c(0.9, 0.95, 1.0, 1.05, 1.1))
abline(v=trueM, col="blue")
with(df, points(df$Mean[Parameter=="M"], y) )
quants(df, parameter="M", length=0.1)

# rh
par(mar=c(5,2,2,2))

with(df, plot(Mean[Parameter=="r_h"], y, type="n", panel.first = TRUE, xlab = expression(r[h]~(pc)), cex.lab=xfactor, cex.axis=xfactor, ylab="",yaxt="n",
              xlim = c( min(Mean[Parameter=="r_h"]), truerh+0.5), main = bquote("within interquartile"~.(rwithin)/50)) )
grid()

abline(v=truerh, col="blue")
with(df, points(df$Mean[Parameter=="r_h"], y) )
quants(df, parameter="r_h", length=0.1)

dev.off()






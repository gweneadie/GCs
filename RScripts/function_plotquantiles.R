# Function to plot quantiles as error bars on plots

quants <- function(x, quantiles=c("X25.", "X75."), parameter, seqy=1:50, ... ){
  
  # quantiles is a character vector of the lower and upper quantiles you want to show, default is 50% quantiles
  # parameter is a character vector indicating which parameter quantiles you want to show
  
  theserows <- x$Parameter==parameter
  x <- x[theserows, ]
  
  arrows( x0 = x[ , quantiles[1]], y0=seqy, x1 = x[ , quantiles[2]], y1=seqy, angle = 0, ...)
  
  arrows( x1 = x[ , quantiles[1]], y1=seqy, x0 = x[ , quantiles[2]], y0=seqy, angle = 0, ...)
  
}

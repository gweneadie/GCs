# Function to calculate summary statistics from final chains

# requires coda package
library(coda)

# make a function to do stuff with each file
getsummaries <- function(filename, path = mypath){
  
  # read in chain
  chainobject <- readRDS( paste0(mypath, filename) )$chain
  
  # extract summary statistics
  temp <- summary(chainobject)
  
  # simplify into one data frame
  data.frame(temp[[1]], temp[[2]])
  
}

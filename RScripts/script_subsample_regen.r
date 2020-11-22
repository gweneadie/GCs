# subsample stars from average GC


# list of mockdata files from Regen
filelist <- list.files(path = "../mockdata/paper1data/CompactGC/", pattern="m*.rds")

# sample data set
nsamp = 500
# only sample stars beyond this radius
rcut = 0
  

#' get a random sample of stars
set.seed(123)

for(i in 1:length(filelist)){
  
  # read in snap data
  alldata = readRDS( paste0("../mockdata/paper1data/CompactGC/", filelist[i]) )
  
  # of the stars beyond rcut, sample 500 randomly
  mydata <- alldata[alldata$r > rcut, ]
  
  # subsample the set of data outside rcut
  mydata = mydata[sample(x = 1:nrow(mydata), size = nsamp, replace = FALSE), ]
  
  # save file
  saveRDS(mydata, file = paste0("../mockdata/paper1data/CompactGC/subsamp500/subsamp500_", filelist[i]))
  
}
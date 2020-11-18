# Make a list of the data filenames needed
filenamelist = list.files(path = "../mockdata/paper1data/ExtendedGC/")

filenamelist = unlist(strsplit(filenamelist, split = ".dat"))

# use function to calculuate distance and speed
source("function_distancespeed.r")

for(i in 1:length(filenamelist)){
  
  filename = filenamelist[i]
  
  GCstars <- read.table(paste0("../mockdata/paper1data/ExtendedGC/", filename, ".dat"), col.names = c("x", "y", "z", "vx", "vy", "vz"))
  
    mydata = distancespeed(GCstars)
  
  # save
  saveRDS(object = mydata, file = paste0("../mockdata/paper1data/ExtendedGC/", filename, ".rds"))
  
}

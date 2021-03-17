# Make a list of the data filenames needed
folder <- "ProjectedGC/"
filenamelist = list.files(path = paste0("../mockdata/paper1data/", folder))

filenamelist = unlist(strsplit(filenamelist, split = ".dat"))

# use function to calculuate distance and speed
source("function_distancespeed.r")

for(i in 1:length(filenamelist)){
  
  filename = filenamelist[i]
  
  GCstars <- read.table(paste0("../mockdata/paper1data/", folder, filename, ".dat"), col.names = c("x", "y", "z", "vx", "vy", "vz"))
  
    mydata = distancespeed(GCstars)
  
  # save
  saveRDS(object = mydata, file = paste0("../mockdata/paper1data/", folder, filename, ".rds"))
  
}

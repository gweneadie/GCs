filename = "m5r1g1.5phi5.0"

GCstars <- read.table(paste0("../mockdata/paper1data/", filename, ".dat"), col.names = c("x", "y", "z", "vx", "vy", "vz"))

# use function to calculuate distance and speed
source("function_distancespeed.r")

mydata = distancespeed(GCstars)

# save
saveRDS(object = mydata, file = paste0("../mockdata/paper1data/", filename, ".rds"))

# read in mock data and save as an R object in the correct format for GCmcmc
GCstars = read.csv("../mockdata/snap.csv", header=FALSE, col.names = c("mass", "x", "y", "z", "vx", "vy", "vz", "ID", "notsure"))

GCstars2 = read.table("../mockdata/snap_version2.dat", col.names = c("mass", "x", "y", "z", "vx", "vy", "vz", "ID", "notsure"))

GCstars3 = read.table("../mockdata/snap_g15phi05m1e5rh3.dat", col.names = c("mass", "x", "y", "z", "vx", "vy", "vz", "ID", "notsure"))


stars <- read.table("../mockdata/snap_g14phi05M125892rh3.dat", col.names = c("mass", "x", "y", "z", "vx", "vy", "vz", "ID", "notsure"))

# columns 2, 3, 4 are x, y, z in GC-centered coordinates
# columns 5, 6, 7,  are v_x, v_y, v_z in GC-centered coordinates

# code takes in r and v
# use function to calculuate distance and speed
source("function_distancespeed.r")

mydata = distancespeed(GCstars)

mydata2 = distancespeed(GCstars2)

mydata3 = distancespeed(GCstars3)

mydata4 <- distancespeed(dat = stars)

saveRDS(object = mydata, file = paste("../mockdata/snap_Rformat_", Sys.Date(), ".rds", sep=""))

saveRDS(object = mydata2, file = paste("../mockdata/snap_version2_", Sys.Date(), ".rds", sep=""))

saveRDS(object = mydata3, file = paste("../mockdata/snap_g15phi05m1e5rh3", Sys.Date(), ".rds", sep=""))

saveRDS(object = mydata4, file = paste0("../mockdata/snap_g14phi05M125892rh3_", Sys.Date(), ".rds"))


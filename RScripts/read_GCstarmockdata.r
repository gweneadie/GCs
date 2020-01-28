# read in mock data and save as an R object in the correct format for GCmcmc

GCstars = read.csv("../mockdata/snap.csv", header=FALSE, col.names = c("mass", "x", "y", "z", "vx", "vy", "vz", "ID", "notsure"))

GCstars = GCstars = read.table("../mockdata/snap_version2.dat", col.names = c("mass", "x", "y", "z", "vx", "vy", "vz", "ID", "notsure"))

# columns 2, 3, 4 are x, y, z in GC-centered coordinates
# columns 5, 6, 7,  are v_x, v_y, v_z in GC-centered coordinates

# code takes in r and v
mydata = data.frame( r = with( GCstars, expr = sqrt(x^2 + y^2 + z^2) ), v = with( GCstars, expr = sqrt(vx^2 + vy^2 + vz^2) ) )

mydata2 = data.frame( r = with( GCstars, expr = sqrt(x^2 + y^2 + z^2) ), v = with( GCstars, expr = sqrt(vx^2 + vy^2 + vz^2) ) )

saveRDS(object = mydata, file = paste("../mockdata/snap_Rformat_", Sys.Date(), ".rds", sep=""))

saveRDS(object = mydata2, file = paste("../mockdata/snap_version2_", Sys.Date(), ".rds", sep=""))

        
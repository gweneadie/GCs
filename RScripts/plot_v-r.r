

# read in data 
GCstars = readRDS("../mockdata/snap_g15phi05m1e5rh32020-03-09.rds")

GCstarsall = read.table("../mockdata/snap_g15phi05m1e5rh3.dat", col.names = c("mass", "x", "y", "z", "vx", "vy", "vz", "ID", "notsure"))


plot(GCstars, col=rgb(0,0,1,alpha = 0.05), pch=19)

sampGCstars = GCstars[sample(x = 1:nrow(GCstars), size = 1e3, replace = F), ]

plot(sampGCstars, col=rgb(0,0.6,1,alpha = 0.5), pch=19)

### Script to make a plot of three types of clusters

# filenames of compact, average, and extended GCs
GCsIwant <- c("m5r1g1.5phi5.0", "m5r3g1.5phi5.0", "m5r9g1.5phi5.0")

compact <- read.table(paste0("../mockdata/paper1data/", GCsIwant[1], ".dat"), col.names = c("x", "y", "z", "vx", "vy", "vz"))


average <- read.table(paste0("../mockdata/paper1data/", GCsIwant[2], ".dat"), col.names = c("x", "y", "z", "vx", "vy", "vz"))

extended <- read.table(paste0("../mockdata/paper1data/", GCsIwant[3], ".dat"), col.names = c("x", "y", "z", "vx", "vy", "vz"))


nplot=1e4
myalpha = 0.08
xrange <- c(-10, 10)
yrange <- c(-20, 20)
rrange <- c(0, 20)
vrange <- c(0,30)
mycex = 1.5

compsamp <- compact[ sample(x = nrow(compact), size = nplot, replace = FALSE), ]
avgsamp <- average[ sample(x = nrow(average), size = nplot, replace = FALSE), ]
extsamp <- extended[ sample(x = nrow(extended), size = nplot, replace = FALSE), ]

# calculate total distance from center and total speed
source('function_distancespeed.r')
compsamp[, c("r", "v")] <- distancespeed(compsamp)
avgsamp[, c("r", "v")] <- distancespeed(avgsamp)
extsamp[, c("r", "v")] <- distancespeed(extsamp)
  
pdf(file = paste0("../Figures/Example_ThreeGCs", "_", Sys.Date(), ".pdf"), useDingbats = FALSE, height=7, width = 9)
par(mfrow=c(2,3), mar=c(5,0,2,0), oma=c(0,5,2,2))

plot(compsamp$x, compsamp$y, asp=1, xlab="x (pc)", ylab="", type="n", xlim=xrange, ylim=yrange, cex.lab=mycex, main="Compact", cex.main=mycex)
grid()
with(compsamp, points(x,y, col=rgb(0,0,0,myalpha)))
mtext(text = "y (pc)", side = 2, line = 3)

plot(avgsamp$x, avgsamp$y, asp=1, xlab="x (pc)", ylab="", type="n", xlim=xrange, ylim=yrange, cex.lab=mycex, main="Average", cex.main=mycex, axes=FALSE)
grid()
axis(1)
box()
with(avgsamp, points(x,y, col=rgb(0,0,0,myalpha)))

plot(extsamp$x, extsamp$y, asp=1, xlab="x (pc)", ylab="", type="n", xlim=xrange, ylim=yrange, cex.lab=mycex, main="Extended", cex.main=mycex, axes=FALSE)
grid()
axis(1)
box()
with(extsamp, points(x,y, col=rgb(0,0,0,myalpha)))

plot(compsamp$r, compsamp$v, xlab = "r (pc)", ylab = "", cex.lab=mycex, type="n", xlim=rrange, ylim=vrange)
grid()
points(compsamp$r, compsamp$v, col=rgb(0,0,0,myalpha))
mtext(text = "v (100km/s)", side = 2, line = 3)

plot(avgsamp$r, avgsamp$v, xlab = "r (pc)", ylab = "", cex.lab=mycex, type="n", xlim=rrange, ylim=vrange, axes=FALSE)
grid()
axis(1)
box()
grid()
points(avgsamp$r, avgsamp$v, col=rgb(0,0,0,myalpha))

plot(extsamp$r, extsamp$v, xlab = "r (pc)", ylab = "", cex.lab=mycex, type="n", xlim=rrange, ylim=vrange, axes=FALSE)
grid()
axis(1)
box()
points(extsamp$r, extsamp$v, col=rgb(0,0,0,myalpha))


dev.off()

### Script to make a plot of three types of clusters

# filenames of compact, average, and extended GCs
GCsIwant <- c("m5r1g1.5phi5.0", "m5r3g1.5phi5.0", "m5r9g1.5phi5.0")

compact <- read.table(paste0("../mockdata/paper1data/", GCsIwant[1], ".dat"), col.names = c("x", "y", "z", "vx", "vy", "vz"))


average <- read.table(paste0("../mockdata/paper1data/", GCsIwant[2], ".dat"), col.names = c("x", "y", "z", "vx", "vy", "vz"))

extended <- read.table(paste0("../mockdata/paper1data/", GCsIwant[3], ".dat"), col.names = c("x", "y", "z", "vx", "vy", "vz"))

nplot=1e4
myalpha = 0.1
xrange <- c(-10, 10)
yrange <- c(-20, 20)
mycex = 1.5

compsamp <- compact[ sample(x = nrow(compact), size = nplot, replace = FALSE), ]
avgsamp <- average[ sample(x = nrow(average), size = nplot, replace = FALSE), ]
extsamp <- extended[ sample(x = nrow(extended), size = nplot, replace = FALSE), ]


pdf(file = paste0("../Figures/xy_3GCs", "_", Sys.Date(), ".pdf"), useDingbats = FALSE, height=3, width = 9)
par(mfrow=c(1,3), mar=c(5,5,2,2))

plot(compsamp$x, compsamp$y, asp=1, xlab="x (pc)", ylab="y (pc)", type="n", xlim=xrange, ylim=yrange, cex.lab=mycex)
grid()
with(compsamp, points(x,y, col=rgb(0,0,0,myalpha)))

plot(avgsamp$x, avgsamp$y, asp=1, xlab="x (pc)", ylab="y (pc)", type="n", xlim=xrange, ylim=yrange, cex.lab=mycex)
grid()
with(avgsamp, points(x,y, col=rgb(0,0,0,myalpha)))

plot(extsamp$x, extsamp$y, asp=1, xlab="x (pc)", ylab="y (pc)", type="n", xlim=xrange, ylim=yrange, cex.lab=mycex)
grid()
with(extsamp, points(x,y, col=rgb(0,0,0,myalpha)))

dev.off()

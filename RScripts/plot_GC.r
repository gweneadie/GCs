filename = "m5r1g1.5phi5.0"

GCstars <- read.table(paste0("../mockdata/paper1data/", filename, ".dat"), col.names = c("x", "y", "z", "vx", "vy", "vz"))


pdf(file = paste0("../results/Figures/xy_", filename, "_", Sys.Date()), useDingbats = FALSE, height=4, width = 4)

plot(GCstars$x, GCstars$y, asp=1, xlab="x (pc)", ylab="y (pc)", type="n")
grid()
with(GCstars, points(x,y, col=rgb(0,0,0,0.01)))

dev.off()

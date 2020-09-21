alldata <- readRDS("../mockdata/snap_g14phi05M125892rh3_2020-08-04.rds")

# get a random sample of the stars
nsamp = 500
set.seed(123)
mydata = alldata[sample(x = 1:nrow(alldata), size = nsamp, replace = FALSE), ]

png(file = paste0("../results/Figures/velocity_profile_", Sys.Date(), ".pdf"), useDingbats = FALSE)
par(mar=c(5,5,2,2))
plot(alldata$r, alldata$v, xlab = "r (pc)", ylab = "v (100km/s)", col=rgb(0,0,0, alpha=0.03), cex.lab=1.5, cex.axis=1.5, main = "simulated data generated from a LIMEPY model")
points(mydata$r, mydata$v, col="blue")
grid()
legend("topright", legend = c("all stars", "sample stars"), col = c("black", "blue"), pch = c(1,1))

dev.off()

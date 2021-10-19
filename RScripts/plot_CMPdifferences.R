# make a vector of the folders in the order that you want them plotted
resultsfolders <- c("RegenAll/", "RegenOutsideCore/", "RegenInsideCore/",
                    "RegenCompact/", "CompactGC/subsamp500_outer/", "CompactGC/subsamp500_inner/",
                    "RegenExtended/", "ExtendedGC/subsamp500_outer/", "ExtendedGC/subsamp500_inner/",
                    "Regen_highPhi0/", "Regen_highPhi0/subsamp500_outer/", "Regen_highPhi0/subsamp500_inner/",
                    "Regen_lowPhi0/", "Regen_lowPhi0/subsamp500_outer/", "Regen_lowPhi0/subsamp500_inner/")

mockdatafolders <- c("RegenAll/subsamp500_random/", "RegenAll/subsamp500_outsidecore/", "RegenAll/subsamp500_insidecore/",
                     "CompactGC/subsamp500/", "CompactGC/subsamp500_outer/", "CompactGC/subsamp500_inner/",
                     "ExtendedGC/subsamp500/", "ExtendedGC/subsamp500_outer/", "ExtendedGC/subsamp500_inner/",
                     "Regen_highPhi0/subsamp500/", "Regen_highPhi0/subsamp500_outer/", "Regen_highPhi0/subsamp500_inner/",
                     "Regen_lowPhi0/subsamp500/", "Regen_lowPhi0/subsamp500_outer/", "Regen_lowPhi0/subsamp500_inner/")


xrange = list(c(0,7.5), c(0,20), c(0,45), c(0,40), c(c(0,12.5)))
# sequence of r values for plotting
rseq = seq(0,45, length.out=2e2)



########### plot #####################

plot(diffCMPs[[i]]$r, diffCMPs[[i]]$diffs, 
     col=rgb(0,0,0.3, 0.3), type="l", 
     ylim=range(diffStats),
     ylab=expression(M[true](r)-M[estimated](r))
)
polygon(x = c(rseq, rev(rseq)), y = c(diffStats$ci95lower, rev(diffStats$ci95higher)), col=rgb(0,0.4,0.7, alpha = 0.25), border = NA )
# make figure of xbar
lines(rseq, diffStats$xbar)
for(j in 2:50){
  lines(diffCMPs[[j]]$r, diffCMPs[[j]]$diffs, col=rgb(0,0,0.3, 0.3))
}
abline(h=0, lty=2)

library("distillery")
# make a vector of the folders in the order that you want them plotted
resultsfoldersRandom <- c("RegenAll/",
                    "RegenCompact/",
                    "RegenExtended/",
                    "Regen_highPhi0/",
                    "Regen_lowPhi0/")
# plot titles
plotTitle <- c("Average", "Compact", "Extended", expression("High"~Phi[0]), expression("Low"~Phi[0]))

# make a vector of the folders in the order that you want them plotted
resultsfoldersBiased <- c("CompactGC/subsamp500_outer/", "CompactGC/subsamp500_inner/",
                    "RegenOutsideCore/", "RegenInsideCore/",
                    "ExtendedGC/subsamp500_outer/", "ExtendedGC/subsamp500_inner/",
                    "Regen_highPhi0/subsamp500_outer/", "Regen_highPhi0/subsamp500_inner/",
                    "Regen_lowPhi0/subsamp500_outer/", "Regen_lowPhi0/subsamp500_inner/")

# mockdatafolders <- c("RegenAll/subsamp500_random/", "RegenAll/subsamp500_outsidecore/", "RegenAll/subsamp500_insidecore/",
#                      "CompactGC/subsamp500/", "CompactGC/subsamp500_outer/", "CompactGC/subsamp500_inner/",
#                      "ExtendedGC/subsamp500/", "ExtendedGC/subsamp500_outer/", "ExtendedGC/subsamp500_inner/",
#                      "Regen_highPhi0/subsamp500/", "Regen_highPhi0/subsamp500_outer/", "Regen_highPhi0/subsamp500_inner/",
#                      "Regen_lowPhi0/subsamp500/", "Regen_lowPhi0/subsamp500_outer/", "Regen_lowPhi0/subsamp500_inner/")


xrange = list(c(0,7.5), c(0.0,20), c(0,42), c(0,40), c(c(0,12.5)))
# expansion factor for labels
myexp = 1.35

# region colour
regcol = rgb(0,0.2,0.6, alpha=0.3)

########### plot the unbiased results #####################
# create a plotting grid that is 2x6, and make each plot take up 2 cells, so we can have 3 plots in the first row and 2 plots in the second row.

png(paste0("../Figures/CMPdifferences_randomsampling_", Sys.Date(), ".png"), res=300, width = 12, height = 6, units = "in")

layout(mat = matrix(c(1,1,2,2,3,3,
                      0,4,4,5,5,0), nrow = 2, byrow = TRUE))

# set up the outer margins, inner margins, grid, etc.
par(oma=c(0,4,3,3), mai=c(1,0.75,0,0), cex.lab=myexp, cex.axis=myexp)




for(i in 1:length(resultsfoldersRandom)){
  # grab folder name and path
  foldername = resultsfoldersRandom[i]
  mypath = paste0("../results/paper1results/", foldername)
  # get the filename and load file
  filename <- list.files(path = mypath, pattern = "^CMPdifferences")
  everything <- readRDS(paste0(mypath, filename))
  
  diffStats <- everything$diffStats
  diffCMPs <- everything$diffCMPs
  
  plot(diffCMPs[[i]]$r, diffCMPs[[i]]$diffs, 
       col=rgb(0,0,0.3, 0.3), type="l", 
       ylim=range(min(diffStats$ci95lower), max(diffStats$ci95higher)), xlim = xrange[[i]],
       ylab=expression(M[true](r)-M[estimated](r)), xlab="r (pc)")
  
  mtext(text = plotTitle[i], side = 3, line=1)
  
  # get the max range that was actually plotted
  maxx <- par("usr")[2]
  indexx <- min(which(diffStats$rseq>maxx))
  if(!is.finite(indexx)){ indexx <- length(rseq) }
  
  # show 95% confidence interval on mean differences
  with(diffStats, polygon(x = c(rseq[1:indexx],rev(rseq[1:indexx])), y = c(ci95lower[1:indexx],rev(ci95higher[1:indexx])),col= regcol, border=NA))
  
  # make figure of xbar
  # lines(diffStats$rseq, diffStats$xbar)
  for(j in 2:50){
    lines(diffCMPs[[j]]$r, diffCMPs[[j]]$diffs, col=rgb(0,0,0.3, 0.3))
  }
  abline(h=0, lty=2)
}

dev.off()

########## plot the biased results ########################
plotTitle <- c("Outside Core", "Inside Core", rep("",7))

outermarginleft <- c( "Compact", "",
                      "Average", "",
                      "Extended", "",
                      expression("High "~Phi[0]), "",
                      expression("Low "~Phi[0]), ""
)

outermarginbottom <- c(rep("", 8), "r (pc)", "r (pc)")
Ylab = expression(M[true](r)-M[estimated](r))
Ylab = rep( c(Ylab, "") , 5)
Xlab = rep("", 10)

png(paste0("../Figures/CMPdifferences_biasedsampling_", Sys.Date(), ".png"), res=300, height=11, width =8, units = "in")
# set up the outer margins, inner margins, grid, etc.
par(mfrow=c(5,2), oma=c(2,5,3,5), mai=c(0.5,0.6,0,0))

# vector to save y axis limits in first column, to use in second column
yplotlims = vector(mode = "list", length = length(resultsfoldersBiased))

for(i in 1:length(resultsfoldersBiased)){
  # grab folder name and path
  foldername = resultsfoldersBiased[i]
  mypath = paste0("../results/paper1results/", foldername)
  # get the filename and load file
  filename <- list.files(path = mypath, pattern = "^CMPdifferences")
  everything <- readRDS(paste0(mypath, filename))
  
  diffStats <- everything$diffStats
  diffCMPs <- everything$diffCMPs
  
  if(is.odd(i)){
    yplotlims[[i]] = range(min(diffStats$ci95lower), max(diffStats$ci95higher))
  }else{
    yplotlims[[i]] = yplotlims[[ceiling(i/2)]]
    # hack to fix y ranges that still look bad
    if(i==6){yplotlims[[i]] = yplotlims[[ceiling(i/2)]]*3}
    if(i==10){yplotlims[[i]] = yplotlims[[ceiling(i/2)]]*12}
  }

  plot(diffCMPs[[i]]$r, diffCMPs[[i]]$diffs, 
       col=rgb(0,0,0.3, 0.3), type="l", 
       ylim=yplotlims[[i]]*1.4, 
       xlim = xrange[[ceiling(i/2)]],
       ylab=Ylab[i], xlab=Xlab)
  
  mtext(text = outermarginleft[i], side = 2, line=5)
  mtext(text = outermarginbottom[i], side = 1, line=3, cex=0.75)
  mtext(text = plotTitle[i], side = 3, line=1)
  
  # get the max range that was actually plotted
  maxx <- par("usr")[2]
  indexx <- min(which(diffStats$rseq>maxx))
  if(!is.finite(indexx)){ indexx <- length(rseq) }
  
  # show 95% confidence interval on mean differences
  if(is.odd(i)){
    with(diffStats, polygon(x = c(rseq[1:indexx],rev(rseq[1:indexx])), y = c(ci95lower[1:indexx],rev(ci95higher[1:indexx])),col= regcol, border=NA))
  }

  # for inside core, most outside of plotting area will break polygon, this is fix
  if(is.even(i)){
    maxylower <- par("usr")[3]
    maxyupper <- par("usr")[4]
    
    temppoly <- diffStats[1:indexx, ]
    
    indexylower <- max(which(temppoly$ci95lower>maxylower))+1
    
    firstcurvex <- temppoly$rseq[1:indexylower]
    corner1x <- temppoly$rseq[indexylower]
    corner2x <- temppoly$rseq[indexx]
    corner3x <- temppoly$rseq[indexx]
    lastcurvex <- rev(temppoly$rseq[1:indexx])
    
    firstcurvey <- temppoly$ci95lower[1:indexylower]
    corner1y <- temppoly$ci95lower[indexylower]
    corner2y <- temppoly$ci95lower[indexylower]
    corner3y <- temppoly$ci95higher[indexx]
    lastcurvey <- rev(temppoly$ci95higher[1:indexx])
    
    # show 95% confidence interval on mean differences
    with(temppoly, 
         polygon(x = c(firstcurvex, corner1x, corner2x, corner3x, lastcurvex),
                 y = c(firstcurvey, corner1y, corner2y, corner3y, lastcurvey),
                 col= regcol, border=NA))
  }
  
  # make figure of xbar
  # lines(diffStats$rseq, diffStats$xbar)
  for(j in 2:50){
    lines(diffCMPs[[j]]$r, diffCMPs[[j]]$diffs, col=rgb(0,0,0.3, 0.3))
  }
  abline(h=0, lty=2)
}

  
dev.off()




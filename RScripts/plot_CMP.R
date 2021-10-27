source("function_logLike_LIMEPY.r")
source("function_CMPcredibleregions.R")
source("function_profiles.r")

# one sample GC results to make example CMP
j=13

# r range for each type of GC
xrange = list(c(0,7.5), c(0.0,20), c(0,42), c(0,40), c(c(0,12.5)))
# custom r sequence for plotting
rseq = lapply(xrange, FUN = function(x) seq(from=x[1], to=x[2], length.out=1e2))

regions=c(0.5, 0.75, 0.95)
# credible region bounds
drop.perc = (1 - regions)/2

# default colours for credible region bounds
solids = c("cadetblue4", "cadetblue3", "cadetblue1")
myylab=expression( M(r<R)~(10^5~M[solar]))
myxlab="R (kpc)"
mymar = c(5,7,0.5,5)
mycexlab=1.8

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


for(i in 1:length(resultsfoldersRandom)){
  
  # grab folder name and path
  foldername = resultsfoldersRandom[i]
  mypath = paste0("../results/paper1results/", foldername)
 
  # get list of chain files and grab jth one
  filename <- list.files(path =mypath, pattern = "^chain")[j]
  # load file
  allchaininfo <- readRDS(paste0(mypath, filename))
  chain <- allchaininfo$chain
  # convert mass to 10^5
  chain[, "M"] <- chain[, "M"]/10^5
  # use every 10th row to calculate CMP
  chain <- chain[seq(from=1, to=nrow(chain), by=10), ]
  
  # calculate Bayesian credible regions
  temp = CMPcredreg(chain = chain, r.values = rseq[[i]])
  
  lower.creds <- temp[[1]]
  upper.creds <- temp[[2]]
  
  # # for every 10th set of parameter values in chain, calculate the mass profile
  # CMPs <- apply(X = chain, MARGIN = 1, FUN = simplemassprofile)
  # 
  # # for every profile estimate, create a spline function for the CMP so we can calculate at any M(r), because limepy doesn't have this flexibility
  # funCMPs <- lapply(X = CMPs, FUN = splineprofile, columns=c("r", "mass"))
  # 
  # # get estimates at custom r values
  # r.values = rseq[[i]]
  # customCMPs <- t(sapply(funCMPs, FUN = function(x) x(r.values)))
  # colnames(customCMPs) = paste( "r", seq(1,length(r.values)), sep="")
  # 
  # # sort the M(r) values
  # sorted.Mr = apply(X=customCMPs, MARGIN=2, FUN=sort)
  # 
  # lower.creds = sapply( X=drop.perc, FUN=function(x) ( sorted.Mr[ -( 1:(x*nrow(sorted.Mr)) ) , ] )[1, ] )
  # colnames(lower.creds) = as.character(100*regions)
  # 
  # upper.creds = apply( X=cbind( drop.perc, regions ), MARGIN=1,
  #                      FUN=function(x) ( sorted.Mr[ -( 1:( sum(x) * nrow( sorted.Mr ) ) ), ] )[1, ] )
  # colnames(upper.creds) = colnames(lower.creds)
  
  
  # load the true parameter values
  truepars <- readRDS(paste0("../results/paper1results/", resultsfoldersRandom[i], "truepars.rds"))
  # convert mass to units of 10^5
  truepars["M"] <- truepars["M"]/1e5
  
  # calculate true model and add to plot true model mass profile
  truemodel <- limepy$limepy(g=truepars[1], phi0=truepars[2], M=truepars[3], rh=truepars[4])
  
  # r values for drawing cred. region bounds (pass to polygon)
  poly.r = c( r.values, rev(r.values) )
  
  # credible bound M(r) values for plotting (pass to polygon)
  polyM = rbind( lower.creds, upper.creds[ nrow(upper.creds):1 , ] )
  
  # r values for plotting
  rs = c(r.values, rev(r.values))
  Ms = rep(0, length(r.values))
  
  p = plot( r.values, (Ms), type="n", ylab="", ylim=c(0,1))
             # xlab=xlab, ylab=ylab, cex.lab=mycexlab)
  #add a background grid
  grid()
  
  # add credible regions
  for( j in length(regions):1 ){
    polygon(x=rs, y=polyM[,j], col=solids[j], border=solids[j]) 
  }
  grid()
  lines(truemodel$r, truemodel$mc/1e5, col="red", lwd=1.5)
  
  # if( makelegend ){
  #   # add legend without rmin/rmax
  #   legend( "topleft",  paste(colnames(lower.creds), "%" ), bg="white",
  #           lwd=c(8,8,8), lty=c(1,1,1), col=solids,  cex=0.8)
  #   
  #   # use if want to plot min/max of data position and key in legend
  #   if( plotdataminmax ){ 
  #     abline(v=max(dat[,"Rgc"]), lty=2)
  #     abline(v=min(dat[,"Rgc"]), lty=2)
  #     #covers previous legend
  #     legend( "topleft",  c(paste(colnames(lower.creds), "%" ), expression(r[min/max~data])), bg="white",
  #             lwd=c(8,8,8,1.3), lty=c(1,1,1,2), col=c(solids,"black"),  cex=0.8)
  #     
  #   }
  # }
  # 
  
  # add true M(r) if needed
  # if( plottrue & !othersim ){
  #   lines(x=r.values, y=sapply(r.values, FUN=M.r, pars=truepars), col="red", cex=1.3) 
  # }
  # if( plottrue & othersim ){
  #   lines(x=r.true, y=M.true, col="red", cex=1.3)
  # }
  # 
  # 
  # print(p)
  # 
  # if(printpdf){  dev.off() }
  # 
}
  
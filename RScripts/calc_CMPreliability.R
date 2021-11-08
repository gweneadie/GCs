# script to find out how often the true mass profile is within the 95% credible region at 10 different radii

library(xtable)
library(emdbook)
source('function_profiles.r')

xrange = list(c(0,20), c(0,9), c(0,45), c(0,40), c(c(0,16)))

# make a vector of the folders in the order that you want them plotted
resultsfoldersRandom <- c("RegenAll/",
                          "RegenCompact/",
                          "RegenExtended/",
                          "Regen_highPhi0/",
                          "Regen_lowPhi0/")
# make a vector of the folders in the order that you want them plotted
resultsfoldersBiased <- c("CompactGC/subsamp500_outer/", "CompactGC/subsamp500_inner/",
                          "RegenOutsideCore/", "RegenInsideCore/",
                          "ExtendedGC/subsamp500_outer/", "ExtendedGC/subsamp500_inner/",
                          "Regen_highPhi0/subsamp500_outer/", "Regen_highPhi0/subsamp500_inner/",
                          "Regen_lowPhi0/subsamp500_outer/", "Regen_lowPhi0/subsamp500_inner/")


# which folder you want
thisone = 9

# ten different radii
rseq = lseq(from = xrange[[5]][1]+1, to = xrange[[5]][2], length.out=10)

# grab folder name and path
foldername = resultsfoldersRandom[thisone]
# foldername = resultsfoldersBiased[thisone]

mypath = paste0("../results/paper1results/", foldername)

# get list of chain files and grab jth one
filename <- list.files(path =mypath, pattern = "^chain")

# matrix to store T/F. Each row will be the T/F for one realization of a GC
TFandRmatrix <- matrix(data = NA, nrow = 50, ncol = length(rseq))

# for every chain
for(j in 1:length(filename)){
  
  # load file
  allchaininfo <- readRDS(paste0(mypath, filename[j]))
  chain <- allchaininfo$chain
  # convert mass to 10^5
  chain[, "M"] <- chain[, "M"]/10^5
  
  # use every 10th row to calculate CMP
  chain <- chain[seq(from=1, to=nrow(chain), by=10), ]
  
  # calculate Bayesian credible regions
  temp = CMPcredreg(chain = chain, r.values = rseq, regions = 0.95)
  
  # load the true parameter values
  truepars <- readRDS(paste0("../results/paper1results/", resultsfoldersRandom[thisone], "truepars.rds"))
  # convert mass to units of 10^5
  truepars["M"] <- truepars["M"]/1e5
  
  # calculate true model and add to plot true model mass profile
  truemodel <- limepy$limepy(g=truepars[1], phi0=truepars[2], M=truepars[3], rh=truepars[4])
  
  massfun <- splinefun(x = truemodel$r, truemodel$mc/1e5)
  
  truemass <- massfun(x = rseq)
  
  TFmatrix = cbind( (truemass > temp$lowercreds), (truemass < temp$uppercreds) )
  TFandRmatrix[j, ] = apply(X = TFmatrix, MARGIN = 1, FUN = function(x) all(x) )
  rm(TFmatrix)
  
}

# add up all the times the true mass profile was within the 95% c.r., at each r
results <- apply(TFandRmatrix, MARGIN = 2, FUN=sum)

mytable = data.frame(r=rseq, within95= paste0(results, "/50"))

print(xtable(x = mytable, digits = c(1,2,0), caption = "Reliability of CMPs for LowPhi0 GC"), include.rownames = FALSE)



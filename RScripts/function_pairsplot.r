library(ggplot2)
library(RColorBrewer)
library(coda)


plotposterior <- function(filename, makepdf=TRUE, n=10){
  
  results <- readRDS(filename)
  chain <- results$chain
  
  # chain is long so plot every nth value
  nth = n
  plotn = seq(1, nrow(chain), by=nth)
  
  if(makepdf){
    
    id = strsplit(x = filename, split = "/")[[1]][4]
    
    pdf(file = paste("../results/paper1results/posterior_", id, "_", Sys.Date(), ".pdf", sep=""), width=9, height=9)
  
  }
  
  print( paste(nrow(chain), "posterior samples") )
  print( paste("Effective size:", round(effectiveSize(chain), digits = 0) ) )
  print( paste(nrow(results$d), "stars") )
  
  plot(as.mcmc(chain[plotn, ]))
  pairs(chain[plotn, ], col=rgb(0.3,0.5,0.8, 0.2), pch=19, cex.labels = 6, cex.axis = 1.3)
  
  if(makepdf){ dev.off() }

}




# calculate summary statistics for all of the different analyses

# make a vector of the folders in the order that you want them plotted
resultsfolders <- c("RegenAll/", "RegenOutsideCore/", "RegenInsideCore/",
                    "RegenCompact/", "CompactGC/subsamp500_outer/", "CompactGC/subsamp500_inner/",
                    "RegenExtended/", "ExtendedGC/subsamp500_outer/", "ExtendedGC/subsamp500_inner/",
                    "Regen_highPhi0/", "Regen_highPhi0/subsamp500_outer/", "Regen_highPhi0/subsamp500_inner/",
                    "Regen_lowPhi0/", "Regen_lowPhi0/subsamp500_outer/", "Regen_lowPhi0/subsamp500_inner/")


for(i in 1:length(resultsfolders)){

  # get the files for the chains
  foldername = resultsfolders[i]
  mypath = paste0("../results/paper1results/", foldername)
  
  # get list of files
  chainfilelist <- list.files(mypath, pattern = "^chain_limepy_subsamp500")
  
  library(stringr)
  # grab the true parameter values from the file names (hack, sorry)
  # but OMG thank you to http://stla.github.io/stlapblog/posts/Numextract.html for this time saver of a function
  Numextract <- function(string){
    unlist(regmatches(string,gregexpr("[[:digit:]]+\\.*[[:digit:]]*",string)))
  }
  
  # these are in the order in the filename MASS, Half-light radii, g, and phi0
  truepars <- as.numeric(Numextract( unlist(strsplit(x = chainfilelist[[1]], split = "_"))[4]) )
  # give names to these
  names(truepars) <- c("M", "r_h", "g", "Phi_0")
  # reorder so they are the same as the chains, and put M in correct units
  truepars <- truepars[c("g", "Phi_0", "M", "r_h")]
  truepars["M"] <- 10^truepars["M"]
  
  # source the function
  source("function_summaries.R")
  
  # need these packages
  library(dplyr)
  library(tibble)
  
  # use lapply to get all summary statistics for each file
  summaries <- lapply(X = chainfilelist, FUN = getsummaries)
  summaries <- lapply(X = summaries, FUN = rownames_to_column, var="Parameter")
  
  # bind the rows into one data frame using dplyr
  df <- bind_rows(summaries)
  # change the characters for Parameters column into Factors
  df <- df %>% mutate_if(is.character, as.factor)
  
  # does the 95% quantile contain the true parameter value?
  df$within95 <- df$X2.5.<truepars & df$X97.5.>truepars
  # how about the 50%
  df$within50 <- df$X25.<truepars & df$X75.>truepars
  
  
  gwithin = sum(df$within50[df$Parameter=="g"])
  Phi0within = sum(df$within50[df$Parameter=="Phi_0"]) 
  Mwithin = sum(df$within50[df$Parameter=="M"])
  rwithin = sum(df$within50[df$Parameter=="r_h"])
  
  gwithin95 = sum(df$within95[df$Parameter=="g"])
  Phi0within95 = sum(df$within95[df$Parameter=="Phi_0"]) 
  Mwithin95 = sum(df$within95[df$Parameter=="M"])
  rwithin95 = sum(df$within95[df$Parameter=="r_h"])
  
  saveRDS(object = list(dfsummaries = df, within = c(gwithin, Phi0within, Mwithin, rwithin), within95 = c(gwithin95, Phi0within95, Mwithin95, rwithin95), truepars=truepars), paste0("../results/paper1results/", foldername, "summarystatistics_", Sys.Date(), ".rds"))
  
  # remove all items except resultsfolders
  keepthese <- ls()[ls()!="resultsfolders"]
  rm(list=keepthese)
  
}

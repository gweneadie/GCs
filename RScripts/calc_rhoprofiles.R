# calculate all the density (rho) profiles from each parameter set in mcmc

# functions to calculate profile
source("function_profiles.r")

# folder
folder <- "Regen_lowPhi0/subsamp500_inner/"

# look at the ith file
i = 13

filenamelist <- list.files(path = paste0("../results/paper1results/", folder), pattern = "^chain")

filename <- strsplit(filenamelist[i], split = ".rds")[[1]]

library(stringr)

results <- readRDS(file = paste0("../results/paper1results/", folder, filenamelist[i]) )

allrhoprofiles <- apply(X = results$chain, MARGIN = 1, FUN = rhoprofile)

# save because that took a while!
saveRDS(allrhoprofiles, file = paste0("../results/paper1results/", folder, "rhoprofiles_", filename, "_", Sys.Date(), ".rds"))

# calculate all the mass profiles from each parameter set in mcmc

# functions to calculate profile
source("function_profiles.r")

# folder
folder <- "RegenCompact/"

# look at the ith file
i = 13

filenamelist <- list.files(path = paste0("../results/paper1results/", folder), pattern = "chain")

filename <- strsplit(filenamelist[i], split = ".rds")[[1]]

library(stringr)

# take filename and split up by _ separaters to get parameter info ### NOTE TO SELF: MAKE THIS EASIER NEXT TIME BY SAVING THE TRUE PARS IN THE DATA FILE!!!
temp <- strsplit(filename, "_")[[1]][4]
parnums <- str_extract_all(temp, "\\d")[[1]]
truepars = as.numeric( c( paste0(parnums[3], ".", parnums[4]), paste0(parnums[5], ".", parnums[6]), paste0("1e", parnums[1]), parnums[2] ) )


results <- readRDS(file = paste0("../results/paper1results/", folder, filenamelist[i]) )

allmassprofiles <- apply(X = results$chain, MARGIN = 1, FUN = massprofile)

# save the true parameter values too
saveRDS(truepars, file=paste0("../results/paper1results/", folder, "truepars.rds"))

# save because that took a while!
saveRDS(allmassprofiles, file = paste0("../results/paper1results/", folder, "massprofiles_", filename, "_", Sys.Date(), ".rds"))

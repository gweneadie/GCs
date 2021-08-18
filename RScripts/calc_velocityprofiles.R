# calculate velocity profile for every set of parameter values from posterior

# functions to calculate profile
source("function_profiles.r")

resultsfolders <- c("CompactGC/subsamp500_outer/", "CompactGC/subsamp500_inner/",
                    "RegenOutsideCore/", "RegenInsideCore/",
                    "ExtendedGC/subsamp500_outer/", "ExtendedGC/subsamp500_inner/",
                    "Regen_highPhi0/subsamp500_outer/", "Regen_highPhi0/subsamp500_inner/",
                    "Regen_lowPhi0/subsamp500_outer/", "Regen_lowPhi0/subsamp500_inner/")

# folder
folder <- resultsfolders[10]

# look at the ith file
i = 15

filenamelist <- list.files(path = paste0("../results/paper1results/", folder), pattern = "^chain", )

filename <- strsplit(filenamelist[i], split = ".rds")[[1]]

library(stringr)

# load true parameter values
truepars <- readRDS(paste0("../results/paper1results/", folder, "truepars.rds"))

results <- readRDS(file = paste0("../results/paper1results/", folder, filenamelist[i]) )

allvelocityprofiles <- apply(X = results$chain, MARGIN = 1, FUN = velocityprofile)

# save because that took a while!
saveRDS(allvelocityprofiles, file = paste0("../results/paper1results/", folder, "velocityprofiles_", filename, "_", Sys.Date(), ".rds"))

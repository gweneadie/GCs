library(ggplot2)
library(plotly)
library(reshape2)
library(tidyverse)
library(metR)
library(data.table)
library(dplyr)
library(modelr)
library(reticulate)
np <- import("numpy")
library(RcppCNPy)

setwd("~/Documents/Astro/GCs/PyScripts/mockdata/fits")
datamcmc <- np$load("m5r3g1.5phi3.0_MCMC_2.7.npy")


sample <- read.table('samples_5a.txt')
names(sample) <- c("m", "r","g","phi","a")
logp <- read.table('logp_5a.txt')
names(logp)[1] <- "LogPos"

logq <- read.table('logq_5a.txt')
names(logq)[1] <- "LogPro"

datas <- cbind(sample,logp,logq)
datas <- mutate(datas, NIW= exp((LogPos - LogPro)-max(LogPos - LogPro)))
datas <- mutate(datas, prob = NIW/ sum(NIW))
datas <- mutate(datas, ID = 1:nrow(datas))
View(datas)
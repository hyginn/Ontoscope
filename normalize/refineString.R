# codeTemplate.R
#
# Purpose:   Further refine the STRING subnetwork to include all 
#             and only genes for which we also have expression data.
# Version:   v0.1
# Date:      2016-04-06
# Author:    Ryoga
#
# Input:     STRING network and FANTOM5 expression data
# Output:    STRING subnetwork that includes all 
#             and only genes for which we also have expression data.
#
# ToDo (Steps):
#     3. Normalize imported datasets
#
# DONE:
#     1. import STRING network data
#     2. import FANTOM5 expression data
#
# V 0.1: Import data sets
#
# V 1.0: Select overlapped genes (really slow) 
#
# V 1.1: Improved speed by using %in%
#
# Questions:
#   1. Does this solution acturally selected all the genes we want in STRING net?
# ====================================================================
# setwd(DEVDIR)
# set working dir
# source("./fantom_import/fantom_main.R")

# =================  PARAMETERS AND INPUT FILES  ====================
refinedSTRING <- file.path("./WEAVE", "refinedSTRINGnet.Rdata")

# load STRING dataset file
STRINGdata <- load("./WEAVE/curatedOutput.RData")

# load FANTOM5 dataset file
FANTOM5 <- read.csv("./Normalize_TF/FANTOM5_TFList.csv", header=TRUE, fill=TRUE)
FANTOM5 <- FANTOM5[ , -(3:5)]


# ================== Construct the network =========================
fantomGene <- FANTOM5$Symbol

ptm <- proc.time()
STRINGnew<-src[src$hgnc_1 %in% fantomGene,]
proc.time() - ptm #~3secs

save(STRINGnew, file = refinedSTRING)

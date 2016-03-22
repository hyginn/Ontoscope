# REGNET.R
#
# Purpose:   REGNET: Create GRN using REGNETWORK database
# Version:   0.1
# Date:      2016-03-22
# Author:    Zhen Hao (Howard) Wu, Fupan Yao
#
# Input:     REGNET_HIGH_CONF - All high confidence edges from REGNETWORK
#            REGNET_MEDIUM_CONF - All medium confidence edges from REGNETWORK
#            REGNET_LOW_CONF - All low confidence edges from REGNETWORK
#
# Output:    igraph object using REGNETWORK database
#
# Depends:
#
# ToDo:      Filter out miRNA data from database and include only normalized gene names.
#
# Notes:
#
# V 0.1:     Crated igraph object using raw REGNETWORK database
# ====================================================================

setwd(paste(DEVDIR, "/REGNET", sep="")) # Modify to your working directory

# ====  PARAMETERS  ==================================================
# Don't put "magic numbers" and files in your code. Place them here,
# assign them to a well-named variable and explain the meaning!





# ====  PACKAGES  ====================================================
# (these are examples ... delete.)
#

# package example ... code paradigm to quietly install missing
#                     packages and load them
if (!require(igraph, quietly=TRUE)) {
  install.packages("igraph")
  library(igraph)
}


# For future reference on development only...
# # function example ...
# wrapString <- function(s, w = 60) {  # give parameters defaults
#   # Wrap string s into lines of width w.  # comment purpose
#   # All lines are terminated with a newline "\n"
#
#   pattern <- paste(".{1,", w, "}", sep="")
#   tmp <- paste(unlist(str_match_all(s, pattern)[[1]]),
#                collapse = "\n")
#   return(paste(tmp, "\n", sep=""))   # return explicitly
# }




# ====  FUNCTIONS  ===================================================
# Define functions or source external files
# (these are examples ... delete.)
#



# ====  ANALYSIS  ====================================================
# This is the main working section of the script where you use the
# functions to process data.

# example ...

HIGHCONF <- read.csv("REGNET_HIGH_CONF.csv", header=TRUE, sep= ",")
MEDIUMCONF <- read.csv("REGNET_MEDIUM_CONF.csv", header=TRUE, sep= ",")
LOWCONF <- read.csv("REGNET_LOW_CONF.csv", header=TRUE, sep= ",")

REGNETDB <- rbind(HIGHCONF, MEDIUMCONF, LOWCONF)
REGNETDB <- REGNETDB[, c(1,3,2,4,5,6,7)]

REGNETGRAPH <- graph_from_data_frame(REGNETDB, directed = TRUE)





# ====  TESTS  =======================================================
#

# NOTE: Database manipulation works on small subset of graph but too slow on entire graph
# STRINGDB_Subset <- STRINGDB[c(1:100),c(1,2,10)]
# STRINGDB_Subset$protein1 <- as.character(STRINGDB_Subset[,1])
# STRINGDB_Subset$protein2 <- as.character(STRINGDB_Subset[,2])
# 
# Split1 <- strsplit(as.character(STRINGDB_Subset[,1]), ".", fixed=TRUE)
# Split2 <- strsplit(as.character(STRINGDB_Subset[,2]), ".", fixed=TRUE)
# 
# for(i in 1:nrow(STRINGDB_Subset) ) {
#   STRINGDB_Subset[i,1] <- Split1[[i]][2]
#   STRINGDB_Subset[i,2] <- Split2[[i]][2]
# }



# [END]

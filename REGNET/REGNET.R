# REGNET.R
#
# Purpose:   REGNET: Create GRN using REGNETWORK database
# Version:   0.3
# Date:      2016-04-10
# Author:    Zhen Hao (Howard) Wu, Fupan Yao
#
# Input:     REGNET_HIGH_CONF - All high confidence edges from REGNETWORK
#            REGNET_MEDIUM_CONF - All medium confidence edges from REGNETWORK
#            REGNET_LOW_CONF - All low confidence edges from REGNETWORK
#
# Output:    igraph object using filtered and normalized REGNETWORK database
#
# Depends:
#
# ToDo:      Filter out miRNA data from database and include only normalized gene names. -- DONE
#
# Notes:
#
# V 0.1:     Created igraph object using raw REGNETWORK database
# V 0.2:     Filtered out miRNA data from raw database and created igraph object from it.
#            Data is already normalized by HGNC symbols as cited in paper, but some symbols are outdated.
# V 0.3:     Added comments to code
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


# ====  FUNCTIONS  ===================================================
# Define functions or source external files
# (these are examples ... delete.)
#



# ====  ANALYSIS  ====================================================
# This is the main working section of the script where you use the
# functions to process data.

# example ...

# Puts all high, medium, and low confidence csv files into separate dataframes

HIGHCONF <- read.csv("REGNET_HIGH_CONF.csv", header=TRUE, sep= ",")
MEDIUMCONF <- read.csv("REGNET_MEDIUM_CONF.csv", header=TRUE, sep= ",")
LOWCONF <- read.csv("REGNET_LOW_CONF.csv", header=TRUE, sep= ",")


# Combines all dataframes into one and reordered the rows, with HGNC symbols of regulator and target
# in first two columns
REGNETDB <- rbind(HIGHCONF, MEDIUMCONF, LOWCONF)
REGNETDB <- REGNETDB[, c(1,3,2,4,5,6,7)]


# List of sources that contain miRNA interactions that should be removed from raw dataframe
miRNADB <- c("microT", "miRanda", "miRBase", "miRecords", "miRTarBase", "PicTar", "Tarbase", "TargetScan", "transmir")

filteredDB <- REGNETDB


# Repeatedly deletes rows from filteredDB with sources mentioned in miRNADB vector
# Also checks the subsetting function needed to delete rows is behaving correctly and prints a message if not
for (db in miRNADB) {
  filteredDB<-filteredDB[ grep(db, filteredDB$database, invert=TRUE), ]
  if (nrow(filteredDB) == 0) {
    print("ERROR in subsetting")
  } else {
    print(paste(db, ": SUCCESS"))
  }
}

# Creates an igraph object from the filtered dataframe
REGNETGRAPH <- graph_from_data_frame(filteredDB, directed = TRUE)





# ====  TESTS  =======================================================
#
# To test whether names in miRNADB appear in original database

# for (db in miRNADB) {
#   test<-REGNETDB[ grep(db, REGNETDB$database, invert=FALSE), ]
#   if (nrow(test) == 0) {
#     print("not found")
#   } else {
#     print(db)
#   }
# }


# [END]

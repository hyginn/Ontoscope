# WEAVE-STRING.R
#
# Purpose:   WEAVE: Incorporate NORMALIZE Gene/TF names into STRING to Create GRN. Returns igraph objects
#                   for STRING, REGNET, and TRRUST databases for downstream use
# Version:   0.3
# Date:      2016-04-10
# Author:    Zhen Hao (Howard) Wu
#     
# Input:     Normalized gene names: Integrated into outputCrated.RData
#            STRING Database: From outputCurated.RData, originating from 9606.protein.links.detailed.v10.txt
#            REGNET igraph: FROM REGNET module
#            TRRUST Database: From TRRUST_network module
#
# Output:    3 igraph objects corresponding to STRING, REGNET, and TRRUST AND 
#            function giving neighborhood around given TF if needed, all packaged into an RData file
#
# Depends:
#
# ToDo:      Need Protein Name to Ensemble Protein ID table -- Solved by STRINGensp2symbol.R
#
#            
# Notes:     Please run normalizeWeave.R to preprocess data FIRST before running this module
#
# V 0.1:     Extracted data from STRING database and put into igraph object. Attempted table manipulation but too slow.
# V 0.2:     Nodes now named by HGNC symbol. Also implemented Subgraph function to get a subgraph centered around TF of interest.
#            Code significantly simplified due to preprocessing by STRINGensp2symbol.R
# V 0.3:     Incorporated REGNET and TRRUST into WEAVE. Module now returns an Rdata file with three igraph objects for
#            each database
# V 0.4:     STRGRAPH now contains only high confidence interactions (combined score > 700)
# ====================================================================

setwd(paste(DEVDIR, "/WEAVE", sep="")) # Modify to your working directory

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

if (!require(biomaRt)) {
  source("http://bioconductor.org/biocLite.R")
  biocLite("biomaRt")
  library("biomaRt")
}



# ====  FUNCTIONS  ===================================================
# Define functions or source external files
# (these are examples ... delete.)
#

# Returns a subgraph of input "GRAPH" centered around "TF" of interest with neighborhood size "order"
getTFSubgraph <- function(TF, order=1, GRAPH=STRGRAPH) {
  
  return(make_ego_graph(GRAPH, order, TF))
}


# ====  ANALYSIS  ====================================================
# This is the main working section of the script where you use the
# functions to process data.

# Creates the STRING igraph object from database stored in curatedOutput.Rdata
# NOTE: Please run normalizeWeave.R in NORMALIZE module BEFORE continuing!!!
load("curatedOutput.Rdata")
high_conf_interactions = src[src$combined_score > 700,]
STRGRAPH <- graph_from_data_frame(high_conf_interactions, directed = TRUE)

# Creates the REGNET igraph object
source("../REGNET/REGNET.R")

# Creates the TRRUST igraph object

setwd("../TRRUST_network/")  # Functions in TRRUST_network.R needed to call files in TRRUST directory
source("./TRRUST_network.R")

trrust_df <- loadTRRUST()
trrust_df <- fixColumns(trrust_df)

TRRUSTGRAPH <- graph.data.frame(trrust_df)

# Example use of getTFSubgraph function
SubgraphList<-getTFSubgraph("MYC")

# Sets current working directory back to WEAVE to save Rdata file in correct directory
setwd("../WEAVE")

# Saves all necessary output for downstream functions in an RData file
# Takes 1-2 mins; provided so that downstream workflows won't need to call WEAVE again to get
# required files.
save(STRGRAPH, REGNETGRAPH, TRRUSTGRAPH, getTFSubgraph, file="WEAVE.RData")

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

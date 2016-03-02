# WEAVE-STRING.R
#
# Purpose:   WEAVE: Incorporate NORMALIZE Gene/TF names into STRING and Undetermined Database to Create GRN
# Version:   0.1
# Date:      2016-02-23
# Author:    Zhen Hao (Howard) Wu
#
# Input:     TFNorm: ["Gene.Symbol", "Protein Ensemble ID", "Gene Ensemble ID"]
#            GeneNorm: TBD
#            String Database: From 9606.protein.links.detailed.v10.txt
#            Other Database: TBD
#
# Output:    igraph object using STRING and Undetermined Database AND neighborhood around given TF
#
# Depends:
#
# ToDo:      Need Protein Name to Ensemble Protein ID table -- Kinda solved by biomaRt
# Notes:
#
# V 0.1:     Extracted data from STRING database and put into igraph object. Attempted table manipulation but too slow.
# ====================================================================

setwd(paste(DEVDIR, "/WEAVE", sep="")) # Modify to your working directory

# ====  PARAMETERS  ==================================================
# Don't put "magic numbers" and files in your code. Place them here,
# assign them to a well-named variable and explain the meaning!
#



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



# Following code too slow on entire dataset
# SplitP1 <- strsplit(as.character(STRINGDB[,1]), ".", fixed=TRUE)
# SplitP2 <- strsplit(as.character(STRINGDB[,2]), ".", fixed=TRUE)
# 
# for(i in 1:nrow(STRINGDB) ) {
#   STRINGDB[i,1] <- SplitP1[[i]][2]
#   STRINGDB[i,2] <- SplitP2[[i]][2]
# }

getTFSubgraph <- function(TF, order=1, GRAPH=STRGRAPH) {
  # Gets all ENSP Ensemble codes for given TF in HGNC symbol.
  ensembl <- useMart("ensembl", dataset="hsapiens_gene_ensembl")
  
  TFENSP <- getBM(filters = "hgnc_symbol",
                  attributes = c("hgnc_symbol", "ensembl_peptide_id"),
                  values = TF,
                  mart = ensembl)
  
  # Appends "9606." to start of ensembl id to match vertex name in GRAPH.
  for(i in 1:nrow(TFENSP)) {
    TFENSP[i,2] <- paste("9606.", TFENSP[i,2], sep="")
  }
  
  # Gets all ensembl ids used by GRAPH
  VInGraph <- TFENSP[TFENSP[,2] %in% V(STRGRAPH)$name,2]
  
  # Returns neighborhood of TF using GRAPH.
  for (i in 1:length(VInGraph)) {
    Subgraph<-neighborhood(GRAPH, order, nodes=i)
  }
  
  return(Subgraph)
}







# ====  ANALYSIS  ====================================================
# This is the main working section of the script where you use the
# functions to process data.

# example ...
# Gets unique list of TFs from TFNORM
# Result <- unique(RefList[RefList$Gene.Symbol %in% TFList,c(1,3,4)])

# source("./TFNORM/NormalizeTF.R") # Can't source directly if in different folders...
STRINGDB <- read.delim("9606.protein.links.detailed.v10.txt", header=TRUE, sep = " ")
STRINGDB$protein1 <- as.character(STRINGDB[,1]) # Values initially int; changed to string to find subgraph nodes
STRINGDB$protein2 <- as.character(STRINGDB[,2])

STRGRAPH <- graph_from_data_frame(STRINGDB, directed = FALSE)

getTFSubgraph("MYC")



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

# gsea.R
#
# Purpose:   To compute differentially expressed pathways using KEGG data from Pathway Commons 
# Version:   0.2
# Date:      2016-04-10
# Author:    Fupan Yao
#
# Input:     GSx from Contrast module with structure defined in sample data
# Output:    Method returns a table of p values, viewable using View()
# Depends:   Piano, reshape2
#
# ToDo:      <list bugs, issues and enhancements>
# Notes:     <more notes>
#
# V 0.1: first iteration of code
# V 0.2: factoring into methods, comments
# ====================================================================

#== packages load ==


if(!require(piano))
{
  source("https://bioconductor.org/biocLite.R")
  biocLite("piano")
}

if(!require(reshape2))
{
  install.packages("reshape2")
}
library(piano)
library(reshape2)

#==functions==

getGSE <- function(gsxinput)
{
  #read pathway data
  pathway <- read.table("./annotate/Pathway.GSEA.hgnc.gmt", sep = "\t", fill = TRUE, col.names = 1:603)
  
  pathway <- pathway[, -2] #remove unnessesary ID data
  pathway <- melt(pathway, id.vars = 1)
  pathway <- pathway[pathway$value != "", ]
  pathway <- pathway[, -2]
  pathway <- pathway[, c(2,1)]
  
  #load pathways into gsa format
  allpathways <- loadGSC(pathway)
  
  #get input and remove NAs
  gsxtemp <- gsxinput
  gsxtemp <- na.omit(gsxtemp)
  
  gsx <- gsxtemp$gsx
  names(gsx) <- gsxtemp$gene
  
  #run GSA analysis
  gsaoutput <- runGSA(gsx, gsc = allpathways)
  return(GSAsummaryTable((gsaoutput)))
}


#== tests ==
load("./contrast/sample1_contrast.RData")
sampleoutput <- getGSE(gsx_fantomCounts_10Kg_6s)
write.csv(sampleoutput, file = "./annotate/sampleGSAoutput.csv")

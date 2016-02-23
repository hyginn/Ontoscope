# normalizeGenes.R
#
# Purpose:   get a list of genes, return relevant ID(s)
# Version:   V0.1
# Date:      2016-02-22
# Author:    gosuzombie
#
# Input:     list of genes, plus a mandatory input type, with optional output type
# Output:    list with two columns, one with input, one with target output, or NA if the input is empty
# Depends:   knowledge of biomaRt curation titles
#
# ToDo:      asking other modules for inputs
# Notes:     possible addition of greps to simplify finding input
#
# V 0.1:     First code <List key changes for versions>
# ====================================================================

# ====  FUNCTIONS  ===================================================

getCuratedGenes <- function(inputlist, input, out = "hgnc_id")
{
  intype = input
  
  if(length(inputlist) == 0 || is.na(inputlist))
  {
    warning("input list empty")
    return(NA)
  }

  # ====  PACKAGES  ====================================================
  
  if(!"biomaRt" %in% rownames(installed.packages()))
  {
    source("https://bioconductor.org/biocLite.R")
    biocLite("biomaRt")
  }
  
  library(biomaRt)
  message("loading biomaRt package")
  ensembl <- useMart("ensembl")
  message("loading database")
  ensembl <- useMart("ensembl",dataset="hsapiens_gene_ensembl")
  
  message("finding HGNC ids")
  output <- getBM(attributes = c(intype, out), filters = intype, values = inputlist, mart = ensembl)
  for(i in colnames(output))
  {
    if(NA %in% output[i, ] || "" %in% output[i, ])
    {
      warning("NA and/or blanks in output")
    }
  }
  
  return(output)

}
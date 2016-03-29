# Read_Gsx.R
#
# Purpose:   To read gene expression scores (Gsx; s=sample, x=gene) in R, determine cutoff and export as .txt.
# Version:   0.2
# Date:      2016-03-29
# Author:    Anam Qudrat
#
# Input:     Gsx scores ( = Lsx X (-log10(Psx))). These scores are always positive.
# Output:    Text file of Gsx scores above cutoff.
# Depends:   NA
#
# ToDo:      Test with working dataset.
# Notes:     Do we even need the data as an ExpressionSet?
#
# V 0.1:     First code
# V 0.2:     Determining a cutoff and writing the file to .txt
# ====================================================================

# ====  PARAMETERS  ==================================================

exprsFile <- "exprsdata.txt" # Output of Contrast Module with Gsx scores.

# ====  PACKAGES  ====================================================

# # Here, I propose to build an ExpressionSet which can be easily manipulated and serves as the input/output for many Bioconductor functions. This class is designed to combine several different sources of infomration into a single convenient structure.

# Install and load Biobase into R.

if (!require(Biobase, quietly=TRUE)) {
  install.packages("Biobase")
  library(Biobase)
}

# ====  FUNCTIONS  ===================================================

source("http://bioconductor.org/biocLite.R")
biocLite(c("Biobase"))
library ("Biobase")

# ====  ANALYSIS  ====================================================

# Building an ExpressionSet from Scratch
# Collect Gsx data into a matrix. Assume the Gsx data is in a tab-delimited text file (exported from a spreadsheet).
exprsFile <- "/Users/amatulah/Desktop/BCB420/dev/Analyze/ReadGsx/exprsdata.txt"
exprs <- as.matrix(read.table(exprsFile, header=TRUE, sep="\t", #the argument becomes sep=","
                              row.names=1,
                              as.is=TRUE))

# Dermining a cutoff: Setting alpha = 0.05 and a log fold change score of at least 2, the cutoff is for scores greater than +2.6.
cov <- exprs[exprs>0] # extract all values greater than cutoff = 2.6. Testing with the value 0 here from the sample dataset.
sorted <- sort(cov, decreasing = TRUE) # sort in descending order
cat(sorted,file="cov.txt",sep="\t") # write file to .txt
file.show("cov.txt")

# ====  TESTS  =======================================================

#Check whether Read matches your expectations
class(exprs)
dim(exprs)
colnames(exprs)
head(exprs[,1])

#Create a minimal expression set. This is useful if combining this gene expression data with other details. Otherwise skip.
#Set1 <- ExpressionSet(genes=exprs)

# [END]









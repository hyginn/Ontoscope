# Read_Gsx.R
#
# Purpose:   To read gene expression scores (Gsx; s=sample, x=gene) in R and look at it.
# Version:   0.1
# Date:      2016-03-20
# Author:    Anam Qudrat
#
# Input:     Gsx scores ( = Lsx X (-log10(Psx))).
# Output:    Data matrix
# Depends:   NA
#
# ToDo:      How to generate a combined expression set for Gsx and cTF (transcription factor) data?
# Notes:     Need actual dataset. Do we even need the data as an ExpressionSet?
#
# V 0.1:     First code
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

# ====  TESTS  =======================================================

#Check whether Read matches your expectations
class(exprs)
dim(exprs)
colnames(exprs)
head(exprs[,1])

#Create a minimal expression set
Set1 <- ExpressionSet(genes=exprs)

#Look at the Gsx data using a histogram. This will lead us into classfication and determining a cutoff.
png('exprs.histogram.png')
hist(exprs,breaks=100,col='yellow',main='Histogram of gene expression levels',xlab='Expression level')
dev.off()

# [END]









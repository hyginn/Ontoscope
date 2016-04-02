# Read_cTF.R
#
# Purpose:   To read cTF (combination of transcription data) in R and look at it.
# Version:   0.1
# Date:      2016-03-20
# Author:    Anam Qudrat
#
# Input:     Ranks
# Output:    Data matrix
# Depends:   NA
#
# ToDo:      How to generate a combined expression set for cTF and Gsx (gene expression score) data?
# Notes:     Need actual data. Do we even need the data as an ExpressionSet?
#
# V 0.1:     First code
# ====================================================================

# ====  PARAMETERS  ==================================================

cTFFile <- "TFdata.txt" # Output of RANK Module with cTF ranks.

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
cTFFile <- "/Users/amatulah/Desktop/BCB420/dev/Analyze/ReadcTF/TFdata.txt"
cTF <- as.matrix(read.table(cTFFile, header=TRUE, sep="\t", #the argument becomes sep=","
                              row.names=1,
                              as.is=TRUE))

# ====  TESTS  =======================================================

#Check whether Read matches your expectations
class(cTF)
dim(cTF)
colnames(cTF)
head(cTF[,1])

#Create a minimal expression set
Set1 <- ExpressionSet(transcriptionfactors=cTF)

#Look at the cTF data using a histogram. This will lead us into classfication and determining a cutoff.
png('cTF.histogram.png')
hist(cTF,breaks=100,col='yellow',main='Histogram of gene expression levels',xlab='Expression level')
dev.off()

# [END]



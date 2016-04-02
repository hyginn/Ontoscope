# Read_cTF.R
#
# Purpose:   To read cTF (combination of transcription data) in R and look at it.
# Version:   0.2
# Date:      2016-03-29
# Author:    Anam Qudrat
#
# Input:     Ranked list.
# Output:    Text file of top-ranked TFs.
# Depends:   NA
#
# ToDo:      Test with working dataset.
# Notes:     We are selecting top-ranked TFs but the lowest ranked TFs determine the cell conversion.
#
# V 0.1:     First code
# V 0.2:     Determining the top-ranked TFs and writing the file to .txt
# ====================================================================

# ====  PARAMETERS  ==================================================

cTFFile <- "TFdata.txt" # Output of RANK Module with cTF ranks.

# ====  PACKAGES  ====================================================

# # Here, I propose to build an ExpressionSet which can be easily manipulated and serves as the input/output for many Bioconductor functions. This class is designed to combine several different sources of infomration into a single convenient structure.

# Install and load Biobase into R. This is to create expression sets.

if (!require(Biobase, quietly=TRUE)) {
  install.packages("Biobase")
  library(Biobase)
}

# Install pmr to compute descriptive statistics of a ranked data set if needed.
if (!require(pmr, quietly=TRUE)) {
  install.packages("pmr")
  library(pmr)
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

# Dermining the top-ranked TFs.
top <- cTF[cTF>3] # extract all top-ranked TFs. Testing with the value 3 here from the sample dataset.
sorted <- sort(top, decreasing = FALSE) # sort in increasing order. Those with lowest rank are predicted to be involved in a cell conversion.
cat(sorted,file="top.txt",sep="\t") # write file to .txt
file.show("top.txt")

# ====  TESTS  =======================================================

#Check whether Read matches your expectations
class(cTF)
dim(cTF)
colnames(cTF)
head(cTF[,1])

#Create a minimal expression set. This is useful if combining this data with other details. Otherwise skip.
#Set1 <- ExpressionSet(transcriptionfactors=cTF)

# [END]



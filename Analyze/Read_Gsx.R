# Read_Gsx.R
#
# Purpose:   To read gene expression scores (Gsx; s=sample, x=gene) in R, determine cutoff and export as .txt.
# Version:   0.3
# Date:      2016-03-29
# Author:    Anam Qudrat
#
# Input:     Gsx scores ( = Lsx X (-log10(Psx))). These scores are always positive.
# Output:    Text file of Gsx scores above cutoff.
# Depends:   NA
#
# ToDo:      Test with working dataset.
# Notes:     Can we combine this dataset with cTF file and use ExpressionSet to store it?
#            How can we integrate user input where the user inserts the "alpha" value of their choice to determine cutoff?
#
# V 0.1:     First code
# V 0.2:     Determining a cutoff and writing the file to .txt
# V 0.3:     Added sample table to test code.
# ====================================================================

# ====  PARAMETERS  ==================================================

exprsF <- "exprsdata.txt" # Output of Contrast Module with Gsx scores.

# ====  PACKAGES  ====================================================

# Here, I propose to build an ExpressionSet which can be easily manipulated and serves as the input/output for many Bioconductor functions. This class is designed to combine several different sources of infomration into a single convenient structure.

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

# Input Gsx data from the Contrast Module. Assume the Gsx data is in a tab-delimited text file (exported from a spreadsheet).

setwd(paste(DEVDIR, "/Analyze", sep=""))

source("contrast.R")

# As an example, here I am using a table "exprsF" as sample output.

exprsF <- matrix(c(0.33, -3.23, 3.32, -3.23, 5.42, 2.33),ncol=1,byrow=TRUE)
rownames(exprsF) <- c("G1","G2","G3","G4","G5","G6")
colnames(exprsF) <- c("Scores")
exprsF <- as.table(exprsF)

#Import file and convert it into a matrix as shown below:
exprs <- as.matrix(read.table(exprsF, header=TRUE, sep="\t", #the argument becomes sep="," if comma separate file.
                              row.names=1,
                              as.is=TRUE))

# Dermining a cutoff: Setting alpha = 0.05 and a log fold change score of at least 2, the cutoff is for scores greater than +2.6.
# It will be useful to define a function that allows user input to choose alpha = 0.05, 0.025, 0.005 or 0.001.
cov <- exprsF>2.6 # extract all values greater than cutoff = 2.6.
Ranked_genes <- sort(exprsF[cov,], decreasing=TRUE) # sort in descending order
rank_df <- data.frame(Ranked_genes)
write.table(rank_df, "cov.txt", sep="\t") # write file to text
file.show("cov.txt")

# ====  TESTS  =======================================================

#Check whether Read matches your expectations. Peak at the data.
class(exprsF)
dim(exprsF)
colnames(exprsF)
head(exprsF[,1])

#Create a minimal expression set. This is useful if combining this gene expression data with other details. Otherwise skip.
#Set1 <- ExpressionSet(genes=exprs)

# [END]









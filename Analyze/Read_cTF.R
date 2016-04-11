# Read_cTF.R
#
# Purpose:   To read cTF (combination of transcription data) in R and look at it.
# Version:   0.3
# Date:      2016-03-29
# Author:    Anam Qudrat
#
# Input:     Ranked list.
# Output:    Text file of top-ranked TFs.
# Depends:   NA
#
# ToDo:      Test with working dataset.
# Notes:     What statistics can we apply to get a selection of top-ranked TFs?
#
# V 0.1:     First code
# V 0.2:     Determining the top-ranked TFs and writing the file to .txt
# V 0.3:     Added sample table to test code.
# ====================================================================

# ====  PARAMETERS  ==================================================

cTF <- "TFdata.txt" # Output of RANK Module with cTF ranks.

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

# Collect cTF data into a matrix. Assume the cTF data is in a tab-delimited text file (exported from a spreadsheet).

setwd(paste(DEVDIR, "/Analyze", sep=""))

source("RANK.R")

# As an example, here I am using a table "cTF" as sample output.

cTF <- matrix(c(5, 2, 4, 3, 6, 1),ncol=1,byrow=TRUE)
rownames(cTF) <- c("A","B","C","D","E","F")
colnames(cTF) <- c("Ranks")
cTF <- as.table(cTF)

#Import file and convert it into a matrix as shown below:

cTF <- as.matrix(read.table(cTF, header=TRUE, sep="\t", #the argument becomes sep="," if comma separated file.
                              row.names=1,
                              as.is=TRUE))

# Dermining the top-ranked TFs. It will be useful to define a function that allows users to determine the TF cutoff manually.
top <- cTF<100 # extract top 100 ranked TFs.
Ranked_cTF <- sort(cTF[top,], decreasing = FALSE) # sort in increasing order. Those with lowest rank are predicted to be involved in a cell conversion.
rank_df <- data.frame(Ranked_cTF)
write.table(rank_df, "top.txt", sep="\t") # write file to .txt
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



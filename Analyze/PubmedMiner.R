# PubmedMiner.R
#
# Purpose:   Assign confidence score to TFs based on their
#            co-occurrence with target cells in Pubmed abstracts.
# Version:   1.0
# Date:      2016-03-29
# Authors:   Anam Qudrat and Shivani Kamdar
#
# Input:     List of TFs identified by Ontoscope as needed for conversion.
#            Abstracts for each TF, derived from Pubmed (This step has already
#            been done for you.)
# Output:    Confidence rank and score for each TF.
#            Confidence ranks are computed as follows:
#            i) Take each output list (ie: A, B, C, D)
#            ii) Assign a base "abundance number" to each TF, which is the number
#                of abstracts available from Pubmed.
#                   A TF is considered low abundance if it has <44 abstracts (this
#                   number is taken from an approximation of the bottom 20% number,
#                   which is 44).
#            iii) For each TF on the list:
#                   A) Number of abstract hits for that TF result and the origin
#                   cell are computed. A percentage is derived.
#                   B) Number of abstract hits for that TF result and the target
#                   cell are computed. A percentage is derived.
#                   C) The ratio of hits for target to hits for origin is derived.
#                   D) Sort the list based first on ratio and second on number
#                      of hits to determine confidence rank.
#            Confidence scores are currently based on comparison of each TF and
#            target cell to the reference TF AR and the reference cell line
#            "prostate". See below for details.

# Depends:   pubmed.mineR and XML, which will be automatically installed if you do
#            not have them.
#
# ToDo:      If needed, integrate Dmitry's reverse search function.
# Notes:     If anyone has further suggestions on how to rank/score these TFs,
#            let us know and we will try to implement it!
#
# V 1.0:     Working version of script.
# ===================================DEPENDS======================================

if(require(XML) == FALSE) {
  install.packages("XML")
}
library("XML")

if(require(oubmed.mineR) == FALSE) {
  install.packages("pubmed.mineR")
}
library("pubmed.mineR")

# ===================================BACKGROUND======================================

#Download abstracts from Pubmed for TFs of interest using reutils.
#Since for well-annotated TFs there may be thousands of abstracts, we have
#already done this step for you.

#if(require(reutils) == FALSE) {
#  install.packages("reutils")
#}
#library("reutils")

#for (i in 1:length(TFList)) {
#  uid <- esearch(TFList[i], db='pubmed', usehistory=TRUE)
#  FileNaming <- TFList[i]
#  efetch(uid, rettype="abstract", retmode="text", outfile=sprintf("%s.txt", FileNaming))
#}

#Note that this results in a MASSIVE (2 million) number of abstracts for Jun - 
#because it is also finding all abstracts that are dated in June or have a Jun 
#as one of the authors!

#To fix this, we will add a text word filter specially for Jun:

#uid <- esearch("Jun[tw]", db='pubmed', usehistory=TRUE)
#efetch(uid, rettype="abstract", retmode="text", outfile="Jun.txt")

#We also have the same problem for AR, so we'll repeat for that TF.

#uid <- esearch("AR[tw]", db='pubmed', usehistory=TRUE)
#efetch(uid, rettype="abstract", retmode="text", outfile="AR.txt")

#Now we have stored all of the abstract files! These have been placed into
#an Analyze subfolder for convenience.

# ===================================STEPS======================================

#Now, let's switch our TFList to the conversion TFs and start analyzing!

#Step I. Define all variables

#Load TFList
#TFList <- read.table("top.txt", sep="\t")
#Since we still don't have an output table, I have included a dummy TFList.

TFList <- c("TP53", "MYC", "TP63", "TP73")

LengthVals <- as.numeric(vector())
BGVals <- as.numeric(vector())
TargetVals <- as.numeric(vector())

#Step 2. Text mine abstracts from the "Background" section for our origin
#        and target cell lines.

#Since we don't have these sections from Gather yet, I have used fibroblasts as
#background and cardiac cells as target.

#Assuming that we have a variable loaded into R for the searches, we will replace
#these dummy terms with that variable once it is available. If not, we will
#implement Dmitry's reverse search function for Fantom IDs and keywords from his
#FANTOM index.

setwd("./Abstracts")

for (i in 1:length(TFList)) {
  FileNaming <- TFList[i]
  abstracts <- readabs(sprintf("%s.txt", FileNaming))
  LengthVals[i] <- length(abstracts@Abstract)
  CountOccurrence <- getabs(abstracts, "fibroblast", FALSE)
  BGVals[i] <- length(CountOccurrence@Abstract)
  CounTarget <- getabs(abstracts, "cardiac", FALSE)
  TargetVals[i] <- length(CounTarget@Abstract)
}

#Step III. Set up the ranked list to determine confidence ranks.

setwd("../")

RatioVals <- TargetVals/BGVals
PercentHits <- TargetVals/LengthVals

ConRank <- data.frame(TFList, BGVals, TargetVals, RatioVals, PercentHits, LengthVals)
ConRank <- ConRank[order(ConRank$RatioVals, ConRank$LengthVals, decreasing=TRUE),]

#Step IV. Assign confidence score (from 0 to 1) for each TF.

#Any TF with a ratio < 1 is automatically assigned a 0.
#Any TF below the 44-abstract cutoff is automatically assigned an NA
#(insufficient data available).

#Initialize ConfidenceScore and add to the ranked table
ConfidenceScore <- c(rep(1, nrow(ConRank)))

ConRank <- data.frame(ConRank, ConfidenceScore)

#Now assign confidence score based on:

#The percentage of TargetVals that are hits, compared to those for AR (which
#has the highest number of abstracts at ~37000) for prostate cells (the well-
#characterized associated cell type).

#AR has 4390 abstracts mentioning "prostate" and "AR" out of 36191 total.
#Aka 12.1% of all abstracts mentioning AR also mention prostate. Since AR is the
#best documented, we will use this percentage as a "gold standard".

#The confidence score is thus determined as the percentage of hits for each TF
#divided by the percentage of hits for AR.

#In the event that this is greater than 1, we will set the ConfidenceScore to
#1 (highest confidence).

ConRank$ConfidenceScore <- PercentHits/0.121

#Now add the 0, 1, and NA confidence scores.

ConRank$ConfidenceScore[ConRank$RatioVals < 1] <- 0
ConRank$ConfidenceScore[ConRank$LengthVals < 44] <- NA
ConRank$ConfidenceScore[ConRank$ConfidenceScore > 1] <- 1

#Step V. Put these results into a nice table for output.

TFConfidence <- data.frame(ConRank$TFList, ConRank$ConfidenceScore)
write.table(TFConfidence, file="Confidence Scores for TFs.txt", sep="\t")

#And we're done! :)
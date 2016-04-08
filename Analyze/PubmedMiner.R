# PubmedMiner.R
#
# Purpose:   Assign confidence score to TFs based on their
#            co-occurrence with target cells in Pubmed abstracts.
# Version:   1.1
# Date:      2016-03-29
# Authors:   Anam Qudrat and Shivani Kamdar
#
# Input:     List of TFs identified by Ontoscope as needed for conversion.
#            Abstracts for each TF, derived from Pubmed (This step has already
#            been done for you.)
#
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
# V 1.1:     Script will now check for TFs with no Pubmed hits and will rank
#            and score them appropriately.
# V 1.0:     Working version of script.
# ===================================DEPENDS======================================

if(require(XML) == FALSE) {
  install.packages("XML")
}
library("XML")

if(require(pubmed.mineR) == FALSE) {
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

#Now we have stored all of the abstract files! Make sure to
#download them and unzip before using the script.

# ===================================STEPS======================================

#Now, let's switch our TFList to the conversion TFs and start analyzing!

#Step I. Define all variables

#Load TFList
TFList <- read.table("top.txt", sep="\t")

LengthVals <- as.numeric(vector())
BGVals <- as.numeric(vector())
TargetVals <- as.numeric(vector())

#Step 2. Text mine abstracts from the "Background" section for our origin
#        and target cell lines.

#Assuming that we have a variable loaded into R for the searches, we will replace
#these dummy terms with that variable once it is available. If not, we will
#implement Dmitry's reverse search function for Fantom IDs and keywords from his
#FANTOM index.

setwd("./Abstracts")

#Check that the TFs on the list have abstract files from Pubmed (some do not.)
#If they don't, we'll be assigning 0 values for them, so we change the names to
#"Empty".

TFList2 <- TFList
for (i in 1:length(TFList)) {
  if (!file.exists(sprintf("%s.txt", TFList[i]))) {
    TFList[i] <- "Empty"
  }
}

for (i in 1:length(TFList)) {
  if (TFList[i] == "Empty"){
    BGVals[i] <- 0
    LengthVals[i] <- 0
    TargetVals[i] <-  0
  }
  else {
  FileNaming <- TFList[i]
  abstracts <- readabs(sprintf("%s.txt", FileNaming))
  LengthVals[i] <- length(abstracts@Abstract)
  CountOccurrence <- getabs(abstracts, sourcecell, FALSE)
  BGVals[i] <- length(CountOccurrence@Abstract)
  CounTarget <- getabs(abstracts, target, FALSE)
  TargetVals[i] <- length(CounTarget@Abstract)
  }
}

#Step III. Set up the ranked list to determine confidence ranks.

setwd("../")

RatioVals <- TargetVals/BGVals
PercentHits <- TargetVals/LengthVals

TFList <- TFList2

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

# ===================================TESTS======================================

#TEST A
#-------------------------------------------------------------------
#TFList <- c("TP53", "MYC", "TP63", "TP73", "HIPPO")
#sourcecell <- "brain"
#target <- "fibroblast"

#Two have ratio<1, two have ratio>1, and HIPPO is not a real TF.

#Output from running this list should give the following:

#TFList     RatioVals     ConfidenceScore
#TP63       4.1111111     0.2515406
#MYC        2.7139364     0.6308100
#TP53       0.9129213     0.0000000
#TP73       0.1666667     0.0000000
#HIPPO      NaN           NA

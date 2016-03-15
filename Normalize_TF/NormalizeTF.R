#NormalizeTF.R
#JTB2020/BCH441 Class Project
#Normalization Module, TF Submodule
#
#Purpose: Extract a list of transcription factors derived from the union of at
#         least three transcription factor datasets of five (see below).
#Version: v1.0
#Date:    2016-02-12
#Author:  Shivani Kamdar
#
#Input:   csv files (provided in .zip), html. See Step II for normalization of terms.
#Output:  List of transcription factors (.txt format)
#
#ToDo:
#Notes:   Requires Bioconductor to work properly. Should install dependency
#         "biomaRt" automatically if you don't have it. Let me know if there are
#         any issues.
#
# ====================================================================

#Step I. Extracting transcription factor lists

#TF1 - TFs from the TFCAT database (2009)
#TF2 - TFs from the DBD database (2008)
#TF3 - Manually curated list of TFs cited in the MOGRIFY paper. See link. (2009)
#TF4 - FANTOM5 list of transcription factors (2014-2015)
#TF5 - The ENCODE list of transcription factors, derived from their list of putative TF antibodies (2012)

#Code to import and format tables:

#TF1 - As TFCAT outputs temporary tables only, we need to first download the files (provided here)
#TF1A - Annotated, manually literature-validated transcription factors. I have used only definite "TF Genes" and not the more vague "TF Gene Candidates" here.

TF1A <- read.table("TFCatA.csv", header=TRUE, fill=TRUE, sep=",")

for (i in 1:nrow(TF1A)) {
if (TF1A$Gene.ID[i]=="")
TF1A$Gene.ID[i] <- TF1A$Gene.ID[i-1]
}
TF1A <- TF1A[,-c(2:3, 6:7)]
TF1A <- TF1A[(grep("human", TF1A$Species, ignore.case=TRUE)),]
TF1A <- TF1A[(unique(TF1A$Gene.ID)),]

#TF1B - Predicted transcription factors as determined by mouse-human homology clusters

TF1B <- read.table("TFCatB.csv", header=TRUE, fill=TRUE, sep=",")
TF1B <- TF1B[,3:4]

#Merge the two tables, noting which TFs are identified by homology only (TF1B) and not literature search validated (TF1A)

TF1 <- merge(x = TF1A, y=TF1B, by="Gene.ID", by.TF1B="Gene.ID", all.y=TRUE)
TF1 <- TF1[(unique(TF1$Gene.Symbol)),]
TF1 <- TF1[,c(1,8)]
#Note that all homology-only TFs now have <NA> values in the Gene.ID column.

#Now writing TF2
TF2 <- read.table("DBD_TFs.csv", header=FALSE, skip=1, fill=TRUE, sep=",")
dbdcols <- c("MarkovID", "EnsemblID", "MatchRegion", "Family")
colnames(TF2) <- dbdcols
TF2 <- TF2[(unique(TF2$EnsemblID)),]

#Annotate TF2 with gene names from Ensembl IDs, using biomaRt and installing if not already there

source("https://bioconductor.org/biocLite.R")
if(require(biomaRt) == FALSE) {
   biocLite("biomaRt")
}
library("biomaRt")
ensemblmart <- useMart("ensembl",dataset="hsapiens_gene_ensembl")
filters <- listFilters(ensemblmart)
attributes <- listAttributes(ensemblmart)

TF2 <- getBM(attributes=c('ensembl_peptide_id', 'hgnc_symbol'), filters='ensembl_peptide_id', values=TF2$EnsemblID, mart=ensemblmart)

#TF3 has a permanent link that we can download from, and needs little cleanup.

TF3 <- read.table("http://www.nature.com/nrg/journal/v10/n4/extref/nrg2538-s3.txt", header=TRUE, sep="\t", skip=11, fill=TRUE)
TF3 <- TF3[,c(2,5:7)]


#TF4 and TF5 need relatively little work, but once again, there is no permalink to these tables.
TF4 <- read.csv("FANTOM5_TFList.csv", header=TRUE, fill=TRUE)
TF4 <- TF4[,-(3:5)]

TF5 <- read.table("ENCODE_TF_ABDerived.csv", header=TRUE, fill=TRUE, skip=1, sep=",")
TF5 <- TF5[(grep("human", TF5$Documents, ignore.case=TRUE)),]
TF5 <- TF5[,3:4]

# ====================================================================

#Step II. Making our lives easier

#Let's change all of the colnames and values to be more descriptive and easier to merge - Gene.Symbol is most descriptive, so I'll go with that.

TF1$Gene.Symbol <- toupper(TF1$Gene.Symbol)
colnames(TF2) <- c("EnsemblProteinID", "Gene.Symbol")
colnames(TF3) <- c("EnsemblGeneID", "InterproDBFamily", "Gene.Symbol", "Tissue")
colnames(TF4) <- c("EntrezID", "Gene.Symbol")
colnames(TF5) <- c("Gene.Symbol", "TargetDescription")
#TF1's "Gene.ID" column is meant to be NCBI ID, but since we expanded it all the way down to allow for easy merge when constructing the table, the IDs may not necessarily be correct. We'll remove this from the final table.

#For now (v0.1), I'll make two sets of tables - one including relevant information so we have access to it if we want it, and one with just the transcription factor names. We'll merge both sets.
#Here's set 2:

TFCat <- c(rep("Yes", times=nrow(TF1)))
TFA <- data.frame(TF1$Gene.Symbol, TFCat)
colnames(TFA)[1] <- "Gene.Symbol"

DBD <- c(rep("Yes", times=nrow(TF2)))
TFB <- data.frame(TF2$Gene.Symbol, DBD)
colnames(TFB)[1] <- "Gene.Symbol"

Manual <- c(rep("Yes", times=nrow(TF3)))
TFC <- data.frame(TF3$Gene.Symbol, Manual)
colnames(TFC)[1] <- "Gene.Symbol"

FANTOM5 <- c(rep("Yes", times=nrow(TF4)))
TFD <- data.frame(TF4$Gene.Symbol, FANTOM5)
colnames(TFD)[1] <- "Gene.Symbol"

ENCODE <- c(rep("Yes", times=nrow(TF5)))
TFE <- data.frame(TF5$Gene.Symbol, ENCODE)
colnames(TFE)[1] <- "Gene.Symbol"

# ====================================================================

#Step III. Joining transcription factor lists

#First, the union list of transcription factors.
ListA <- list(TFA, TFB, TFC, TFD, TFE)
MergedList <- merge(ListA[1], ListA[2], all=TRUE)
for (i in 3:length(ListA)){
  MergedList <- merge(MergedList, ListA[i], all=TRUE)
  MergedList <- MergedList[(!MergedList$Gene.Symbol==""),]
}

#Next, for reference, the union list of transcription factors with additional information.
ListB <- list(TF1, TF2, TF3, TF4, TF5)
RefList <- merge(ListB[1], ListB[2], all=TRUE)
for (i in 3:length(ListB)){
  RefList <- merge(RefList, ListB[i], all=TRUE)
  RefList <- RefList[(!RefList$Gene.Symbol==""),]
}

# ====================================================================

#Step IV. Find those TFs present in 2 of the 5 TF datasets.
#         As the FANTOM5 and manually curated lists account for most of the
#         TFs present in the list, we shall use a cutoff of 2 to make sure that
#         we do not lose TFs that may not have been present in older databases
#         (DBD, TFCat) or were not specifically tested by ENCODE (~300 TFs)

for (i in 1:nrow(MergedList)){
  MergeCount <- MergedList[i,]=="Yes"
  MergedList$Count[i] <- length(which(MergeCount=="TRUE"))
}
TFList <- unique(MergedList[MergedList$Count=="2"|MergedList$Count=="3"|MergedList$Count=="4"|MergedList$Count=="5",])$Gene.Symbol

#Exporting the list of transcription factors to .txt:
write.table(TFList, "Transcription Factor List.txt")

# ====================================================================

#Now we're done! :)

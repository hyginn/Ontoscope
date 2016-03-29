#Analyze_Visualization.R
#JTB2020/BCH441 Class Project
#Analyze Module, Visualization Submodule
#Heatmap Submodule
#
#Purpose: 1) Generate a heatmap for each critical TF between backgrounds and both
#            target and cell of origin, showing how expression differs between
#            cell types.
#Version: v1.0
#Date:    2016-03-21
#Author:  Shivani Kamdar
#
#Input:   Rdata file containing a list of TFs needed for conversion.
#         Rdata file containing a list of the cell lines to query FANTOM for.
#         fantomTFs, generated for all FANTOM5 samples using Dmitry and Dan's
#         Fantom Import module.
          
#Output:  Heatmap for each TF of interest.
#
#ToDo:
#Notes:   
#         
#         
#
# ====================================================================

#Step I. Creating fantomTFs

#This step is performed based on input files for backgrounds and targets.

##Thanks to Dmitry and Dan for creating Fantom import/output functionality.

##Load relevant samples

#load("./FilesGoHere.RData")
#fantomOntology("FilesGoHere")
#fantomSummarize()
#filterTFs()

#Since we do not have the lists from GATHER yet, I have used Dmitry's sample file
#as a placeholder:

load("../fantom_import/RData_Samples/fantomCounts_11.Rdata")
filterTFs()

##We now have a data table containing all 1541 TFs and their read counts for all
##samples.

#Step II. Process the fantomTFs file to be suitable for heatmap construction.

rownames(fantomTFs) <- fantomTFs[,1]
fantomTFs[,1] <- NULL

#Convert sample names to Fantom IDs

for (i in 1:ncol(fantomTFs)) {
  colnames(fantomTFs)[i] <- gsub(".*hs", "", colnames(fantomTFs)[i])
  colnames(fantomTFs)[i] <- sub("^.{5}.", "", colnames(fantomTFs)[i])
}

#Step III. Load the list of TFs needed for conversion.

#As I do not yet have this output data, I assume it will be in an Rdata file as a
#vector of TF names (HGNC).

#load("./ConversionList.RData")

#To test, I have created a short conversion list:

ConversionList <- c("TP53", "MYC", "TP63", "TP73")

#Step IV. Generate and export heatmap.


png(filename="Transcription Factor Expression Across Human Cell Lines.png",
    width=1000, height = 1000, res = 300)

heatmap(as.matrix(fantomTFs[ConversionList,]),margins=c(7,5))
dev.off()


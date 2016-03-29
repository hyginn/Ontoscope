# OntoscopeValidate.R
#
# Purpose:   To validate the ranked trancription factor list for a specific cell conversion produced by RANK module against 
#            published transcription factor data for that cell conversion
# Version:   0.2
# Date:      2016-02-20
# Author:    Burton Mendonca and Ryoga Li
#
# Input:     Ranked TF list of top 8 transcription factors required for a specific cell conversion
# Output:    The validated reuslt is output to a .csv file. Sample content of that file can be found on VALIDATE page
# Depends:
#
# ToDo:      <list bugs, issues and enhancements>
# Notes:     <more notes>
#
# V 0.2:     First code <List key changes for versions>
# ====================================================================

setwd(paste(DEVDIR, "/VALIDATE", sep=""))

# ====  PARAMETERS  ==================================================



# ====  PACKAGES  ====================================================


# ====  FUNCTIONS  ===================================================
# Define functions or source external files

getTFList <- function(datasets, cellFrom, cellTo){
  # return a list of TF in a datasets when given 'cellTo' and 'cellFrom'
  TFList <- c()
  for(i in 1:nrow(datasets)){
    row <- datasets[i,]
    if(row$CellTo == cellTo & row$CellFrom == cellFrom){
      TFList <- append(TFList, toString(row$TFList))
    }
  }
  return(TFList)
}

fractionRecovery <- function(TFList, referenceTFList){
  #Calculates the fraction of items in a "reference" transcription factor list that are recovered/matched in another transcription factor list
  
  #Check that both lists are populated
  if(length(TFList) <= 0){stop("The TF list to be analyzed is not populated")}
  if(length(referenceTFList) <= 0){stop("The reference TF list is not populated")}
  
  #Return the fractional recovery of TFs
  return(length(intersect(TFList, referenceTFList))/length(referenceTFList))
  
}

averageTFRank <- function(TFList, referenceTFList){
  #Calculates the average rank of transcription factors in a "reference" transcription factor list that have been recovered/matched in another 
  #RANKED transcription factor list (ranked top to bottom, 1 to length of the ranked list) 
  
  #Check that both lists are populated
  if(length(TFList) <= 0){stop("The ranked TF list to be analyzed is not populated")}
  if(length(referenceTFList) <= 0){stop("The reference TF list is not populated")}
  
  #Determine the TFs that are recovered in the ranked TF list
  recoveredTFList <- intersect(TFList, referenceTFList)
  
  #If no TFs are recovered, then return NULL for the average TF rank
  if(length(recoveredTFList) == 0){
    return(0)
  }
  
  #Initialize sum of the ranks of recovered transcription factors
  sum <- 0
  
  #Go through every transcription factor in the recovered TF list
  for(transcriptionFactor in recoveredTFList){
    sum <- sum + grep(transcriptionFactor, TFList)
  }
  
  return(sum/length(recoveredTFList))
  
}

averageOverlap <- function(list1, list2){
  #Calculates the average overlap of two lists, as described in Webber et al. (2010), Section 
  #Webber, W., Moffat, A., & Zobel, J. (2010). A similarity measure for indefinite rankings. ACM Transactions on Information Systems TOIS ACM Trans. Inf. Syst., 28(4), 1-38.
  
  #Check whether lists are of the same length
  if(length(list1) != length(list2)){stop("The lists are not of the same length and cannot be compared using average overlap method")}
  
  #Initialize an array of agreement (fraction identity) of the lists at each depth
  agreementArray <- c()
  
  for(depth in 1:length(list1)){
    agreementArray <- c(agreementArray, fractionRecovery(list1[1:depth], list2[1:depth]))
  }
  
  return(mean(agreementArray))
}




# ====  ANALYSIS  ====================================================
# Output a data frame for the validation results for each conversion
# A sample out put looks like the one showing on the Validate Page
# load data files 
load("maraConversions.rdata")
load("dDataset.rdata")
load("mogrifyConversions.rdata")
load("publishedConversions.RData")
load("stringConversions.rdata")
# load a file from RANK module
# mydata <- load("rankOutput.rdata")
# myList <- mydata$TFList
# Here I used a random list to test the code 
# assume we are looking at Bcell to Macrophage
myList <- c("MITF", "CEBPA", "MAFB", "DBP", "SNAI3")
# get published conversions
refList <- c("CEBPA", "SPI1")
# get corresponding TF lists from different sources we want to validate
MARAList <- getTFList(maraConversions, "Bcell", "Macrophage")
STRINGList <- getTFList(stringConversions, "Bcell", "Macrophage")
mogrifyList <- getTFList(mogrifyConversions, "Bcell", "Macrophage")
DList <- getTFList(dDataset, "Bcell", "Macrophage")

# Average rank of TFs
averageRank <- c(NA,
                 averageTFRank(myList, refList), 
                 averageTFRank(MARAList, refList),
                 averageTFRank(STRINGList, refList),
                 averageTFRank(mogrifyList, refList),
                 averageTFRank(DList, refList))
averageRank

# % TF from publication retrieved
fracRetrived <- c(NA,
                  fractionRecovery(myList, refList)*100, 
                  fractionRecovery(MARAList, refList)*100,
                  fractionRecovery(STRINGList, refList)*100,
                  fractionRecovery(mogrifyList, refList)*100,
                  fractionRecovery(DList, refList)*100)
fracRetrived

# assume we are looking at Bcell to Macrophage
# Source Cell Type
# cellFrom <- mydata$CellFrom
cellFrom <- c("Bcell")

# Target Cell Type
# cellTo <- mydata$CellTo
cellTo <- c("Macrophage")


# create a data frame for all the TF ranks
max.len = max(length(refList), length(myList),
              length(MARAList), length(STRINGList), 
              length(mogrifyList), length(DList))
ref <- c(refList, rep(NA, max.len - length(refList)))
on <- c(myList, rep(NA, max.len - length(myList)))
MARA <- c(MARAList, rep(NA, max.len - length(MARAList)))
STRING <- c(STRINGList, rep(NA, max.len - length(STRINGList)))
mogrify <- c(mogrifyList, rep(NA, max.len - length(mogrifyList)))
DL <- c(DList, rep(NA, max.len - length(DList)))

allTF <- data.frame(ref, on, MARA, STRING, mogrify, DL)
colnames(allTF) <- c("Published","Ontoscope", "MARA", "STRING", "Mogrify", "D\'Alessio")
allTF

# combine all the information into one data frame
ValidationOutput <- rbind(averageRank, fracRetrived, cellFrom, cellTo)
colnames(ValidationOutput) <- c("Published","Ontoscope", "MARA", "STRING", "Mogrify", "D\'Alessio")
combined <- rbind(ValidationOutput, allTF)
combined

write.csv(combined, file = "output.csv")


# ====  TESTS  =======================================================

myTFList <- c("MITF", "SPI1", "CEBPA", "MAFB", "DBP", "ETS2", "SNAI3", "HMGA1")
refTFList <- c("SPI1", "CEBPA","")
celNetTFList <- c()

fractionRecovery(myTFList, refTFList)
averageTFRank(myTFList, refTFList)

averageOverlap(c("a","b","c","d","e","f","g"),c("z","c","a","v","w","x","y"))

#TFListList <- list()
#for(i in 1:nrow(ConvDat)){
#  TFList <- c()
#  for(j in 4:9){
#    if(ConvDat[i,j] != '-'){
#      TFList <- c(TFList, ConvDat[i,j])
#    }
#  }
#  TFListList[[i]] <- TFList
#  
#}

#for(i in 1:nrow(publishedConversions)){
#  publishedConversions$TFList[i] <- unlist(publishedConversions$TFList)
#}

# [END]

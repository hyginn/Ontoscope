# OntoscopeValidate.R
#
# Purpose:   To validate the ranked trancription factor list for a specific cell conversion produced by RANK module against 
#            published transcription factor data for that cell conversion
# Version:   0.1
# Date:      2016-02-20
# Author:    Burton Mendonca
#
# Input:     Ranked TF list of top 8(?) transcription factors required for a specific cell conversion
# Output:    TBC
# Depends:
#
# ToDo:      <list bugs, issues and enhancements>
# Notes:     <more notes>
#
# V 0.1:     First code <List key changes for versions>
# ====================================================================

setwd(DEVDIR)

# ====  PARAMETERS  ==================================================



# ====  PACKAGES  ====================================================


# ====  FUNCTIONS  ===================================================
# Define functions or source external files

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
    return(NULL)
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
# This is the main working section of the script where you use the
# functions to process data.

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

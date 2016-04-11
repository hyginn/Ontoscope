# OntoscopeRankCombinePrune.R
#
# Purpose:   To produce a ranked, pruned trancription factor list for a specific cell conversion
# Version:   0.1
# Date:      2016-03-19
# Author:    Burton Mendonca
#
# Input:     ASSESS output and CONTRAST output
# Output:    Data frame of top X TF list, with overall rank, as well as individual ranks based on gene scores and network influence scores
# Depends:
#
# ToDo:      <list bugs, issues and enhancements>
# Notes:     <more notes>
#
# V 0.1:     First code <List key changes for versions>
# ====================================================================

setwd(paste(DEVDIR, "/RANK", sep=""))

# ====  PARAMETERS  ==================================================



# ====  PACKAGES  ====================================================


# ====  FUNCTIONS  ===================================================
# Define functions or source external files

getTFs <- function(geneDataFrame, TFList){
  #Retrieves transcription factors for a data frame of gene records
  return(geneDataFrame[geneDataFrame[1,] %in% TFList,])
}

rankGenes <- function(geneScoreDataFrame, geneNumber = 100){
  #Input: 2-column Gene data frame whose first column is a gene name/ID
  #       and whose second column is a gene scores (e.g. differential expression, gene-regulatory network influence score)
  #Output: 2-column Gene data frame whose first column is a gene name/ID
  #        and whose second column is a gene rank. The data frame is limited to a specified number of genes, geneNumber.
  #        No. 1 rank means highest score, No. X rank means Xth highest score
  
  #Check input format
  stopifnot(ncol(geneScoreDataFrame) == 2)
    
  geneScoreDataFrame[, 2] <- rank(-geneScoreDataFrame[, 2])
  colnames(geneScoreDataFrame)[2] <- paste(colnames(geneScoreDataFrame)[2], "Rank", sep = "")
  
  geneRankDataFrame <- geneScoreDataFrame[geneScoreDataFrame[,2] <= geneNumber, ]
  return(geneRankDataFrame[order(geneRankDataFrame[,2]),])
  
}

rankGeneDataFrame <- function(..., rankGeneNumber = 100){
  #Input: Multiple data frames whose first column is a gene name/ID
  #       and whose subsequent columns are gene scores (e.g. differential expression, gene-regulatory network influence scores)
  #       geneNumber specifies how may genes to include in the rankings (e.g. top 5 genes, top 10 genes, top 100 genes)
  #Output: Gene data frame shose first column is a gene name/ID
  #        and whose subsequent columns are the final rank ( = sum of invidual ranks), followed by the individual ranks for Gsx, Tis, etc.
  
  #Create a list of gene ranks data frames based on each gene score data frame
  geneRankDataFrameList = list()
  i <- 1
  for(geneScoreDataFrame in list(...)){
    for(column in 2:ncol(geneScoreDataFrame)){
      geneRankDataFrameList[[i]] <- rankGenes(geneScoreDataFrame[,c(1, column)], geneNumber = rankGeneNumber)
      i <- i + 1
    }
  }
  
  #return(geneRankDataFrameList)
  
  #Initialize the output gene rank data frame
  outputDataFrame <- data.frame()
  
  #Build an output data frame with each of the UNIQUE gene names from each of the gene rank data frames
  for(geneRankDataFrame in geneRankDataFrameList){
    outputDataFrame <- data.frame(gene = unique(c(outputDataFrame$gene, geneRankDataFrame[,1])), stringsAsFactors = FALSE)
  }
  
  #Initialize the ranks in the output data frame to zero
  outputDataFrame$finalRank <- 0
  
  #Iterate through every gene rank data frame and transfer the gene ranks to the output data frame
  for(geneRankDataFrame in geneRankDataFrameList){
    
    #Initialize a new column of zero ranks at zero for every gene that belongs
    outputDataFrame[outputDataFrame$gene %in% geneRankDataFrame[,1], colnames(geneRankDataFrame)[2]] <- 0
    
    #If a gene does not appear in a particular ranking, then it is given a score of rankGeneNumber
    outputDataFrame[!(outputDataFrame$gene %in% geneRankDataFrame[,1]), colnames(geneRankDataFrame)[2]] <- rankGeneNumber
    
    #Iterate through every gene found in the gene rank data frame
    for(gene in outputDataFrame[outputDataFrame$gene %in% geneRankDataFrame[, 1], 1]){
      
      #Assign the rank in the output data frame, taken from the gene  rank data frame
      outputDataFrame[outputDataFrame$gene == gene, colnames(geneRankDataFrame)[2]] <- geneRankDataFrame[geneRankDataFrame[, 1]  == gene, 2]
    }
    
  }
  
  #Sum the individual ranks into the final rank
  outputDataFrame$finalRank = apply(outputDataFrame[,3:ncol(outputDataFrame)], 1, sum)
  
  #Sort the output data fram by final rank
  outputDataFrame <- outputDataFrame[order(outputDataFrame$finalRank), ]
  
  #Reset the row numbers as 1,2,3,4,5... after the sort
  row.names(outputDataFrame) <- 1:nrow(outputDataFrame)
  
  return(outputDataFrame)
  
}

compareTFDataFrame <- function(sourceTFDataFrame, 
                               targetTFDataFrame, 
                               sourceExpressionDataFrame = data.frame(),
                               expressionThreshold = 20){
  #Created a "cell reprogramming" TF data frame, which contains TFs to go from the source cell type to the target cell type
  #TFs in the target cell TF data frame that are already in the source TF data frame AND are "highly" expressed (above a certain threshold)
  #are withheld from the final "cell reprogramming" TF data frame
  #Inputs: Ranked TF data frame for a source cell type, with the same format as the output of rankGeneDataFrame
  #        Ranked TF data frame for a target cell type, with the same format as the output of rankGeneDataFrame
  #        Data frame containing gene expression levels (presumably from GATHER module) for source cell type. Column 1 = gene name. Column 2 = expression level.
  #        Expression threshold, above which a TF is considered "highly" expressed
  #Output: Ranked data frame of "cell reprogramming" TFs
  
  #If the expression data is missing, create a dummy set of expression data
  if(length(sourceExpressionDataFrame) == 0){
    sourceExpressionDataFrame <- data.frame(gene = unique(c(sourceTFDataFrame$gene, targetTFDataFrame$gene)), expression = 100, stringsAsFactors = FALSE)
  }
  
  #Set the output "cell reprogramming" data frame as the target cell ranked TF data frame
  outputTFDataFrame <- targetTFDataFrame
  
  #Go through every target cell TF that is also in the source TF data frame
  for(TF in targetTFDataFrame$gene[targetTFDataFrame$gene %in% sourceTFDataFrame$gene]){
    #If the common source/target TF is expressed above a certain threshold in the source cell
    # then remove it from the  "cell reprogramming" TF data frame
    if(sourceExpressionDataFrame[sourceExpressionDataFrame[, 1] == TF, 2] >= expressionThreshold){
      outputTFDataFrame <- outputTFDataFrame[outputTFDataFrame$gene != TF, ]
    }
  }
  
  return(outputTFDataFrame)
}

pruneTFDataFrame <- function(TFDataFrame, regNetwork, coverageSimilarity = 0.98){
  #Removes redundant TFs from a ranked TF data frame, as follows: If a higher-ranking TF regulates a certain % of the current TF, remove the current TF.
  #Inputs: Ranked data frame of TFs
  #        Gene regulatory network as an iGraph, to use for pruning. Each outward edge means "regulates".
  #        A coverage similarity limit used to remove redundant TFs, as a fraction (0 to 1)
  #Output: A pruned ranked data frame of TFs
  rowsToRemove <- c()
  for(i in 2:nrow(TFList)){
    for(j in 1:(i-1)){
      if(length(intersect(regulatedGenes(TFDataFrame[i,1], regNetwork), regulatedGenes(TFDataFrame[j,1], regNetwork))/length(regulatedGenes(TFDataFrame[i,1], regNetwork))) >= coverageSimilarity){
        rowsToRemove <- c(rowsToRemove, i)
      }
    }
  }
  
  outputTFDataFrame <- TFDataFrame[-rowsToRemove, ]
  
  #Reset the row numbers as 1,2,3,4,5... after the pruning
  row.names(outputTFDataFrame) <- 1:nrow(TFDataFrame)
  
  return(outputTFDataFrame)
}

regulatedGenes <- function(TF,regNetwork){
  #Inputs: A name of the TF as a string
  #        A gene regulatory regulatory network as an iGraph,in which each outward edge means "regulates"
  #Returns a list of genes directly regulated by a transcription factor, TF
  return(ego(regNetwork, 1, TF, mode = "out"))
}

# ====  ANALYSIS  ====================================================
# This is the main working section of the script where you use the
# functions to process data.

# ====  TESTS  =======================================================

#set.seed(1002807448)

#contrastOutputDummySource <- data.frame(gene = paste("gene", sample(1:20,10)), gsx = rnorm(10), stringsAsFactors = FALSE)

#assessOutputDummySource <- data.frame(gene = paste("gene", sample(1:20,10)), tisSTRING = rnorm(10), tisMARA = rnorm(10), stringsAsFactors = FALSE)

#contrastOutputDummyTarget <- data.frame(gene = paste("gene", sample(1:20,10)), gsx = rnorm(10), stringsAsFactors = FALSE)

#assessOutputDummyTarget <- data.frame(gene = paste("gene", sample(1:20,10)), tisSTRING = rnorm(10), tisMARA = rnorm(10), stringsAsFactors = FALSE)

#sourceExpressionDummy <- data.frame(gene = paste("gene", sample(1:20,20)), cellExpression = rnorm(20, 50, 20), background1  = rnorm(20, 50, 20), stringsAsFactors = FALSE)

#targetExpressionDummy <- data.frame(gene = paste("gene", sample(1:20,20)), cellExpression = rnorm(20, 50, 20), background1  = rnorm(20, 50, 20), stringsAsFactors = FALSE)

#cgrdfsource <- rankGenes(contrastOutputDummySource, geneNumber = 5)

#agrdfsource1 <- rankGenes(assessOutputDummySource[,c(1,2)], geneNumber = 5)

#agrdfsource2 <- rankGenes(assessOutputDummySource[,c(1,3)], geneNumber = 5)

#cgrdftarget <- rankGenes(contrastOutputDummyTarget, geneNumber = 5)

#agrdftarget1 <- rankGenes(assessOutputDummyTarget[,c(1,2)], geneNumber = 5)

#agrdftarget2 <- rankGenes(assessOutputDummyTarget[,c(1,3)], geneNumber = 5)

#rgdfsource <- rankGeneDataFrame(contrastOutputDummySource, assessOutputDummySource, rankGeneNumber = 5)

#rgdftarget <- rankGeneDataFrame(contrastOutputDummyTarget, assessOutputDummyTarget, rankGeneNumber = 5)

#cgdf1 <- compareTFDataFrame(rgdfsource, rgdftarget, sourceExpressionDummy, expressionThreshold = 20)

#cgdf2 <- compareTFDataFrame(rgdfsource, rgdftarget, expressionThreshold = 20)

# [END]

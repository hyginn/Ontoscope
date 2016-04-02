#Contrast.R
#
# Purpose:   To claculate Gsx score for each sample(s) in each gene(x)
# Version:   V0.3
# Author:    kartikay chadha
#
# Input:     Normalized file containg raw read countd from fantom 5 via gather module
# Output:    Gsx scores (= Lsx X (-log10(Psx)))
# Depends:   input column_1 to n is target sample rest background
#
# ToDo:      
# Notes:     Tested on window OS7x64bits and R version 3.1.3
#
# V 0.1:     Calculating Gsx score
#
# v 0.2:     Updated with bugs fixed- library load cmd fixed
# Date-rel:  24-March-2016
#
# v 0.3:    including 2nd parameter to specify number of source/target samples input 
#           Changing output dataframe type (stringsAsFactors = F)
#           Changing function name to contrast 
#Date-rel:   2-April-2016

#-----------LOAD FILE---------------------------------------

#Reference code
#colData <- read.csv("coldata.csv", row.names=1, header=T)
#
#Load "sample1_contrast.RData"
#
#Run Function : contrast(dataframe,n)
#               n is the number for first n columns in dataframe which are samples for the source/target cell line. Rest all will be treated as background. 

#-----------contrast function-----------------

contrast <- function(countData,n){
  
  if("DESeq2" %in% rownames(installed.packages()) == FALSE) #loading DESeq2 package 
  {
    source("http://bioconductor.org/biocLite.R")
    biocLite("DESeq2")
   
  }
  library("DESeq2")
#Creating the column discription file
#Column 1 is the sample target and rest all columns are background cell lines 



  colData<-data.frame(condition = numeric(0)) #creating empty data frame with condition column name 
  colData[1:n,1]<- 'test' # first column of input file is tes/sample target
  colData[(n+1):ncol(countData),1]<- 'back' #rest all are background
  row.names(colData)<- colnames(countData) #setting all column names input file as row names of column discription file
  colData$condition <- factor(colData$condition) #converting characters to factors for DESeq 
  


#=====Running DESEQ======

#creating input file for DESEQ  
  dds<-DESeqDataSetFromMatrix(countData = countData,colData = colData,design = ~ condition)
  dds<- DESeq(dds) #Running DESEQ2
  res<-results(dds) #Capturing results 

#Calculating and expoting the Gsx score
x<-data.frame( gene = row.names(res), gsx= (-log10(res$padj)*res$log2FoldChange),stringsAsFactors = F)
return(x)
  
}
  
#end  

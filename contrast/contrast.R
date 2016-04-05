# contrast.R
#
# Purpose:   To calculate Gsx score for each sample(s) in each gene(x)
# Version:   V 0.3.2
# Author:    kartikay chadha
#
# Input:     Normalized file containg raw read countd from fantom 5 via gather module
#            Input data-frame column 1 to n are target sample(s), the rest are background
#            Row names are gene IDs
# Output:    Gsx scores (= Lsx X (-log10(Psx)))
# Depends:   BioConductor DeSeq

#
# ToDo:      
# Notes:     Tested on window OS7x64bits and R version 3.1.3
#
# V 0.3.2:  Updating documentation comments and specifications
# Date rel: 4-April-2016
#           
# V 0.3.1:  slighthly changed calling semantics by setting n = 1, as a
#           parameter default; added a few comments;
#           updated coding style
#
# V 0.3:    including 2nd parameter to specify number of source/target samples input 
#           Changing output dataframe type (stringsAsFactors = F)
#           Changing function name to contrast 
#Date-rel:   2-April-2016
#
# V 0.2:     Updated with bugs fixed- library load cmd fixed
# Date-rel:  24-March-2016
#
# V 0.1:     Calculating Gsx score

#-----------LOAD FILE---------------------------------------

# Reference code
# colData <- read.csv("coldata.csv", row.names=1, header=T)
#
# Load "sample1_contrast.RData"
#
# Run Function : contrast(dataframe,n)
#               n is the number for first n columns in dataframe which are
#               samples for the source/target cell line. Rest all will be
#               treated as background. 

# -----------contrast function-----------------

contrast <- function(countData, n = 1){
  
  if ("DESeq2" %in% rownames(installed.packages()) == FALSE)  {
    source("http://bioconductor.org/biocLite.R")  #loading DESeq2 package
    biocLite("DESeq2")
  }
  library("DESeq2")

# Creating the column description file
# Column 1 to n are the sample target and rest all columns are background cell lines 

# BS> Please add reference to DESeq specs and ideally also define
# BS> what you are doing here (as in: define the goal, not describe what
# BS> the code does). For example I was surprised that these _should_
# BS> be factors.
#
# KC> Yes, DESeq2 needs the the vector file to have conditions of design as factors. I am updating this
# KC> section. However, DESeq2 converts char to factors if we give chr as input.

# DESeq requires two inputs
# Input 1 (countData) : Dataframe with arectangular data of integer values
#                       row.names as gene names
#                       column.headers as sample names. 
#
# Input 2 (colData) : Vector file indicating which sample is in which group (target or background).
#                     Number of rows = to number of columns in input 1
#                     row.names = column.headers of input 1

colData <- data.frame() #creating empty data frame
  colData[1:n, "condition"] <- 'test' # first n columns of input file are test/sample target
  colData[(n+1):ncol(countData), "condition"] <- 'back' # rest all are background
  row.names(colData) <- colnames(countData) # setting all column names input file as row names of column discription file
  colData$condition <- factor(colData$condition) #converting characters to factors for DESeq2 

  
# =====Running DESEQ======

# BS> DESeq documentation specifies: "As input, the DESeq package expects
# BS> count data [...] in the form of a rectangular table of integer values."
# BS> Please add code to verify that this is the case.
#
# KC> DESeq2 verifies the files at the point when we create the dataset matrix.
# KC> DESeq2 has very well written debug function to find out all such errors
# KC> It can pick up if counts by chance are negative or condition is not specified for any of the columns
# KC> All are returned as warnings/debug
#
# KC> For practice. To check if any of the columns of a data frame has a non numeric entry
# KC> here is the code (It will be repetative if included in contrast function as DESeq2 is already doing it)
#
# any(sapply(fantomCounts_500g_5s,is.numeric) == FALSE)
# returns TRUE if any entry is not numeric 

# Creating input file for DESEQ  
  dds <- DESeqDataSetFromMatrix(countData = countData,
                              colData = colData,
                              design = ~ condition)
  dds <- DESeq(dds) #Running DESEQ2
  res <- results(dds) #Capturing results 

# Calculating and exporting the Gsx score
  x <- data.frame(gene = row.names(res),
                  gsx = (-log10(res$padj) * res$log2FoldChange),
                  stringsAsFactors = FALSE)
  return(x)
  
}
  
#end  

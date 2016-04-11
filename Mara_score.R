# Mara_score.R
#
# Purpose:   Asses: Incorporate Gsx (gene scores) with Gene network (GxG) and List of transcription factors (TF) to get a score for 
# every transcription factor for every cell type.
# Version:   0.1
# Date:      2016
# Author:    Phil Fradkin (Monuj)
#
# Input:     GENE_JASPAR_ID
#            MARA_scores
#            motifDB
#            TFtargets
#      
#
# Output:    List of transcription Factors with scores attached
#
# Depends:
#
# ToDo:      
# Notes:
#
# V 0.1:     
# ====================================================================
# PREP
# set working directory indicate your own directory
setwd(paste(DEVDIR, "/annotate", sep="")) 
source("gsea.R") 
#change file name
gene_scores = gsx

setwd(DEVDIR)
load("MARA.RData")

setwd(DEVDIR) 

# ====================================================================

#choose a cell line
#ex:
#chose cell line
cell_line <- MARA_scores$Adipocyte.20..20breast.2c.20donor1.CNhs11051.11376.118A8

#filter motifs that passed qc for cell_line
passed_qc <- which(cell_line[] < .05)

#the combination of name and motif IDS of TFs that passed
motif_ids <- row.names(MARA_scores)[passed_qc]

#split the combintation
split_ids <- strsplit(motif_ids, split = ";")

#mara motifs written
mara_motifs <- rapply(split_ids, function(x) tail(x,1))

#names of tfs written
sig_tf <- rapply(split_ids, function(x) head(x,1))

#position of motif within TFtargets and its information 
pos_motif <- match( mara_ids ,motifDB$JASPAR_ID)



get_mara_TFscore <- function(TF) {
  
  #get the order number of TF on TFtargets
  tf_number <- which(row.names(motifDB) == TF)
  
  #get gene set from TFtargets
  gene_set <- TFtargets[[tf_number]]$GENE
  
  #set tf score to 0
  TF_score <- 0
  
  #for every gene in gene set
  for (i in 1:length(gene_set)){
    
    gene <- gene_set[i]
    #check if gene score exists and then add it to TF score
    Gsx <- gene_scores$gsx[levels(gene_scores$gene)== current_gene]
    if (length(Gsx) == 0 | is.null(Gsx)  ){
      Gsx <- 0
    }
    TF_score <- sum(TF_score, Gsx)
  }
  #divide the TF_score by the number of interactions that the motif has
  TF_score <- TF_score / length(TFtargets[[tf_number]]$GENE)
  return TF_score
}

tf_score.df <- matrix(nrow = length(sig_tf), ncol = 1, dimnames = list(c(sig_tf)), c( "SCORE"))



for (i in 1:length(sig_tf)){
  #acquire transcription factor 
  tf <- sig_tf[i]
  # run get tf on every transcription factor and write score
  score = get_mara_TFscore(tf)
  #attach the score to the data frame
  tf_score.df[tf,] = score
}





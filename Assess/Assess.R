# Asses.R
#
# Purpose:   Asses: Incorporate Gsx (gene scores) with Gene network (GxG) and List of transcription factors (TF) to get a score for 
# every transcription factor for every cell type.
# Version:   0.1
# Date:      2016-03-22
# Author:    Phil Fradkin (Monuj)
#
# Input:     Transcription Factor List.txt : ["Number", "Name"]
#            String Database: ["TF", "interacting gene" , "order of dist"]
#            Gsx Score list for every gene ["Gene", Gsx]
#
#            Other Database: TBD
#
# Output:    List of transcription Factors 
#
# Depends:
#
# ToDo:      Need to get getTFSubgraph() to run and get output (from Weave). Need to get Contrast.R to output a list of Gsx scores
# Notes:
#
# V 0.1:     
# ====================================================================
# PREP
# set working directory indicate your own directory





# load required data: Transcription factor list, STRGRAPH (for getTFSubgraph()), Gsx score list



load(paste(DEVDIR, "/contrast/sample1_contrast.RData", sep="")) 
# ====================================================================
#packages

if (!require(igraph, quietly=TRUE)) {
  install.packages("igraph")
  library(igraph)
}

if (!require(biomaRt)) {
  source("http://bioconductor.org/biocLite.R")
  biocLite("biomaRt")
  library("biomaRt")
}


# ====================================================================
#required files

#load get getTFSubgraph function
setwd(paste(DEVDIR, "/WEAVE", sep="")) 
source("WEAVE-STRING.R") 

#Need a set of gene scores from annotate load gsx
setwd(paste(DEVDIR, "/annotate", sep="")) 
source("gsea.R") 
#change file name
gene_scores = gsx

setwd(paste(DEVDIR, "/Assess", sep="")) 
#read transcription factor list
TF_List <- read.table("Transcription Factor List.txt")

#need to load STRGRAPH from WEAVE its currently default in WEAVE
#defalt is set to STRGRAPH look bellow in sub_s line 77

# ====================================================================
#functions

getTFscore <- function(TF, order=1) {
  TF_score <- 0
  #plot subgraph using tf
  sub_s <- getTFSubgraph(TF, GRAPH=STRGRAPH)
  #assume that one subgraph is created. Will figure out later for multiple cases
  sub <- sub_s[[1]]
  #use the subgraph to go through every gene in transcription factor's sphere of influence 
  
  
  for (j in 1:length(V(sub)$name)){
    #find every individual gene
    current_gene <- V(sub)$name[j]
    if (current_gene != TF){
      #acquire gene from Gsx score table
      Gsx <- gene_scores$gsx[levels(gene_scores$gene)== current_gene]
      if (length(Gsx) == 0 | is.null(Gsx)  ){
        Gsx <- 0
      }
    
      #Find the distance away from TF
      Lrn <- shortest.paths(graph <- sub, v <- current_gene, to <- TF)[1]
      if (Lrn == 0 | length(Lrn) == 0 ){
        warning("Lrn is either length 0 or is 0 itself. Automatically reset Lrn to 1")
        Lrn <- 1
        #set Lrn to 1 and print error
      }
      #Find the parent of gene distance from TF
      #Wite an if clause to check for 0 
      
      #acquire the names of genes leading to the TF recursively. These names will be later used to calculate the edges of the nodes
      parent1 <- get.shortest.paths(graph <- sub, from <- current_gene, to <- TF)$vpath[[1]][2]$name
      
      if (Lrn > 1){
        parent2 <- get.shortest.paths(graph <- sub, from <- parent2, to <- TF)$vpath[[1]][2]$name
        
        if (Lrn > 2){
          parent3 <- get.shortest.paths(graph <- sub, from <- parent3, to <- TF)$vpath[[1]][2]$name
        }
        
      }
      #edges are being duplicated
      if ( length(parent1) != 0) {
        Orn <- sum(Orn, (length(neighbors(sub, parent1, mode = "all"))/2 ))
      }
      #check if parent2 exists if yes add the edges to Orn
      if (length(parent2) != 0) {
        Orn <- sum(Orn, (length(neighbors(sub, parent2, mode = "all"))/2 ))
      }
      if (length(parent3) != 0) {
        Orn <- sum(Orn, (length(neighbors(sub, parent3, mode = "all"))/2))
      }

      #check if Orn is 0 or length 0. Both impossible
      if (Orn == 0 | length(Orn) == 0 ){
        warning("Orn is either length 0 or is 0 itself. Automatically reset Orn to 1")
        Orn <- 1
        #set Orn to 1 and print error
      }
      
      #calculate score
      Gene_score <- Gsx * (1/(Lrn*Lrn)) * (1/Orn)
      if (length(Gene_score) == 0){
        message("Gene_score equals numeric(0) for ",`current_gene`)
        Gene_score <- 0
      }
      if (is.null(Gene_score)){
        message("Gene_score equals Null for ",`current_gene`)
        Gene_score <- 0
      }
      if (is.na(Gene_score)){
        message("Gene_score equals NA for ",`current_gene`)
        Gene_score <- 0
      }
      #print(current_gene)
      #print(Gene_score)
      TF_score <- sum(TF_score , Gene_score)
      #attach the Gene score to subgraph data frame
    }
  }
  print( cat("score for transcription factor", TF ,TF_score))
  return (TF_score)
}


# ====================================================================
# 
# create a data frame into which we write transcription factors and their scores
tf_score.df <- matrix(nrow = length(TF_List[,1]), ncol = 1, dimnames = list(c(levels(TF_List[,1])), c( "SCORE")))



 for (i in 1:length(TF_List[,1])){
   #acquire transcription factor 
   tf <- levels(TF_List[,])[i]
   # run get tf on every transcription factor and write score
   score = getTFscore(tf)
   #attach the score to the data frame
   tf_score.df[tf,] = score
}



   
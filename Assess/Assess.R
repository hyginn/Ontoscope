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
setwd(paste(DEVDIR, "/WEAVE", sep=""))

source("WEAVE-STRING.R") 

setwd(paste(DEVDIR, "/Assess", sep="")) 

# load required data: Transcription factor list, STRGRAPH (for getTFSubgraph()), Gsx score list

TF_List = read.table("Transcription Factor List.txt")
# read gene scores Gsx TO ADD

load(paste(DEVDIR, "/contrast/sample1_contrast.RData", sep="")) 

# ====================================================================
#functions

getTFscore <- function(TF, order=1) {
  
  #plot subgraph using tf
  sub_s = getTFSubgraph(tf)
  #assume that one subgraph is created. Will figure out later for multiple cases
  sub = sub_s[[1]]
  #use the subgraph to go through every gene in transcription factor's sphere of influence 
  
  
  for (j in 1:length(V(sub)$name)){
    #find every individual gene
    gene = V(sub)$name[j]
    #acquire gene from Gsx score table
    Gsx = gsx_fantomCounts_500g_5s$gsx[levels(gsx_fantomCounts_500g_5s$gene)== j]
    #Find the distance away from TF
    Lrn = shortest.paths(graph = sub, v = gene, to = TF)[1]
    #Find the parent of gene distance from TF
    Orn = length(neighbors(sub, tf, mode = 1))
    #calculate score
    Gene_score = Gsx * (1/Lrn) * (1/Orn)
    
    #attach the Gene score to subgraph data frame
    
  }
  
}


# ====================================================================
# 
 for (i in 1:length(TF_List[,1])){
   #acquire transcription factor 
   tf = levels(TF_List[,])[i]
   #plot subgraph using tf
   sub_s = getTFSubgraph(tf)
   #assume that one subgraph is created. Will figure out later for multiple cases
   sub = sub_s[[1]]
   #use the subgraph to go through every gene in transcription factor's sphere of influence 
   
   for (j in 1:length(V(sub)$name)){
     #find every individual gene
     gene = V(sub)$name[j]
     #acquire gene from Gsx score table
     Gsx = 1
     #Find the distance away from TF
     Lrn = 1
     #Find the parent of gene distance from TF
     Orn = 1
     #calculate score
     Gene_score = Gsx * (1/Lrn) * (1/Orn)
     
     #attach the Gene score to subgraph data frame
     
   }
   
   # sum the scores of genes (all the Gene_score values) to get a final value of TF
   
   #attach the value of the TF to TF_List
   
}



   
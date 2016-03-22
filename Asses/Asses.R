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
setwd("C:/Users/Lenovo/Desktop/BCB420/Ontoscope/WEAVE")

source("WEAVE-STRING.R") 

setwd("C:/Users/Lenovo/Desktop/BCB420/Ontoscope/Asses")

# load required data: Transcription factor list, STRGRAPH (for getTFSubgraph()), Gsx score list

TF_List = read.table("Transcription Factor List.txt")
# read gene scores Gsx TO ADD

# ====================================================================
#load packages


# ====================================================================
# 
 for (i in 1:length(TF_List[,1])){
   #acquire transcription factor 
   tf = levels(TF_List[,])[i]
   #plot subgraph using tf
   subgraph = getTFSubgraph(tf)
   
   #use the subgraph to go through every gene in transcription factor's sphere of influence 
   
   for (j in 1:length(subgraph[,1])){
     #find every individual gene
     gene = subgraph(,2)[i]
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



   
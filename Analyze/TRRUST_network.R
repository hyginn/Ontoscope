# Purpose:   Import the TRRUST network and allow Easy Filtering and Visualization
# Version:   1.0.0
# Date:      2016-03-25
# Author(s): Dmitry Horodetsky
# 
# Version     0.5.0 - initial commit
#
#             0.7.0 - added weighing capability, added clustering capability
#                     added randomGene() selection
#             
#             1.0.0 - added PMID labeling, added action (Activation, Repression, Unknown) labeling
#                     added a "freeze" graphing mode for large graphs        
#
#             




if (!require(data.table, quietly=TRUE)) {
  install.packages("data.table")
  library(data.table)
}

if (!require(igraph, quietly=TRUE)) {
  install.packages("igraph")
  library(igraph)
}

if (!require(visNetwork, quietly=TRUE)) {
  install.packages("visNetwork")
  library(visNetwork)
}

##########################
#  ***PRE-PROCESSING***  #
##########################

####
#Check whether the 'trrust_rawdata.txt' file exists in Work Directory
####
.checkTRRUST <- function(){
  if (file.exists("trrust_rawdata.txt") == FALSE){
    message("The 'trrust_rawdata.txt' file is missing from your Work Directory ") & stop()
  }
}
.checkTRRUST()

####
#Function to Load the TRRUST network into a (user-defined) dataframe
####

loadTRRUST <- function(){
  fread("trrust_rawdata.txt", header=FALSE, stringsAsFactors = FALSE, showProgress = FALSE, data.table = FALSE)
}

####
#Fix the Column Names
####

#x is the dataframe "name" where you imported your TRRUST network into


fixColumns <- function(x){
  colnames(x)[1] <- "TF_gene"
  colnames(x)[2] <- "nonTF_gene"
  colnames(x)[3] <- "interaction"
  colnames(x)[4] <- "PMID"
  return(x)
  
}

###########################
#***FILTERING FUNCTIONS***#
###########################


###
#Select Type of interactions
###

#type is the type of interaction: Unknown, Repression, Activation
#x is your TRRUST data.frame

#invert selection. By default is FALSE
#default mode of the function is to KEEP your type

#if you set invert to TRUE. Eg:
#function(x,"Activation",TRUE)
#It will return everything EXCEPT "activation" interactions
#ie your selection is inverted


typeSelect <-function(x, type,invert_mode){
  if (type != "Unknown" & type != "Activation" & type != "Repression"){
    message("Only three Arguments are supported 'Activation', 'Repression' or 'Unknown'. You can only use these arguments one at a time.")
  } else {
    
    if (missing(invert_mode)){
      invert_mode <- FALSE
    }
    
    type_filter <- grep(type,x[,3], invert=invert_mode)
    return(x[type_filter,])
  }
}

###
#Generate a Gene "character" file. Done for your convenience. Feed it into the filter gene function
###

genGeneChar<-function(){
  gene_char <- character()
  
  repeat_loop = TRUE
  while (repeat_loop){
    index <- as.numeric(length(gene_char))+1
    gene <- readline(prompt="Please enter your GENE Name. No quotes. (eg: 'AIRE'): ")
    gene_char[index]<-gene
    
    choice <- as.numeric(readline(prompt="Use '1' to add more genes. Use '2' to finish. No quotes please. Choice: "))
    
    if (choice == 2){
      break 
    } 
  }
  return(gene_char)
}

####
#Pick Random Genes
####

#x is your trrust dataframe
#number is how many random Genes you'd like to select

randomGenes <-function(x,number){
  
  .checkMode()
  return(as.character(sample(x[,as.numeric(trrust_network_mode[1])],number)))
}

####
#Filter Genes using a generated "character" file
####

#x is the name of the dataframe which has your TRRUST network data
#gene_char is your genes in a 'character' format

filterGenes <- function(x,gene_char){
  
  .checkMode()
  filtered_genes <- which(x[as.numeric(trrust_network_mode[1])][,] %in% gene_char)
  return (x[filtered_genes,])
}

###########################
#*NODE AND EDGE FUNCTIONS*#
###########################

#HUGE shoutout to Nicole White from rneo4j.com
#Some of the clustering and weighing were based on her ideas



###
#Get Edges
###

#x is a dataframe where you imported your TRRUST network into

getEdges <-function(x){
  igraph_object <- graph.data.frame(x)
  edges <- data.frame(get.edgelist(igraph_object))
  
  #Fix the Column Names
  colnames(edges)[1] <- "from"
  colnames(edges)[2] <- "to"
  
  
  return(edges)
  
}

###
#Get Nodes
###

#x is a dataframe where you imported your TRRUST network into



getNodes <- function(x){
  nodelist_1 <- as.character(unique(x[,1]))
  nodelist_2 <- as.character(unique(x[,2]))
  nodelist_final <- unique(c(nodelist_1,nodelist_2))
  
  length <- length(nodelist_final)
  
  #Its a clunky solution, but I need to do some pre-allocation
  nodes<-data.frame(matrix(nrow = length), stringsAsFactors = FALSE)
  nodes$id <-nodelist_final
  nodes$label <-nodelist_final
  nodes[1]<-NULL
  
  return (nodes)
}

####
#Use 'Centrality' to generate weights
####

#Note: You use the "edges" data.frame to generate centrality values
#BUT you assign these values to the "nodes" data.frame

getWeights <- function(nodes,edges){
  igraph_edges <-graph_from_data_frame(edges)
  nodes$value = betweenness(igraph_edges, directed = FALSE)
  return (nodes)
  
}

####
#Use Centrality to Cluster by Colour
####

getClusters <- function(nodes,edges){
  igraph_edges = graph_from_data_frame(edges, directed=FALSE)
  clusters = cluster_edge_betweenness(igraph_edges)
  nodes$group = clusters$membership
  return(nodes)
}

###
#Add PMIDs to Edges
###

#You need the edges file and your TRRUST network

getPMIDs <- function(edges,trrust){
  #Remove Multiple PMIDs (for neatness) and add a "PMID:" prefix
  title <- apply(trrust[4], 2, function (x) as.character(gsub(";.*$","",x)))
  title <- apply(title, 2, function (x) paste0("PMID:",x))
  
  edges$title <- c(title)
  
  return(edges)
}

getAction <- function(edges,trrust){
  trrust[3] <- apply(trrust[3], 2, function (x) as.character(gsub("Activation","[A]",x)))
  trrust[3] <- apply(trrust[3], 2, function (x) as.character(gsub("Repression","[R]",x)))
  trrust[3] <- apply(trrust[3], 2, function (x) as.character(gsub("Unknown","[N/A]",x)))
  
  label <- c(trrust[,3])
  
  edges$label <- label

  return(edges)
}


##############################
#Visualization via visNetwork#
##############################

visGraph <-function(nodes,edges){
  visNetwork(nodes, edges, width = "100%") %>% visEdges(arrow = trrust_network_mode[2], font = list(align = "middle", size = "9", smooth = FALSE)) %>%
    visPhysics(solver = "forceAtlas2Based")
}

visGraph_f <-function(nodes,edges){
  visNetwork(nodes, edges, width = "100%") %>% visEdges(arrow = trrust_network_mode[2], font = list(align = "middle", size = "9", smooth = FALSE)) %>%
    visPhysics(solver = "forceAtlas2Based") %>% visIgraphLayout()
}

exportVis <- function(name){
  #write a check for nodes and edges later HERE
  network <- visGraph(nodes, edges)
  htmlwidgets::saveWidget(network, paste0(name,".html"))
}

exportVis_f <- function(name){
  #write a check for nodes and edges later HERE
  network <- visGraph_f(nodes, edges)
  htmlwidgets::saveWidget(network, paste0(name,".html"))
}
  
###################
#Helper Functions #
###################
setMode <- function(mode_num){
  if (mode_num == 1){
    trrust_network_mode <<- c(1,"to")
    message("Mode 1 - Search genes by known Tfs, Set!")
  }
  
  if (mode_num == 2){
    trrust_network_mode <<- c(2,"to")
    message("Mode 2 - Search TFs by known genes, Set!")
  }
  
  if ((mode_num != 2) & (mode_num != 1)) {
    message("ERROR!")
    message("Please Select the Proper Mode, using 'setMode():")
    message("setMode(1) - Have a list of TFs and want to find out what genes they affect")
    message("setMode(2) - Have a list of genes and want to find all TFs which affect those genes ")
  }
}

.checkMode <- function(){
  if (!exists("trrust_network_mode")){
    message("ERROR!")
    message("Please Select the Proper Mode, using 'setMode():")
    message("setMode(1) - Have a list of TFs and want to find out what genes they affect")
    message("setMode(2) - Have a list of genes and want to find all TFs which affect those genes ")
  }
}

message("Don't forget to use setMode(mode_num) before filtering!")



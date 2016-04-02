#Version 2.0


#If you want to understand the workflow you should go through this step by step

############################
#PROCESSING
############################
#Lets import the TRRUST_network.R module
source(file="TRRUST_network.R")

#Set the randomness seed, so everyone has the same "random" result
set.seed(25)

#Let's import our trrust network into a dataframe
trrust <- loadTRRUST()

#By default the column names area bit weird, so lets fix them
trrust <- fixColumns(trrust)

############################
#Filtering
############################


##########IMPORTANT!#############
#First we need to decide which Mode we want to use
#Mode 1: Have a list of TFs and want to find out what genes they affect
#Mode 2: Have a list of genes and want to find all TFs which affect those genes 
##########IMPORTANT!#############

#Lets do Mode 1

setMode(1)


#Lets pick our genes. The module takes genes as a character file

#We have 3 ways of getting picking genes:

#1) We can subset some other dataframe and generate a character file
#2) We can use genGeneChar(), an interactive module to help you generate the character file
#3) We can geta random selection using randomGenes()

#Lets use 3)


#x is your trrust dataframe

#number is how many random Genes you'd like to select

genes <- randomGenes(trrust,2)

#Now lets select the type of interaction we want these genes to display
#the TRRUST database has "Activation", "Repression" and "Unknown"

#If you want to use "Activation" and remove all other types

#trrust <- typeSelect(trrust,"Activation")

#This wil filter out all other interactions from the trrust database

#In this example I want all interactions

####PROTIP!###########
#Let's say you want to remove all Unknown Interactions
#Well in this case you would use "invert" mode
# trrust<-typeSelect(trrust,"Unknown",TRUE)
#By default invert mode is off (FALSE)
#So you don't have to specify this everytime
####PROTIP!###########


#Lets filter the trrust database so it only contains our genes of interest

#x is the name of the dataframe which has your TRRUST network data
#gene_char is your genes in a 'character' format

trrust <- filterGenes(trrust,genes)

############################
#Visualization
############################

#The main idea is to use visNetwork as a "frontend" to display nice graphics
#and iGraph as a "backend" for the calculations. 

#Lets get our nodes
nodes <- getNodes(trrust)

#Lets get our edges
edges <- getEdges (trrust)

#Lets get centrality. We use the edges to calculate centrality
#but store them in the Nodes file

nodes <- getWeights(nodes,edges)

#Lets cluster using these centralities. Once again we use edges to calculate
#and Nodes to store

nodes <- getClusters(nodes,edges)

#Lets add "PMIDs" to all interactions. These appear when you hover over the edge

edges <- getPMIDs(edges,trrust)

#Lets add a label to the edges so we know what type of interaction it is

edges <- getAction(edges,trrust)




#######################
#THE BIG MOMENT!
#######################

#Lets generate a visNetwork graph
#They take awhile to load.
#You can use your mouse/trackpad to zoom

visGraph(nodes,edges)

#and if you want to export:

exportVis("workflow_new")

#this will save a workflow.html in your working directory


#You can play around with various networks by setting the seed to random numbers
#You can also experiment with various numbers of target genes
#I couldn't render the entire file (8000 genes)
#I couldn't render 100 genes either
#I think the limit is around 50 (but I need to further check)

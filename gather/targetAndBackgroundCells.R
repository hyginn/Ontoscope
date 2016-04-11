# Purpose:    improve the definition of target/background, 
#             perhaps with an interactive component? Supporting 
#             visualization could show the distribution of target 
#             and background on the Ontology tree - e.g. as green/red 
#             coloured sections of the tree.
#
# For detail: http://steipe.biochemistry.utoronto.ca/abc/students/index.php/User:Ryoga/TargetAndBackground
#
# Version:   v1.0
# Date:      2016-04-07
# Author:    Ryoga
#
# Input: 
#     1. A cell ontology graph (tree)
#     2. Target cell line
#
# Output:
#     A graph(tree) with target cell highlighted in blue and background cell in red,
#     all the nodes in between are highlighted in grey
#
# ToDo (Steps):
#     4. test with our tree from phlify and format the tree nicely
#
# DONE:
#     1. Define target cell and background cells (Input)
#     2. Based on the input, highlight two kinds of cells
#     3. function selectCells
# 
# v1.0: all the functions are tested 
# ====================================================================
# setwd(DEVDIR)
# set working dir
setwd("~/Desktop/BCB420/dev/")

# =================  PARAMETERS AND INPUT FILES  ====================

source("./gather/gather.R")
source("./phylify/ontology-explorer.r")
# Tree from philfy
# G <- COdat #1039 vertices and 1186 edges


highlightCells <- function(G, cells, Ncolor){
  ###
  # Returns an igraph object with desired cell(s) highlighted
  # @param
  #     G: igraph object
  #     cells: A vector containing desired cell(s)
  #     Ncolor: A string states the color for the node(s)
  ###
  for(i in cells){
    V(G)[i]$color <- Ncolor
  }
  return(G)
  
}

selectCells <- function(G, targetCell, backgroundCells, minPar, maxPar){
  ###
  # Returns an igraph object with all the cells in between target cell and background cells
  # @param
  #     G: igraph object
  #     targetCell: target cell (cell of interest)
  #     backgroundCells: background cells defined by minPar and maxPar (SEE GATHER)
  #     minPar: the number of edges upstream any target cell to the first common ancestor to include in the background
  #     maxPar: the number of edges to the last common ancestor.
  ###
  
  # get all parents between levels for target cell
  tarCellParents <- get_parents_between_levels(G, targetCell, minPar, maxPar)
  
  # get all parents between levels for background cells
  bkCellParents <- c()
  for(cell in backgroundCells){
    bkCellParents <- c(bkCellParents, get_parents_between_levels(G, cell, minPar, maxPar))
  }
  
  nodes_in_between <- unique(c(tarCellParents, bkCellParents))
  
  return(nodes_in_between)
}

clearG <- function(G){
  ###
  # Clear the highlights on a graph
  ###
  V(G)$color <- NA
  return(G)
}

# =================  TEST  ====================

# def minCellUp and maxCellUp
minPar = 1
maxPar = 2

# create an igraph object for testing
# I have created a really simple tree to demostrate the code
# For details please ref to the wiki page
# link: http://steipe.biochemistry.utoronto.ca/abc/students/index.php/User:Ryoga/TargetAndBackground
Nnames <- c("FF:30000-145H3", "FF:0000005", "FF:10000-145H9", "FF:0000007", "FF:0000002", "FF:0000003", "FF:0000001", "FF:20000-145H4", "FF:0000010")
Eds <- c("FF:0000002", "FF:0000002", "FF:0000003", "FF:0000003", "FF:0000001", "FF:0000001", "FF:0000008","FF:0000008", "FF:0000011")
d<- data.frame(Nnames,Eds)
G <- graph.data.frame(d, directed=TRUE, vertices=NULL)
plot(G)

# Use functions from GATHER to find target and background cell
# with cells[1] = target and others are background
cells <- head(gatherOne("FF:0000003", G, minPar, maxPar), -1)
targetcell <- cells[1]
backgroundcells <- cells[-1]

# Highlight target cell as blue
# Highlight background cells as red
G <- highlightCells(G, targetcell, "blue")
G <- highlightCells(G, backgroundcells, "red")
# plot(G)

# Find all cells in between target and back ground cells
cellInBetw <- selectCells(G, targetcell, backgroundcells, minPar, maxPar)
# Highlight them in grey
G <- highlightCells(G, cellInBetw, "grey")

plot(G)

# clear the coloring
G <- clearG(G)
plot(G)



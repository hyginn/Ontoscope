# GATHER module: takes in igraph fro phyliphy, 
# and for each cell-line produces a dataframe with gene expression counts further used in CONTRAST
# Version:   3.0
# Date:      2016-03-22
# Author: Eugenia Barkova

# install necessary packages
if (!require(igraph, quietly=TRUE)) {
  install.packages("igraph")
  library("igraph")
}

### load fantom and phylify modules 
#####
#Load CO Database
#####
.check_CO_DB <- function(){
  if (file.exists("./phylify/COdat.RData")){
    load('./phylify/COdat.RData', envir = globalenv())
    message ('COdat.RData Loaded!')
  } else { stop("COdat.RData not found. Please put it in your working directory")
  }
}
.check_CO_DB()

source("~/BCB420/dev/fantom_import/fantom_main.R")
FFDashesRegex <- "^FF:[0-9]+-[0-9]+[A-Z][0-9]$"
FFSimpleRegex <- "^FF:[0-9]{7}"

# Need a function in phylif that returns graph as a tree

gatherResults <- list() # list to hold dataframes with counts

###
# GatherCounts(): Returns a dataframe with counts for target cell line and its background in igraph G
# and a number of first columns in the dataframe are dedicated for target
### 

gatherCounts <- function(G, target, minPar, maxPar){
  result <- gatherOne(target, G, minPar, maxPar)
  cells <- paste(as.character(result[1]), collapse=", ") # format for fantom module
  ## call fantom and get counts data frame
  fantomOntology(cells)
  fantomSummarize() # get counts
  # update results
  gatherResults <- fantomCounts
  print(gatherResults)
  gatherResults <- c(gatherResults, result[2])
  return(gatherResults)
}

###
# Get ids of all parents
###
parents <- function (G, id) {
  ids <- as_ids(neighbors(G, id, mode="out"))
  
  return(ids)
}

###
# Get ids of all parents
###
children <- function (G, id) {
  ids <- as_ids(neighbors(G, id, mode="in"))
  return(ids)
}

###
# Get children with ids FF:x-y, since we only have counts data only for them
###
get_dashed_children <- function(G, id){
  ins <- as_ids(neighbors(G, id, mode="in"))
  insDashes <- ins[grep(FFDashesRegex, ins)]
  return(insDashes)
}

###
# Get all ids of the form FF:x from list of ids
###
get_simple_ff <- function(ids){
  #ins <- as_ids(neighbors(G, id, mode="in"))
  no_dash <- ids[grep(FFSimpleRegex, ids)]
  return(no_dash)
}


###
# Get all ids of ancestors of in_id starting at level minPar, and ending at maxPar
# where level 1 means the imediate parents of in_id
###
get_parents_between_levels <- function(G, in_id, minPar, maxPar){
  
  if (minPar > 1){
    par_between <- c()
  } else {
    par_between <- parents(G, in_id)
  }
  
  if (minPar == maxPar){
    par_between <- parents(G, in_id)
    return(par_between)
  }
  
  cur <- parents(G, in_id) # parent at level 1
  prev <- c()
  
  
  for (i in 2:maxPar){
    for (ids in cur){
      prev <- c(prev, parents(G, ids))
    }
    if (i >= minPar){
      par_between <- c(par_between, prev)
    }
    cur <- prev
  }
  
  return(unique(par_between))
}

###
# Get all ids of the tree below parents in the parent_list
###
get_all_children <- function(G, parents_list){
  
  all_children <- c()
  new_cur <- c()
  cur <- c()

  # go through the list of parents and get all their children with simple FF ids
  for (par in parents_list){
    cur <- children(G, par)
    cur <- get_simple_ff(cur) # filter out dashes
    for (c in cur){
      if (! c %in% all_children){
        all_children <- c(all_children, c) # add first children
      } 
    }
    
    # while there are children left
    while (length(cur) != 0){
      new_cur <- c()
      for (id in cur){
        cur_child <- children(G, id)
        cur_child <- get_simple_ff(cur_child)
        new_cur <- c(new_cur, cur_child) # establish a list for children at the next level
        all_children <- c(all_children, cur_child)
      }
      cur <- new_cur # look at next level
    }
  }
  
  return(all_children)
}


###
# GatherOne(): background counts for one cell line ####
###

gatherOne <- function(target_cell, G, minPar, maxPar){
  ## go up the tree till minPar threshold
  not_included <- c(target_cell, get_parents_between_levels(G, target_cell, 1, minPar - 1))
  
  # get all parents from minPar to maxPar
  relevant_parents <- get_parents_between_levels(G, target_cell, minPar, maxPar)
  # get all children of these parents
  relevant_children <- unique(get_all_children(G, relevant_parents))
  relevant_children <- relevant_children[!relevant_children %in% not_included]
  relevant_nodes <- unique(c(relevant_parents, relevant_children))
  
  # get dashes only
  background <- c()
  for (node in relevant_nodes){
    background <- c(background, get_dashed_children(G, node))
  }
  target_dashed <- get_dashed_children(G, target_cell)
  background <- unique(c(target_dashed, background))
  # returns the list of dashed FFs for target and background + 
  # how many of the first columns are for target
  return(c(background, length(target_dashed)))
}

gatherCounts(COdat, "FF:0000592", 2, 4)

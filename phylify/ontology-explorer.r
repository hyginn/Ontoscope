# ontology-explorer.r
#
# Purpose: Tools to aid heuristic subsetting of an OBO ontology
# Version: v0.5.0
# Date: Apr 12 2016
# Author: Julian Mazzitelli <mazzitelli.julian@gmail.com>
#
# Input: an .obo file
# Output: subsetted modifications as desired to the ontology, igraph object
#
# TODO: Unit tests on giving bad params. Design other test cases.
#
# Notes: This is meant to allow you to easily subset an ontology and view
# the resulting graph. By default it's methods will produce an igraph object,
# but this igraph will have been produced from base R data structures, so if
# you like, you could use a matrix for example.
#
# Changelog:
# v0.1.0
#   - initial draft
# v0.2.0:
#   - add human samples, to filter out by category
# v0.3.0
#   - gets source,target FF and CNHs IDs from mogrify site source
# v0.4.0
#   - add propertyTypes to summarizeOBO
#   - get human OR mouse samples
#   - getMogrifyReplicasForID(ID) -> character vector
# v0.5.0
#   - comments
#   - use nicePath
#   - improved makeVisNetwork

nicePath <- function (filename) {
  tryCatch({
    return(file.path(getwd(), dirname(sys.frame(1)$ofile), filename))
  }, error = function (error) {
    return(filename)
  })
}

# BS> Ok - but biocLite really only needs to be sourced once per session ...
# JM> Yeah, but `if (!require(x)) source("biocLite.R"); biocLite(x)`
# JM> would also source biocLite more than once if more than one bioconductor
# JM> package is missing. Ultimately I just like one line imports :D
getBioconductorPackage <- function (packageName) {
  source("https://bioconductor.org/biocLite.R")
  biocLite(packageName)
}

# === Packages ===

# BS> Missing comment: Why are these packages installed?What functions do they provide?

# Gene set enrichment data structures and methods
# BS> Especially here: this provides getOBOCollection. I would have looked for it in ontoCAT
# see: http://svitsrv25.epfl.ch/R-doc/library/GSEABase/html/OBOCollection-class.html
if (!require(GSEABase, quietly=TRUE)) getBioconductorPackage("GSEABase")

# basic operations with ontologies
# for a quick API overview, see: https://github.com/hyginn/Ontoscope/tree/master/phylify#ontocat
# mostly loaded since it can help with a "producing COdat" workflow,
# but is not actually used here.
if (!require(ontoCAT, quietly=TRUE)) getBioconductorPackage("ontoCAT")

# R bindings to C based network analysis package igraph
# used in getIgraph
if (!require(igraph, quietly=TRUE)) install.packages("igraph")

# talk to vis.js, with igraph!
# used in makeVisNetwork
# see: http://dataknowledge.github.io/visNetwork/
if (!require(visNetwork, quietly=TRUE)) install.packages("visNetwork")

# JSON <-> data frame
# used for fromJSON in getMogrify*
if (!require(jsonlite, quietly=TRUE)) install.packages("jsonlite")

# === Modules ===
# used for convertIDs in getMogrifyCNhsIDs
source("fantom_ont_conv/fantom_ont_conv.R")

# === Constants ===
CHARACTER <- "character"
OBO_COLLECTION <- "OBOCollection"
TERM <- "Term"
IS_A <- "is_a"

# === Functions ===

# getOBO(source) -> OBOCollection
# @param <string> source url or file containing ontology
# @returns OBOCollection
# see: http://svitsrv25.epfl.ch/R-doc/library/GSEABase/html/OBOCollection-class.html
getOBO <- function (source) {
  if (typeof(source) != CHARACTER) {
    stop("Please provide an atomic character: getOBO(<string>)")
# BS> I think it would be better to treat this as an exception, i.e. stop()
# BS> with appropriate error message.
# JM> Switched. I was only recently made aware of stop().
  }

  return(getOBOCollection(source))
}

# notOBOErr() -> string
# just to avoid repeat error messages
notOBOErr <- function() { stop("Please pass in a valid OBOCollection") }

# BS> Generally: structure your error messages as: expected..., got..., disposition (usually: Aborting.).

# BS> Defensive programming would not be required for many of these. getOBO() should
# BS> confirm success and since all consuming functions are your own, and don't
# BS> you can make stringer assumptions about imput validity.
# JM> These were intended to be consumed by a user, but ended up being internal.

# Some wrappers around slots just to make code more readable
getOBOStanzas <- function (obo) { return(obo@.stanza) }
getOBOSubsets <- function (obo) { return(obo@.subset) }
getOBOKeyVals <- function (obo) { return(obo@.kv) }

# Summarize helper functions
getNumTerms <- function (obo) {
  stanzas <- getOBOStanzas(obo)

  return(sum(stanzas$value == TERM))
}

getNumEdges <- function (obo) {
  keyVals <- getOBOKeyVals(obo)

  numEdges <- sum(keyVals$key == IS_A)
  return(numEdges)
}

getTermIDs <- function (obo) {
  stanzas <- getOBOStanzas(obo)

  return(rownames(stanzas)[which(stanzas$value == TERM)])
}

getTermTypes <- function (termIDs) {
  # NOTE this considers :, _, to be the same. may not be the case!
  # but only a few use _, so it is a good summary.
  termTypes <- unique(gsub("[:_][A-Za-z0-9-]+", "", termIDs))

  termTypeCounts <- c()
  # IDType -> ^IDType
  for (regex in lapply(termTypes, function (x) { paste("^", x, sep="") })) {
    count <- length(grep(regex, termIDs))
    termTypeCounts <- c(termTypeCounts, count)
  }

  termTypesDF <- data.frame(
    termType=termTypes,
    count=termTypeCounts
  )

  return(termTypesDF)
}

# Deprecating. Unneccessary wrapping around grep.
# getTermsMatched <- function (obo, regex, invert=FALSE) {
#   termIDs <- getTermIDs(obo)
#
#   matched <- termIDs[grep(regex, termIDs, invert=invert)]
#   return(matched)
# }

# summarizeOBO(<OBOCollection>) -> named list
# @param <OBOCollection> obo
# @returns named list
summarizeOBO <- function (obo, head=FALSE, n=20L) {
  # First question, how many [Term]s?
  numTerms <- getNumTerms(obo)
  # And edges?
  numEdges <- getNumEdges(obo)
  # What are there IDs?
  termIDs <- getTermIDs(obo)
  # And there types?
  termTypes <- getTermTypes(termIDs)
  propertyTypes <- unique(obo@.kv$key)

  # head() the longer ones if desired
  if (head) {
    numTerms <- head(numTerms, n=n)
    termIDs <- head(termIDs, n=n)
  }

  summary <- list(
    numTerms=numTerms,
    numEdges=numEdges,
    termIDs=termIDs,
    termTypes=termTypes,
    propertyTypes=propertyTypes
  )

  return(summary)
}

# === igraph utils ===
getIgraph <- function (obo) {
  return(igraph.from.graphNEL(as(obo, "graphNEL"), name=TRUE, weight=TRUE, unlist.attrs=TRUE))
}

filterByGood <- function (G, goods) {
  set <- as_ids(V(G))

  return(delete_vertices(G, set[!(set %in% goods)]))
}

filterByBad <- function(G, bad) {
  return(delete_vertices(G, bad))
}

# makeVisNetwork -> <visNetwork>
# Make visNetworks, and customize with params:
# @param smooth <logical> whether or not to use curved edges. warning: slower!
# @param useLabel <logical> whether or not to take label attribute. use false if your nodes don't have a label
# @param cluster <logical> whether or not to cluster (with clusterAlg)
# @param clusterAlg <FUN> the igraph function to cluster by
# @param clusterAsUndirected <logical> whether to cast graph to cluster to be undirected. some algs. only work on undirected
# @param customGroups <logical> whether or not to use your own custom $group vertex attributes
# @param hierarchicalLayout <logical> whether or not to let vis.js compute a hierarchical layout
# @param levelSeparation <number> for vis.js hierarchical layout
# @param direction <string> direction of tree for hierarchical layout
# @param igraphLayout <logical> whether or not to compure layout on igraph side vs vis.js side
# @param layout <string> the name of the igraph layout function to use
makeVisNetwork <- function (graph,
  smooth=FALSE, useLabel=TRUE,
  cluster=TRUE, clusterAlg=cluster_edge_betweenness, clusterAsUndirected=FALSE,
  customGroups=FALSE,
  hierarchicalLayout=FALSE, levelSeparation=250, direction="UD",
  igraphLayout=TRUE, layout="layout_nicely") {

  nodes <- as_data_frame(graph, what="vertices")
  if (useLabel) {
    nodes <- data.frame(id=nodes$name, label=nodes$label)
  } else {
    nodes <- data.frame(id=nodes$name, label=nodes$name)
  }

  if (cluster) {
    if (clusterAsUndirected) {
      clusters <- clusterAlg(as.undirected(graph))
    } else {
      clusters <- clusterAlg(graph)
    }

    nodes$group = clusters$membership
  }

  # customGroups takes precedence over cluster
  if (customGroups) {
    nodes$group <- as_data_frame(graph, what="vertices")$group
  }

  edges <- as_data_frame(graph, what="edges")

  visNet <- visNetwork(nodes, edges, width="100%")

  if (hierarchicalLayout) {
    visNet <- visHierarchicalLayout(visNet, direction=direction, levelSeparation=levelSeparation)
  } else if (igraphLayout) {
    visNet <- visIgraphLayout(visNet, layout=layout)
  }

  visNet <- visNodes(visNet, size=5)
  visNet <- visEdges(visNet, arrows="to", smooth=smooth)

  visNet

  return(visNet)
}

# === Human+Mouse Samples ===
getSamples <- function (file) {
  # Use HumanSamples CSV to help subset
  samples <- read.csv(file)

  # Yes, they spelt characteristics wrong. two ways wrong.
  colnames(samples) <- gsub(".$", "", gsub("Cha?rac?teristics..", "", colnames(samples)))

  return(samples)
}

getHumanSamples <- function() {
  return(getSamples(nicePath("./samples/HumanSamples2.0.sdrf.csv")))
}

getMouseSamples <- function() {
  return(getSamples(nicePath("./samples/MouseSamples2.0.sdrf.csv")))
}

getFFByCategory <- function (humanSamples, category) {
  ffIDs <- humanSamples$ff_ontology[(humanSamples$Category %in% category)]

  return(ffIDs)
}

# === Mogrify Data Utils ===
getMogrifyIDs <- function() {
  return(fromJSON(nicePath("./getMogrifyCells/mogrify-cellIDs.json"))$ID)
}

# this depends on an internet connection, and node. and being "here"
# It was used to verify our replicates vs. Mogrify's replicates for an FF cell ID
getMogrifyCNhsIDs <- function(source, target) {
  cmd <- paste("node getMogrifyCNhs/get.js", source, target)
  df <- fromJSON(system(cmd, intern=TRUE))
  df$val <- lapply(df$val, convertIDs)

  return(df)
}

getMogrifyReplicasForID <- function (ID) {
  df <- getMogrifyCNhsIDs(source=ID, target="FF:0000592")
  IDs <- df[df$type == "source",]$val

  return(as.character(IDs))
}

# [END]

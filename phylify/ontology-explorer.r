# ontology-explorer.r
#
# Purpose: Tools to aid heuristic subsetting of an OBO ontology
# Version: v0.4.0
# Date: Mar 23 2016
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

# BS> Ok - but biocLite really only needs to be sourced once per session ...
getBioconductorPackage <- function (packageName) {
  source("https://bioconductor.org/biocLite.R")
  biocLite(packageName)
}

# === Packages ===

# BS> Missing comment: Why are these packages installed?What functions do they provide?

# Gene set enrichment data structures and methods
# BS> Especially here: this provides getOBOCollection. I would have looked for it in ontoCAT
if (!require(GSEABase, quietly=TRUE)) getBioconductorPackage("GSEABase")

# basic operations with ontologies
if (!require(ontoCAT, quietly=TRUE)) getBioconductorPackage("ontoCAT")

# R bindings to C based network analysis package igraph
if (!require(igraph, quietly=TRUE)) install.packages("igraph")

# talk to vis.js, with igraph!
if (!require(visNetwork, quietly=TRUE)) install.packages("visNetwork")

# JSON <-> data frame
if (!require(jsonlite, quietly=TRUE)) install.packages("jsonlite")

# === Modules ===
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
    return("Please provide an atomic character: getOBO(<string>)")
# BS> I think it would be better to treat this as an exception, i.e. stop()
# BS> with appropriate error message. 

  }

  return(getOBOCollection(source))
}

# notOBOErr() -> string
# just to avoid repeat error messages
notOBOErr <- function() { return("Please pass in a valid OBOCollection") }

# BS> Generally: structure your error messages as: expected..., got..., disposition (usually: Aborting.). 

# BS> Defensive programming would not be required for many of these. getOBO() should
# BS> confirm success and since all consuming functions are your own, and don't
# BS> you can make stringer assumptions about imput validity.


# Some wrappers around slots just to make code more readable
getOBOStanzas <- function (obo) {
  if (class(obo)[1] != OBO_COLLECTION) return(notOBOErr())

  return(obo@.stanza)
}
getOBOSubsets <- function (obo) {
  if (class(obo)[1] != OBO_COLLECTION) return(notOBOErr())

  return(obo@.subset)
}
getOBOKeyVals <- function (obo) {
  if (class(obo)[1] != OBO_COLLECTION) return(notOBOErr())

  return(obo@.kv)
}


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
getTermsMatched <- function (obo, regex, invert=FALSE) {
  termIDs <- getTermIDs(obo)

  matched <- termIDs[grep(regex, termIDs, invert=invert)]
  return(matched)
}

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

getIgraph <- function (obo) {
  return(igraph.from.graphNEL(as(obo, "graphNEL"), name=TRUE, weight=TRUE, unlist.attrs=TRUE))
}

makeVisNetwork <- function (graph, customLayout="layout_nicely") {
  nodes <- as_data_frame(graph, what="vertices")
  # colnames(nodes) <- c("id")
  nodes <- data.frame(id=nodes$name, label=nodes$name)

  edges <- as_data_frame(graph, what="edges")
  visNetwork(nodes, edges, width = "100%") %>%
    visIgraphLayout(layout = customLayout) %>%
    visNodes(size=5) %>%
    visEdges(arrows="to")
}

# === Human Samples ===
getSamples <- function (file) {
  # Use HumanSamples CSV to help subset
  samples <- read.csv(file)

  # Yes, they spelt characteristics wrong. two ways wrong.
  colnames(samples) <- gsub(".$", "", gsub("Cha?rac?teristics..", "", colnames(samples)))

  return(samples)
}
getHumanSamples <- function() {
  return(getSamples("./samples/HumanSamples2.0.sdrf.csv"))
}
getMouseSamples <- function() {
  return(getSamples("./samples/MouseSamples2.0.sdrf.csv"))
}


getFFByCategory <- function (humanSamples, category) {
  ffIDs <- humanSamples$ff_ontology[(humanSamples$Category %in% category)]

  return(ffIDs)
}

getMogrifyIDs <- function() {
  return(fromJSON("./getMogrifyCells/mogrify-cellIDs.json")$ID)
}

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

filterByGood <- function (G, goods) {
  set <- as_ids(V(G))

  return(delete_vertices(G, set[!(set %in% goods)]))
}

filterByBad <- function(G, bad) {
  return(delete_vertices(G, bad))
}


# [END]

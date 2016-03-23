# ontology-explorer.r
#
# Purpose: Tools to aid heuristic subsetting of an OBO ontology
# Version: v0.1.0
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

# === Packages ===
# Gene set enrichment data structures and methods
if (!require(GSEABase, quietly=TRUE)) {
  # try http:// if https:// URLs are not supported
  source("https://bioconductor.org/biocLite.R")
  biocLite("GSEABase")
}

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
  }

  return(getOBOCollection(source))
}

# notOBOErr() -> string
# just to avoid repeat error messages
notOBOErr <- function() { return("Please pass in a valid OBOCollection") }

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

makeAdjMatrix <- function (obo) {
  termIDs <- getTermIDs(obo)
  N <- length(termIDs)

  G <- matrix(numeric(N*N), ncol=N)
  rownames(G) <- termIDs
  colnames(G) <- termIDs

  # for (i in 1:N-1) {
  #   for (j in (i+1):N) {
  #     print(G[i, j])
  #   }
  # }

  return(G)
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

  # head() the longer ones if desired
  if (head) {
    numTerms <- head(numTerms, n=n)
    termIDs <- head(termIDs, n=n)
  }

  summary <- list(
    numTerms=numTerms,
    numEdges=numEdges,
    termIDs=termIDs,
    termTypes=termTypes
  )

  return(summary)
}

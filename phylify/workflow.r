nicePath <- function (filename) {
  tryCatch({
    return(file.path(getwd(), dirname(sys.frame(1)$ofile), filename))
  }, error = function (error) {
    return(filename)
  })
}

# Example workflow using ontology-explorer.r

# BS> Missing author etc...
# BS> Not clear what the purpose is: what are the parameters to
# BS> create what (kind of) object? Should the output be
# BS> saved? Loaded later (where)? Why is this necessary? What
# BS> are the use cases ... etc. etc.

# Author: Julian Mazzitelli <mazzitelli.julian@gmail.com>
# Purpose: example uses of functions provided by ontology-explorer

# Tools for exploring (via subsetting) ontology
source("ontology-explorer.r")

# BS> Missing comment: what is this file?
# FANTOM Five phase2 ontology in OBO 1.2 format
FFP2 <- "ff-phase2-140729.obo"

# get an OBOCollection class object
fantom <- getOBO(FFP2)

# We can print out a quick summary to the console
# numTerms; numEdges; termIDS; termTypes with counts
summarizeOBO(fantom, head=TRUE, n=10L)

# Use the full length summary to begin exploring
# The idea is that anything relevant can be pulled out of the summary,
# like oboSummary$termIDs for example
fantomSummary <- summarizeOBO(fantom)

# BS> I don't get what's happening below. Whay one or the other? What
# BS> are the use cases? What are the options? How does one choose?
# JM> I am deprecating my function due to it mostly just wrapping grep.

# We can pull out the term IDs and grep them
fantomSummary$termIDs[grep("^EFO", fantomSummary$termIDs)]

# using ontoCAT
# most useful for getAllTerm(Parents|Children)ById
# ontoCAT wants an absolute path, hence normalizePath
fantomCAT <- getOntology(normalizePath(FFP2))

# Term IDs
termIDs <- getTermIDs(fantom)

# Get FF IDs, FF:X IDs, and FF:A-B IDs
FFs <- termIDs[grep("^FF:", termIDs)]
FFNumsRegex <- "^FF:[0-9]{7}"
FFNums <- FFs[grep(FFNumsRegex, FFs)]
FFDashesRegex <- "^FF:[0-9]+-[0-9]+[A-Z][0-9]$"
FFDashes <- FFs[grep(FFDashesRegex, FFs)]
length(FFs) == length(FFNums) + length(FFDashes)

# Get IDs that are on mogrify
mogrifyIDs <- getMogrifyIDs()
length(mogrifyIDs) # 279
# Everything is an FFNum
length(mogrifyIDs[grep(FFNumsRegex, mogrifyIDs)]) == length(mogrifyIDs)

# Get CNhsIDs as FF:A-B Ids
CNhsIDs <- getMogrifyCNhsIDs(source="FF:0000062", target="FF:0000592")
# Wraps around above to give back a character vector of "replicas" for an ID
myReplicas <- getMogrifyReplicasForID("FF:0000062")
# NOTE! These likely match (exactly) the incoming  edges to the FFNum ID

# Get FFIDs by species and category
humanSamples <- getHumanSamples()
# Different categories
# tissues, cell lines, primary cells, time courses, fractionations and pertubations
# levels(humanSamples$Category)
# Now we can get IDs by their categorie(s):
bads_human <- getFFByCategory(humanSamples, c("time courses", "fractionations and perturbations"))
goods_human <- getFFByCategory(humanSamples, c("cell lines", "primary cells"))
# and mouse:
mouseSamples <- getMouseSamples()
bads_mouse <- getFFByCategory(mouseSamples, c("time courses", "fractionations and perturbations"))
goods_mouse <- getFFByCategory(mouseSamples, c("cell lines", "primary cells"))

# Load up the fantom_import module
source(nicePath("../fantom_import/fantom_main.R"))
# Get all the FFDash IDs that we can pull samples for
DESeqable <- as.character(fantom_samples[!is.na(fantom_samples[,2]),2])
# But not everything in there is good!
length(DESeqable) # 1829
sum(DESeqable %in% goods_human) # 834

# Not doing this anymore to avoid losing replicates.
# DESeqable <- DESeqable[DESeqable %in% goods_human]

# igraph
G <- getIgraph(fantom)

# COdat is a filtered version of G

# BS> Not sure this should happen here, rather than filtering for valid nodes
# BS> and edges before the graph is built ...

# We can first try taking only the DESeqable IDs, but this gives 0 edges
COdat <- filterByGood(G, DESeqable)


# BS> What does makeVisNetwork() return? Or do?
# BS> (Not documented in your code.)
# JM> Documented now.
makeVisNetwork(COdat, useLabel=FALSE)

# Taking all FFNums and FFDashes
COdat <- filterByGood(G, termIDs[grep("^FF", termIDs)])
COdat <- filterByBad(G, termIDs[grep("^FF", termIDs, invert=TRUE)])
makeVisNetwork(COdat, cluster=FALSE, useLabel=FALSE)

# Taking all FFNums
COdat <- filterByGood(G, FFNums)
makeVisNetwork(COdat, cluster=FALSE, useLabel=FALSE)

# Taking all FFNums and DESeqable FFDashes
COdat <- filterByGood(G, c(FFNums, DESeqable))
makeVisNetwork(COdat, cluster=FALSE, useLabel=FALSE)

# Taking only mogrifyIDs
COdat <- filterByGood(G, mogrifyIDs)
makeVisNetwork(COdat, cluster=FALSE, useLabel=FALSE)

# Taking mogrifyIDs and DESeqables
COdat <- filterByGood(G, c(mogrifyIDs, DESeqable))
makeVisNetwork(COdat, cluster=FALSE, useLabel=FALSE)

save(COdat, file="COdat.RData")

# [End]

# Example workflow using ontology-explorer.r

# BS> Missing author etc...
# BS> Not clear what the purpose is: what are the parameters to
# BS> create what (kind of) object? Should the output be
# BS> saved? Loaded later (where)? Why is this necessary? What
# BS> are the use cases ... etc. etc.

# Tools for exploring (via subsetting) ontology
source("ontology-explorer.r")

# BS> Missing comment: what is this file?
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

# We can use the getTermsMatched function to grab IDs matching a regex
getTermsMatched(fantom, "^EFO")
head(getTermsMatched(fantom, "^FF", invert=TRUE))
# The "pure" alternatives are
rownames(fantom@.stanza)[which(fantom@.stanza$value == TERM)][grep("^EFO", rownames(fantom@.stanza)[which(fantom@.stanza$value == TERM)])]
# and
fantomSummary$termIDs[grep("^EFO", fantomSummary$termIDs)]
# is getTermsMatched good? Or unneccessary grep wrapping leading to requiring extra API knowledge..

# using ontoCAT
# most useful for getAllTerm(Parents|Children)ById
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
source("../fantom_import/fantom_main.R")
# Get all the FFDash IDs that we can pull samples for
DESeqable <- as.character(fantom_samples[!is.na(fantom_samples[,2]),2])
# But not everything in there is good!
length(DESeqable) # 1596
sum(DESeqable %in% goods_human) # 765
DESeqable <- DESeqable[DESeqable %in% goods_human]

# igraph
G <- getIgraph(fantom)

# COdat is a filtered version of G

# BS> Not sure this should happen here, rather than filtering for valid nodes
# BS> and edges before the graph is built ...

# We can first try taking only the DESeqable IDs, but this gives 0 edges
COdat <- filterByGood(G, DESeqable)


# BS> What does makeVisNetwork() return? Or do?
# BS> (Not documented in your code.)
makeVisNetwork(COdat)

# Taking all FFNums and FFDashes
COdat <- filterByGood(G, termIDs[grep("^FF", termIDs)])
COdat <- filterByBad(G, termIDs[grep("^FF", termIDs, invert=TRUE)])
makeVisNetwork(COdat, customLayout="layout_as_tree")
makeVisNetwork(COdat)

# Taking all FFNums
COdat <- filterByGood(G, FFNums)
makeVisNetwork(COdat)

# Taking all FFNums and DESeqable FFDashes
COdat <- filterByGood(G, c(FFNums, DESeqable))
makeVisNetwork(COdat)

# Taking only mogrifyIDs
COdat <- filterByGood(G, mogrifyIDs)
makeVisNetwork(COdat)

# Taking mogrifyIDs and DESeqables
COdat <- filterByGood(G, c(mogrifyIDs, DESeqable))
makeVisNetwork(COdat)

save(COdat, file="COdat.RData")


# === mini gather ===

# as_ids not working with neighborhood, which is too bad b/c order is nice
as_ids(neighborhood(COdat, order=2, "FF:0000592", mode="out"))
# but does with neighbours
as_ids(neighbors(COdat, "FF:0000592", mode="out"))

makeDashesBg <- function(G, FFID) {
  # takes one level out
  makeNumList <- function (G, id, closeDepth, farDepth) {
    ids <- as_ids(neighbors(G, id, mode="out"))

    return(ids)
  }

  dashes <- c()
  for (id in as.list(nums)) {
    ins <- as_ids(neighbors(COdat, id, mode="in"))
    insDashes <- ins[grep(FFDashesRegex, ins)]

    dashes <- c(dashes, insDashes)
  }

  return(dashes)
}

makeDashesBg(COdat, "FF:0000592")


# [End]

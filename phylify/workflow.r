# Example workflow using ontology-explorer.r

# Tools for exploring (via subsetting) ontology
source("ontology-explorer.r")

# get an OBOCollection class object
fantom <- getOBO("ff-phase2-140729.obo")

# We can print out a quick summary to the console
# numTerms; numEdges; termIDS; termTypes with counts
summarizeOBO(fantom, head=TRUE, n=10L)

# Use the full length summary to begin exploring
# The idea is that anything relevant can be pulled out of the summary,
# like oboSummary$termIDs for example
fantomSummary <- summarizeOBO(fantom)

# We can use the getTermsMatched function to grab IDs matching a regex
getTermsMatched(fantom, "^EFO")
head(getTermsMatched(fantom, "^FF", invert=TRUE))
# The "pure" alternatives are
rownames(fantom@.stanza)[which(fantom@.stanza$value == TERM)][grep("^EFO", rownames(fantom@.stanza)[which(fantom@.stanza$value == TERM)])]
# and
fantomSummary$termIDs[grep("^EFO", fantomSummary$termIDs)]
# is getTermsMatched good? Or unneccessary grep wrapping leading to requiring extra API knowledge..

termIDs <- getTermIDs(fantom)
bads <- termIDs[grep("^CHEBI", termIDs, invert=TRUE)]

# igraph
G <- getIgraph(fantom)

# Load up the fantom_import module
source("../fantom_import/fantom_main.R")

good_ids <- as.character(fantom_samples[!is.na(fantom_samples[,2]),2])

# This gives 0 edges
#G2 <- delete_vertices(G, termIDs[!(termIDs %in% good_ids)])

G2 <- delete_vertices(G, termIDs[grep("^FF", termIDs, invert=TRUE)])
makeVisNetwork(G2)

FFxs <- termIDs[grep("^FF:[0-9]+$", termIDs)]
good_ids2 <- c(good_ids, FFxs)
G2 <- delete_vertices(G, termIDs[!(termIDs %in% good_ids2)])
# This leaves us with less vertices with no edges:
V(G2)[igraph::degree(G2) == 0] %in% good_ids2

# With only FF:X
G2 <- delete_vertices(G, termIDs[grep("^FF:[0-9]+$", termIDs, invert=TRUE)])

# Get FFIDs by category
humanSamples <- getHumanSamples()
# Different categories
# tissues, cell lines, primary cells, time courses, fractionations and pertubations
# levels(humanSamples$Category)
# Now we can get IDs by their categorie(s):
bad <- getHumanFFByCategory(humanSamples, c("time courses", "fractionations and perturbations"))
goods_human <- getHumanFFByCategory(humanSamples, c("cell lines", "primary cells"))

length(good_ids) # 1596
sum(good_ids %in% goods_human) # 765

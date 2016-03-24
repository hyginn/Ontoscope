# Example workflow using ontology-explorer.r

source("ontology-explorer.r")

# get an OBOCollection class object
fantom <- getOBO("ff-phase2-140729.obo")

# retrieve stanzas, subsets, and key:value pairs
stanzas <- getOBOStanzas(fantom)
subsets <- getOBOSubsets(fantom)
keyVals <- getOBOKeyVals(fantom)
# There are much more get* methods, but they are mostly used internally
# to generate a nice summary object

# We can print out a quick summary to the console
summarizeOBO(fantom, head=TRUE, n=10L)

# Use the full length summary to begin exploring
# The idea is that anything relevant can be pulled out of the summary,
# like oboSummary$termIDs for example
fantomSummary <- summarizeOBO(fantom)

# We can use the getTermsMatched function to grab IDs matching a regex
getTermsMatched(fantom, "^EFO")
head(getTermsMatched(fantom, "^FF", invert=TRUE))

# Make an adjacency matrix
G <- makeAdjMatrix(fantom)

# Get the is_a's of a term
getTermParents(G, "CHEBI:24532")

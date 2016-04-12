# The current method of creating COdat
# Author: Julian Mazzitelli
# Date: Apr 12 2016

# see workflow for more comments

source("ontology-explorer.r")
source("../fantom_import/fantom_main.R")

fantom <- getOBO("ff-phase2-140729.obo")
mogrifyIDs <- getMogrifyIDs()
DESeqable <- as.character(fantom_samples[!is.na(fantom_samples[,2]),2])

G <- getIgraph(fantom)

# Take cell lines from Mogrify and all the replicates we have
COdat <- filterByGood(G, c(mogrifyIDs, DESeqable))

save(COdat, file="COdat.RData")

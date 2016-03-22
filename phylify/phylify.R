# phylify 0.0.1 pre-release
# see: https://github.com/thejmazz/ontoscope-phylify

# === Packages ===
# JSON <-> data frame
if (!require(jsonlite, quietly=TRUE)) install.packages("jsonlite")

# R bindings to igraph
if (!require(igraph, quietly=TRUE)) install.packages("igraph")

# Gene set enrichment data structures and methods
if (!require(GSEABase, quietly=TRUE)) {
    # try http:// if https:// URLs are not supported
    source("https://bioconductor.org/biocLite.R")
    biocLite("GSEABase")
}

# WebGL based graphs via plotly's JavaScript graphing library
# Pass *all* visualization configuration in with one JSON object
if (!require(plotly, quietly=TRUE)) install.packages("plotly")


# === Construct igraph object from .obo ===
# Assumes ff-phase2-140729.obo is in same directory as this script
# see: http://svitsrv25.epfl.ch/R-doc/library/GSEABase/html/getOBOCollection.html
fantom <- getOBOCollection("ff-phase2-140729.obo")

# fantom@.subset
# head(fantom@.kv)
# fantom@evidenceCode
# fantom@type
# fantom@.stanza
# fantom@ids
# length(fantom@ids) # 6170
# fantom@.subset
# fantom@ontology

# fantom@.kv is a list of stanza_ids
# this is confusing, since it also includes keys from the header
# (under the .__Root__ stanza_id)

ROOT_STANZA_ID = ".__Root__"

# Just to type less + readabilty
kv <- fantom@.kv
key_ids <- kv$stanza_id


# Get header IDs
headerIDs <- which(key_ids == ROOT_STANZA_ID)

# Okay, so we got rid of the headers. Good to go?
# Not so fast..

# tail(stanza_ids, n=30L)
# tail(fantom@.kv, n=30L)

# This parser does not distinguish between [Term]s and [Typedef]s...

# There are some [Typedef]s at the end.
# We can filter these out using grep, assuming that all good [Terms]
# look like "some capital ID, then :, then a capital ID of numbers or letters"
# This is quite sketchy. We are relying on ID string structure to filter
# out information which was already made explicit in the .obo file...
# A shortcoming bionode-obo will not have :)
# Another note on GSEABase#getOBOCollection is that we have lost value comments

# stanza_ids[grep("^[A-Za-z]+:[A-Z0-9-]+$", stanza_ids, invert=TRUE)]
# this gives us some ids such as CL_0000056 and NCBITaxon_10088
# After some inspection, it seems as though these IDs are different from there :
# counterparts. 

# This didn't work to keep .__Root__ out of assumed <- typedefs
# exclude_headers <- c(character(length(headerIDs)), key_ids[which(order(key_ids) != headerIDs)])
# assumed_typedefs <- grep("^[A-Za-z]+[:_][A-Z0-9-]+$", exclude_headers, invert=TRUE)

assumed_typedefs <- grep("^[A-Za-z]+[:_][A-Z0-9-]+$", key_ids, invert=TRUE)
assumed_typedefs <- assumed_typedefs[which(assumed_typedefs != headerIDs)]

# Everything else other than these should be good
# key_ids[c(headerIDs, assumed_typedefs)]


# So now lets get everything that should be useful.
term_ids <- unique(key_ids[-c(headerIDs, assumed_typedefs)])

for (i in head(term_ids)) {
    print(head(kv[grep(i, kv$stanza_id),]))
}

# kv[grep("CHEBI:23367", kv$stanza_id),][kv[grep("CHEBI:23367", kv$stanza_id),]$key == "name",]$value
# kv[grep("CHEBI:23367", kv$stanza_id),][kv[grep("CHEBI:23367", kv$stanza_id),]$key == "is_a",]$value

getty <- function(id, k) {
    chunk <- kv[grep(id, kv$stanza_id),]
    val <- chunk[chunk$key == k,]$value
    # print(val)
    return(val)
}

bigger_list <- vector("list", 6)

i <- 1
for (id in head(term_ids)) {
    little_list <- list(ID=id, name=getty(id, "name"), is_a=getty(id, "is_a"))
    
    bigger_list[[i]] <-  little_list
    i <- i+1 
}

# OBOCollection comes with the slots .stanza, .subset, and .kv
# and methods `as` to convert b/w graphNEL and OBOCollection
# see: http://svitsrv25.epfl.ch/R-doc/library/GSEABase/html/OBOCollection-class.html
gNEL <- as(fantom, "graphNEL")

# lets take the graphNEl and bring it into igraph
G <- igraph.from.graphNEL(gNEL, name=TRUE, weight=TRUE, unlist.attrs=TRUE)

# === Static Plotting ===

# SVG
# svg("plot.svg", width=20, height=20)

# Quartz
plot(G, vertex.size=0.01, vertex.label=NA, edge.arrow.width=0)

# Close to SVG file
# dev.off

# Layouts
# as_star
# as_tree
# as_circle
# nicely

# === Interactive plotly ===
# see: https://plot.ly/r/network-graphs/

# L <- layout.circle(G)
L <- layout_as_tree(G)

# vertices and edges
vs <- V(G)
es <- as.data.frame(get.edgelist(G))

Nv <- length(vs)
Ne <- length(es[1]$V1)

Xn <- L[,1]
Yn <- L[,2]

network <- plot_ly(type="scatter", x=Xn, y=Yn, mode="markers", text=vs$label, hoverinfo="text")

edge_shapes <- list()
for(i in 1:Ne) {
  v0 <- es[i,]$V1
  v1 <- es[i,]$V2

  edge_shape = list(
    type = "line",
    line = list(color = "#030303", width = 0.3),
    x0 = Xn[v0],
    y0 = Yn[v0],
    x1 = Xn[v1],
    y1 = Yn[v1]
  )

  edge_shapes[[i]] <- edge_shape
}

network <- layout(
  network,
  title = 'FANTOM Network',
  shapes = edge_shapes,
  xaxis = list(title = "", showgrid = FALSE, showticklabels = FALSE, zeroline = FALSE),
  yaxis = list(title = "", showgrid = FALSE, showticklabels = FALSE, zeroline = FALSE)
)

network

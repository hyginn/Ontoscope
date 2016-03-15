# phylify 0.0.1 pre-release
# see: https://github.com/thejmazz/ontoscope-phylify
# very beta,
# but takes ndjson produced by bionode-obo and creates an igraph
# plot is very basic atm, need to look into customizations,etc

# === Packages ===
if (!require(jsonlite, quietly=TRUE)) install.packages("jsonlite")

if (!require(igraph, quietly=TRUE)) install.packages("igraph")

if (!require(GSEABase, quietly=TRUE)) {
    # try http:// if https:// URLs are not supported
    source("https://bioconductor.org/biocLite.R")
    biocLite("GSEABase")
}

# web-based graphs via plotly's JavaScript graphing library
if (!require(plotly, quietly=TRUE)) install.packages("plotly")


# === Construct igraph object from .obo ===
# Assumes ff-phase2-140729.obo is in same directory as this script
# see: http://svitsrv25.epfl.ch/R-doc/library/GSEABase/html/getOBOCollection.html
fantom <- getOBOCollection("ff-phase2-140729.obo")

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

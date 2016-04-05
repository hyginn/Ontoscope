#ex_3_4 code
source(file="TRRUST_network.R")
set.seed(2353)
trrust <- loadTRRUST()
trrust <- fixColumns(trrust)
setMode(2)
genes <- randomGenes(trrust,35)
trrust <- filterGenes(trrust,genes)
nodes <- getNodes(trrust)
edges <- getEdges (trrust)
nodes <- getWeights(nodes,edges)
nodes <- getClusters(nodes,edges)
edges <- getPMIDs(edges,trrust)
edges <- getAction(edges,trrust)

#Normal Network
visGraph(nodes,edges)
exportVis("ex_3")

#Frozen Network
#visGraph_f(nodes,edges)
#exportVis_f("ex_4")

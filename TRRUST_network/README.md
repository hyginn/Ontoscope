## TRRUST  Network

Version: **1.0.0**

**Features**: Basic Filtering and Visualization

**New**: 
 - Add PMIDs to Edges
 - Label each Edge with its respective Action (Activation, Repression, Unknown)
 - Generate a "frozen" graph with visGraph_f() and exportVis_f()
 - Workflow Updated
 
The TRRUST_network module supports two modes:
 
Mode 1
-------------
This mode is for when you have a **known list of TFs** and want to find out what genes they affect
 
Let's say you have two transcription factor coding genes:
 
```
> str(genes)
 chr [1:2] "MECP2" "RFXAP"
```



and you want to known with what genes they interact. After going through the [WORKFLOW](https://github.com/biodim/TRRUST_network/blob/master/workflow/TRRUST_workflow.R), you will get this graph:

https://rawgit.com/biodim/TRRUST_network/master/html/workflow_new.html

If you zoom in, you will see that each edge is labeled: [A] for activation, [R] for repression and [N/A] for unknown

If you **hover at each edge**, you will get the **relevant PMID link** for the interaction

if you want to remove all unknown (ie [N/A]) interactions, from the workflow file:

```
#Remove all Unknown interactions
trrust<-typeSelect(trrust,"Unknown",TRUE)

#Regenerate the Graph
nodes <- getNodes(trrust)
edges <- getEdges (trrust)
nodes <- getWeights(nodes,edges)
nodes <- getClusters(nodes,edges)
edges <- getPMIDs(edges,trrust)
edges <- getAction(edges,trrust)
visGraph(nodes,edges)
```

and you get this: 

https://rawgit.com/biodim/TRRUST_network/master/html/ex_1.html

(RFXAP had only unknown interactions and so it is removed.)

Mode 2
-------------
This mode is when you have a **known list of genes** and want to see what TFs interact with them

Let's say you have a list of 4 genes:

```
> str(genes)
 chr [1:4] "VWF" "ADORA1" "MAT2B" "HBE1"
```

and you want to see which TFs interact with them

Selecting Mode 2 in the module, you would get the following graph:

https://rawgit.com/biodim/TRRUST_network/master/html/ex_2.html

[(here is the code to generate it yourself) ](https://github.com/biodim/TRRUST_network/blob/master/workflow/ex_2.R)


We can see that there are quite a number of TFs that affect those genes. 

Let's try a much larger network

```
> genes
 [1] "CALB1"  "HSPA5"  "CD44"   "GFAP"   "BCL2"   "SNRPN"  "TP73"   "NTS"    "VWF"    "PLK1"   "FUT4"  
[12] "RPA2"   "MVP"    "SUMO1"  "NR5A1"  "HES1"   "IRF5"   "DEFB4A" "BCL2"   "KLK3"   "EGFR"   "MTTP"  
[23] "BLM"    "OPRM1"  "MYCL"   "TOP2A"  "STAT5A" "HMGA1"  "AMH"    "KRT12"  "PBXIP1" "KLK1"   "BIRC5" 
[34] "TP53"   "HTR1A" 
```

Here is the network. Take note how long it loads:
https://rawgit.com/biodim/TRRUST_network/master/html/ex_3.html

A much better solution would be to use the visGraph_f and exportVis_f functions. The "f" standard for "frozen", the networks lose their "springiness", but load much faster. Take a look:

https://rawgit.com/biodim/TRRUST_network/master/html/ex_4.html

**Protip**: for large networks don't visualize them in RStudio, it is much better to export them and visualize in chrome or firefox

[(the code for example 3 and example 4 is available here) ](https://github.com/biodim/TRRUST_network/blob/master/workflow/ex_3_and_4.R)

Here is the "old", 0.7.0 graph:

https://rawgit.com/biodim/TRRUST_network/master/html/workflow.html





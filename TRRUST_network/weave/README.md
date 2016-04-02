## Notes for WEAVE/RANK

IMPORTANT!
-------------

**NOTE 1:**

I **do not** recommend using centrality scores of the GLOBAL Network. Instead the RANK/WEAVE module should use centrality score for a **LOCAL** network. This means:

1) Have a set of "important" genes (eg transcription factor coding genes)

2) See the genes that they directly affect in the TRRUST network (remember to filter out the "UNKNOWN" interactions)

3) Generate the centrality score for this **LOCAL** network


If you go through the workflow you should be able to do this (and automate it), but contact me and I will write up a workflow/function to help you out

**NOTE 2:**
If we decide to use centrality scores as weights, then think of the TRRUST network as a **BOOST** network. Most TFs will have a centrality/betweeness score of zero. Using the network as a BOOST, means that a zero betweeness score WILL NOT affect the "total" score (that is score that is calculated from other networks [ie string]/sources). A zero centrality score will be neutral. However a positive centrality score will be a boost to the "total" score. Its up to you to quantify how big this boost will be (1%? 5%? 10%?)


Here are some .RData files. Each one contains the nodes, edges and the original dataframe. The nodes have betweeness centrality applied to them

trrust_1.RData
-------------
All the "Unknown" interactions have been removed. I think this would make the graph a bit more accurate

trrust_2.RData
-------------
The TRRUST network untouched (unknown interactions are kept)

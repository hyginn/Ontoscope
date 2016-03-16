## TRRUST  Network

Version: **0.5.0**

Features: basic filtering and visualizations

To Do: implement a weighing mechanism, clustering and write up a workflow

Check this out:

https://rawgit.com/biodim/TRRUST_network/master/html/ex_1.html

(Take a bit of time to load. You can zoom using the scroll wheel on your mouse or a trackpad)

With an input of 3 genes: "BAK1", "MYC" and "MMP1", the module retrieves other genes that code transcription factors that directly influence the inputed genes

Here is a more complex network:

https://rawgit.com/biodim/TRRUST_network/master/html/ex_2.html

It focuses on 11 input genes:  

```
[1] "GPR39"  "HNF1A"  "KCNJ11" "LDLR"   "LIPC"   "MMP7"   "MYC"    "NPC1L1"
[9] "NR1I2"  "PCSK9"  "PPARA" 
```
and shows the TFs that **activate** them

You can do these kinds of visualizations right now. Any number of genes (graph looks nicer with less genes present). You can also filter by interaction: activation, repression or both

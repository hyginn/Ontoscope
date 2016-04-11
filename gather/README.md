## GATHER Module

Introduction:
-------------
Gather module is responsible for preparing input for CONTRAST module. For a list of target cells, 
it returns a list of dataframes of counts for each target cell along with the number of the first columns in the dataframe dedicated for the target replicants.

Instructions:
-------------

To use any of the functions, as usual you would need to source code as follows in your working directory.

source('./gather/gather.R')


There are two main functions in the GATHER module that you can use. 

If you are interested in counts only for one target cell you can call 

> counts <- gatherCountsOne(COdat, "FF:0000592", 2, 4)

or

> counts <- gatherCounts(COdat, c("FF:0000592"), 2, 4)


In case you want to get counts for several tagrets in the same time, call gatherCounts() as follows:

> gatherCounts(COdat, c("FF:0000592", "FF:0000210"), 2, 4) # don't actually run this (will take forever!!!!!)


Details:
--------

GATHER depends on PHYLIFY and FATNTOM modules, and the speed of GATHER depends mainly on how large is the background, since FANTOM takes a while two retrieve counts for one id. 



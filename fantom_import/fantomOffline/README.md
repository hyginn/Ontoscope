## fantomOffline

Version: **1.0**

Input:

a character/list of fantom Ontology IDs (FF:A-B)

Output:

a fantomResults data.frame

To Do:

 - integrate fantomSummarize() to produce a CBX file
 - write a renaming bash script

Important:
the downloaded fantom files must be located in the 'fantom_files' folder and be properly named to work. Refer to the sample files in that folder


Introduction:
-------------
For Large Queries (>20), using an internet based retrieval is slow (1-2 minutes per file). It is recommended to pre-download the files and use the fantomOffline function (6-10 **seconds** per file). Compare given the sample files:

```
#Slow

fantom_IDs <- c("FF:13663-147C9", "FF:11408-118E4")

fantomOntology(fantom_IDs)

#3-4 minutes

#Fast
fantom_IDs <- c("FF:13663-147C9", "FF:11408-118E4")

fantomOffline(fantom_IDs)

#3 seconds?
```


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

```r
Preliminary

fantom_IDs <- c("FF:13663-147C9", "FF:11408-118E4")
source("prof_utils.R")

#Slow
>time(fantomOntology, fantom_IDs)
[1] "78.86 seconds"

#Fast
time(fantomOffline, fantom_IDs)
[1] "1.97 seconds"

```

Workflow to generate a CBX file
-------------

1. Transfer all the pre-downloaded fantom files to "Ontoscope/fantom_import/fantomOffline/fantom_files"
2. Run the script to fix their names
3. Generate a character/list of your IDs of interest
4. Run:

```r
fantomOffline(fantom_IDs)

fantomSummarize(2)
exportCounts()
```

This will generate (and export) a fantomCounts file which is the CBX that is needed

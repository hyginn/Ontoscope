## fantomOffline

**Important**:
 - the downloaded fantom files must be located in **this** fantomOffline folder ("Ontoscope/fantom_import/fantomOffline")
 - you must set your work directory to the "Ontoscope" folder
 - the naming scheme of the downloaded files should follow the naming scheme of the two sample files given
 - The examples given in this README work with the two sample files provided

Introduction:
-------------
For Large Queries (>20), using an internet based retrieval is slow (1-2 minutes per file). It is recommended to pre-download the files and use the offline capabilities of the three fantom retrieval functions(fantomKeyword, fantomDirect, fantomOntology)

Normally this command:

```r
fantom_IDs <- c("FF:13663-147C9", "FF:11408-118E4")
fantomOntology(fantom_IDs)
```

Will connect to the Fantom Servers and retrieve the relevant counts. However, if you predownload the files and put them in this "fantomOntology" folder, you can run the same command, but set online retrieval to 'FALSE':


```r
fantom_IDs <- c("FF:13663-147C9", "FF:11408-118E4")
fantomOntology(fantom_IDs, online=FALSE)
```

This also works for fantomDirect and fantomKeyword:

```r
fantomDirect("57, 89", online=FALSE)
```
Downloading
---------
Use [thejmazz's](https://github.com/thejmazz/) bash script to download all files: [LINK](https://gist.github.com/thejmazz/3b4ab9e6241d9aed3817)


Profiling
---------

```r

fantom_IDs <- c("FF:13663-147C9", "FF:11408-118E4")
source("prof_utils.R")

#Slow
>time(fantomOntology, fantom_IDs)
[1] "80.04 seconds"

#Fast
time(fantomOntology, fantom_IDs, online = FALSE)
[1] "1.82 seconds"

```

Workflow to generate a CBX file
-------------

1. Transfer all the pre-downloaded fantom files to "Ontoscope/fantom_import/fantomOffline/"
2. Generate a character/list of your IDs of interest
3. Run:

```r
fantomOntology(fantom_IDs, online=FALSE)
#Or fantomKeyword Or fantomDirect


fantomSummarize(2)
exportCounts()
```

This will generate (and export) a fantomCounts file which is the CBX that is needed

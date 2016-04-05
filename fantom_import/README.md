## Fantom Import Module

Version: **1.0.1** 



**Refer to Sample Workflow for an example of module use**


**Recent Changes:**

 - Offline Retrieval is now supported (ctrl+f "Offline Retrieval")
 - Fantom Processing Functions Expanded
 - fantomSearch() can now return "keywords" given FantomID(s) input

**Features:**

 - Import from fantomKeyword(), fantomOntology(), fantomDirect()
 - Retrieve data Offline or Online
 - Seach using fantomSearch() and fantomList()
 - Return RAW or Normalized Counts
 - Summarize results with fantomSummarize()
 - Return transcription factor coding genes with filterTFs()
 - Export your data as .RData or a .csv

**To Do:**

 - N/A


**Bugs**

 - Submit Bugs via the Issues Tab

Introduction:
-------------
The Fantom Import Module allows you to import data from Fantom5 based on Keywords, Fantom Ontology, or using your your own method via fantomDirect(). Currently it supports phase1 and phase2 results. You can also return both RAW or RLE NORMALIZED Counts

Using fantomKeyword(), fantomOntology() or fantomDirect() generates a list of dataframes: fantomResults. This is subsettable. 

Instructions:
-------------

Make sure you have transfered the "Sample_DB.txt" to your working directory. You also need to have a working Internet connection

Workflow
-------------
1. Decide whether you want to return RAW or RLE NORMALIZED Counts
2. Import your data with either fantomKeyword("keyword1, keyword2") or with fantomOntology("FF:X, FF:Y, FF:Z")
3. Importing your data automatically generates a list of dataframes: fantomResults. It contains: Genetic annotation, Peak Number, Gene Name, entrezgene ID, HGNC ID, Uniprot ID and the counts for EVERY sample. So if you requested 5 samples, you will get a SINGLE list of 5 dataframes

(**Optionally**) Summarize your results with fantomSummarize(). This will return a SINGLE dataframe (fantomCounts) of normalized gene names and the counts for all your samples. **If you use a positive integer as an argument, all genes whose count is below that integer value are filtered out.** You can view this dataframe with:
```
view(fantomCounts)
```
(**Optionally**) Export your fantomCounts with exportCounts(). This will export fantomCounts by creating a "fantomCounts.RData" file, which you can load into other modules (deseq2). You can also return a "fantomCounts.csv"

(**Optionally**) Filter your gene list (with the relevant sample counts) for only transcription factor coding genes with filterTFs()

Sample Workflow
-------------
Let's say you want the relevant counts for FF:10444-106F3, FF:10465-106H6, FF:10201-103F3. Here is a sample workflow:

```
fantomOntology("FF:10444-106F3, FF:10465-106H6, FF:10201-103F3")
fantomSummarize(2)
exportCounts()
```
This will generate a fantomCounts.RData file.  You can then

```
load("fantomCounts.RData")
```
in your module and perform the necessary modifications. The fantomCounts.RData file contains normalized gene names and the relevant counts for all the keywords that you have selected. Genes with RAW counts less than 2 are filtered out


Selecting Your Mode:
-------------
You can return results either as RAW COUNTS or RLE NORMALIZED. By default the function returns RAW COUNTS. If you want to return RLE NORMALIZED. Type this into your console before executing any function (but make sure your source fantom_main.R first):

```
return_counts <- FALSE
```

The function will now return RLE NORMALIZED counts. If you want to switch it back to RAW COUNTS:

```
return_counts <- TRUE
```

fantomKeyword
------------

```
>fantomKeyword("brain")
[1] "Sample_DB Loaded!"
Returning RAW COUNTS
3 Search Result(s) Were Found. Loading...
Loading Results from Fantom Access Number 528 ( 1 / 3 ) ...
Results from Fantom Access Number 528 Loaded!
Loading Results from Fantom Access Number 529 ( 2 / 3 ) ...
Results from Fantom Access Number 529 Loaded!
Loading Results from Fantom Access Number 530 ( 3 / 3 ) ...
Results from Fantom Access Number 530 Loaded!
All results have been loaded into fantomResults

```

fantomResults is a dataframe. You can subset it (eg fantomResults[1]) or view directly (note the capital V)

```
View(fantomResults[1])
```

Each dataframe contains the genomic annotation (chromosome position), a short description (prominant transcription factors that were detected), entrezgene ID, uniprot ID, hgnc ID and the relevent counts. Capitals matter (for now): "Lung" and "lung" will return different results.

You can also use multiple keywords:

```
>fantomKeyword("brain, liver, heart")
[1] "Sample_DB Loaded!"
```
fantomOntology
------------

If you know the relevant Fantom Ontology IDs (ie "FF:10198-103E9"), you can import your data using it. Note the argument notation.

```
> fantomOntology("FF:10198-103E9, FF:10549-107H9, FF:946436346, FF:28")
[1] "Sample_DB Loaded!"
Returning RAW COUNTS
MATCHED: 2 of 4
2 Search Result(s) Were Found. Loading...
Loading Results from Fantom Access Number 608 ( 1 / 2 ) ...
Results from Fantom Access Number 608 Loaded!
Loading Results from Fantom Access Number 611 ( 2 / 2 ) ...
Results from Fantom Access Number 611 Loaded!
All results have been loaded into fantomResults
```

fantomDirect
------------

```
>fantomDirect("23,45,677,34,56,67")
[1] "Sample_DB Loaded!"
Returning RAW COUNTS
6 Search Result(s) Were Found. Loading...
Loading Results from Fantom Access Number 23 ( 1 / 6 ) ...
Results from Fantom Access Number 23 Loaded!
Loading Results from Fantom Access Number 45 ( 2 / 6 ) ...
Results from Fantom Access Number 45 Loaded!
Loading Results from Fantom Access Number 677 ( 3 / 6 ) ...
Results from Fantom Access Number 677 Loaded
Loading Results from Fantom Access Number 34 ( 4 / 6 ) ...
Results from Fantom Access Number 34 Loaded!
Loading Results from Fantom Access Number 56 ( 5 / 6 ) ...
Results from Fantom Access Number 56 Loaded
Loading Results from Fantom Access Number 67 ( 6 / 6 ) ...
Results from Fantom Access Number 67 Loaded!
All results have been loaded into fantomResults

```

Use this if you want to avoid using the default keyword-based search method (fantomKeyword). You can generate a list of all samples and their corresponding Fantom Access Numbers using fantomList().

With fantomDirect, you can avoid keyword-based limitations. For example you can load different types of samples (eg both CD8 cells and heart cells). Also instead of loading all samples (as fantomKeyword does) for a specific query you can load the samples you want (you just have to find their Fantom Access Numbers First). For example:

```
>fantomKeyword("brain")
[1] "Sample_DB Loaded!"
3 Search Result(s) Were Found. Loading...
```

This results is 3 Samples: #528, #529 and #530. If you want to load only #528 and #530:

```
>fantomDirect("528, 530")
[1] "Sample_DB Loaded!"
Returning RAW COUNTS
2 Search Result(s) Were Found. Loading...
```

Take Note: The Argument is fantomDirect("x,y,z"), not fantomDirect("x","y","z")

fantomSummarize
------------

```
>fantomSummarize(threshold)
```

Takes your fantomResults and generates a single dataframe (fantomCounts). This dataframe will have normalized gene names and the counts for all your samples.  Note: You must import fantom Data (and have a fantomResults file), before you can create a summary. View the dataframe with:

```
view(fantomCounts)
```

Pass a positive integer as a threshold value to filter out all genes whose counts are below the integer value. Default (ie fantomSummarize()) is no threshold


filterTFs
------------

```
>filterTFs()
```
Use this to return **only transcription factor coding genes** from your fantomCounts file (~20,000 total genes -> ~600 transcription factor coding genes). This command will automatically create a fantomTFs dataframe **AND** save a fantomTFs.RData in your working directory. This function was created using Shivani Kamdar's Transcription Factor algorithm


exportCounts
------------

```
>exportCounts()
```
Generates a fantomCounts.RData file

```
>exportCounts(".csv")
```
Generates a fantomCounts.csv file


fantomSearch
------------

If you want to explore the FANTOM 5 database, but not load any samples, this is the tool for you

```
>fantomSearch("CD8")
```
The output will give you the entries in the Fantom Database, along with the FANTOM access number and FANTOM Ontology. You can use this function to find relevant Fantom Access Numbers.

If you have a Fantom ID (eg FF:11402-118D7) and you want to return the real "name" then just pass the FALSE argument:

```
> fantomSearch("FF:11402-118D7",FALSE)
[1] "Mesothelial Cells, donor3"
```

It also works if you have a character/list of IDs:

```
list_of_ids <- c("FF:10696-109G3", "FF:10028-101E1", "FF:10191-103E2", "FF:10057-101H3")
>fantomSearch(list_of_ids,FALSE)
[1] "mesodermal tumor cell line:HIRS-BM"
[2] "thyroid, adult, pool1"
[3] "vein, adult"
[4] "umbilical cord, fetal, donor1"
```



fantomList
----------

```
>fantomList()
```
Returns all Sample, Fantom Ontology and Fantom Access Numbers available in the Fantom Database

Offline Retrieval
----------

All 3 retrieval functions now support offline retrieval if you pre-download the files and put them in the fantomOffline folder. To access offline functionality you have to set online to FALSE


```
#Normal 'ONLINE' retrieval

fantomKeyword(keywords)
fantomOntology(fantom_ids)
fantomDirect(ids)

#OFFLINE retrieval
fantomKeyword(keywords, online=FALSE)
fantomOntology(fantom_ids, online=FALSE)
fantomDirect(ids, online=FALSE)

``

refer to the fantomOffline folder for more details



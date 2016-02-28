## Fantom Import Module

Version: **0.7.5**

**Recent Changes:**

 - Added Phase 2 Support
 - Added Option to return both RAW and RLE NORMALIZED Counts

**Features:**

 - Import from fantomKeyword(), fantomOntology(), fantomDirect()
 - Seach using fantomSearch() and fantomList()
 - Return RAW or Normalized Counts

**To Do:**

 - Dataframe Processing
 - add Phase 2 peaks to fantomDatabase
 - Implement a function that will allow you to retrieve either the raw counts or the (FANTOM) normalized data

Introduction:
-------------
The Fantom Import Module allows you to import data from Fantom5 based on Keywords, Fantom Ontology, or using your your own method via fantomDirect(). Currently it supports phase1 and phase2 results. You can also return both RAW or RLE NORMALIZED Counts

Using fantomKeyword(), fantomOntology() or fantomDirect() generates a list of dataframes: fantomResults. This is subsettable. You can view each individual result:

```
View(fantomResults[1])
```

You can use:
```
length(fantomResults)
```

to check the size of your Results (and how many times you can subset it)


Instructions:
-------------

Make sure you have transfered the "Sample_DB.txt" to your working directory, not the default fantom_import directory

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


fantomDirect
------------

```
>fantomDirect("23,45,677,34,56,67")
[1] "Sample_DB Loaded!"
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




fantomSearch
------------

If you want to explore the FANTOM 5 database, but not load any samples, this is the tool for you

```
>fantomSearch("CD8")
```
The output will give you the entries in the Fantom Database, along with the access number and tissue type. You can use this function to find relevant Fantom Access Numbers.

fantomList
----------

```
>fantomList()
```
Returns all Sample, Cell Type and Fantom Access Numbers available in the Fantom Database



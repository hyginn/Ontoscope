## Fantom Import Module

Version: **0.5.2**

**Recent Changes:**

 - Improved code readability

**Features:**

 - fantomImport()

 - fantomDirect()

 - fantomSearch()

 - fantomList()

**To Do:**
 - fantomOntology()
 - Dataframe Processing

Instructions:
-------------

Make sure you have transfered the "Sample_DB.txt" to your working directory, not the default fantom_import directory

fantomImport
------------

```
>fantomImport("brain")
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

Use this if you want to avoid using the default keyword-based search method (fantomImport). You can generate a list of all samples and their corresponding Fantom Access Numbers using fantomList().

With fantomDirect, you can avoid keyword-based limitations. For example you can load different types of samples (eg both CD8 cells and heart cells). Also instead of loading all samples (as fantomImport does) for a specific query you can load the samples you want (you just have to find their Fantom Access Numbers First). For example:

```
>fantomImport("brain")
[1] "Sample_DB Loaded!"
3 Search Result(s) Were Found. Loading...
```

This results is 3 Samples: #528, #529 and #530. If you want to load only #528 and #530:

```
>fantomDirect("528, 530")
[1] "Sample_DB Loaded!"
2 Search Result(s) Were Found. Loading...
```

Take Note: The Argument is fantomDirect("x,y,z"), not fantomDirect("x","y","z")

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



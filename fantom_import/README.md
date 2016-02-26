## Fantom Import Module

Version: **0.5**

**Recent Changes:**

Added:

 - fantomImport,

 - fantomSearch, 

 - fantomList

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

fantomSearch
------------

If you want to explore the FANTOM 5 database, but not load any samples, this is the tool for you

```
>fantomSearch("CD8")
```
The output will give you the entries in the Fantom Database, along with the access number and tissue type. Future releases of the Fantom Import module will have a filter by tissue feature as well as direct selection. With direct selection, you will be able to extract any cell, as long as you know it's Fantom Access Number. This will allow you to directly extract cells that are not related to each other (eg heart and CD8)

fantomList
----------

```
>fantomList()
```
returns all Sample, Cell Type and Fantom Access Numbers




## fantom_ont_conv.R

Version: **1.0.0**

Features: A Simple CNhsXXXXXX to FF:A-B converter

Instructions: Transfer the **ID_database.RData** to your working directory


Sample Workflow
-------------

I have created a character vector for some "CNhsIDs"

```
> str(IDs)
 chr [1:5] "CNhs14406" "CNhs14407" "CNhs14408" "CNhs14410" ...
```

I now use the convertIDs function to convert to Fantom Ontology IDs

```
>fantom_ids <- convertIDs(IDs)
>str(fantom_ids)
chr [1:5] "FF:13545-145H8" "FF:13541-145H4" "FF:13542-145H5" ...
```


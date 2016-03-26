## getBED.R

Version: **1.2.0**
**Fixed the one ID, multiple matches bug**

Features: Given a list/character vector of Fantom Ontologies, download the  relevant .bed files

To Do: Optimizations

Instructions: Transfer the **BED_DB.RData** to your working directory


Sample Workflow
-------------

I have created a character vector for some fantom Ontologies (fantom_IDs)

```
> str(fantom_IDs)
 chr [1:2] "FF:11268-116G8" "FF:11653-122E6"
```

I now use the getBD function to download the .bed files

```
>getBED(fantom_IDs)
Downloading... FF:11268-116G822E6"
(...)
FF:11268-116G8 Saved!
Downloading... FF:11653-122E6
(...)
FF:11653-122E6 Saved!
```


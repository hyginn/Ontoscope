## Sample fantomCounts.RData

Purpose:
-------------
It is computationally taxing generating the fantomCounts.RData files. I will pre-generate a few files as well as post the code to generate them yourself if you desire. I will post files of several lengths, so you will know how well your algorithm scales.

You can load a fantomCounts.Rdata with

```
load("fantomCounts.RData")
```

If you did a particularly taxing computation, consider uploading your fantomCounts.RData here


fantomCounts_11.RData
-------------
```
fantomKeyword("CD8")
fantomSummarize()
exportCounts()

```
fantomCounts_73.RData
-------------
```
fantomKeyword("Fibroblast")
fantomSummarize()
exportCounts()

fantomCounts_114.RData
-------------
```
fantomKeyword("cancer")
fantomSummarize()
exportCounts()

```

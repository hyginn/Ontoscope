if(!require(piano))
{
  source("https://bioconductor.org/biocLite.R")
  biocLite("piano")
}

library(piano)
library(reshape2)
pathway <- read.table("./annotate/Pathway.GSEA.hgnc.gmt", sep = "\t", fill = TRUE, col.names = 1:603)

pathway <- pathway[, -2] #remove unnessesary ID data
pathway <- melt(pathway, id.vars = 1)
pathway <- pathway[pathway$value != "", ]
pathway <- pathway[, -2]
pathway <- pathway[, c(2,1)]

source("./enrichr/enrichr.R")
load("./contrast/sample1_contrast.RData")

allpathways <- loadGSC(pathway)

gsxtemp <- gsx_fantomCounts_10Kg_6s
gsxtemp <- na.omit(gsxtemp)

gsx <- gsxtemp$gsx
names(gsx) <- gsxtemp$gene

gsaoutput <- runGSA(gsx, gsc = allpathways)

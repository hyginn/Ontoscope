# normalizeRegNetwork
#
# Purpose:   Covert Wikigene ids to HGNC symbols for RegNetwork
# Version:   1.0
# Date:      2016-03-01
# Author:    Boris Steipe, Fupan Yao
#
# Input:     Regnetwork file, with two columns, one for source, and one for target
# Output:    output file with 4 columns, two from initial, and two curated
#
# Depends:   Bioconductor: biomaRt
#
# ToDo:      Some problems with directory and relative paths   
#            In addition, duplicates showing up even though unique keyword was used
# Notes:     Regnetwork downloaded from http://www.regnetworkweb.org/download.jsp
#
# V 1.0:     First code
# ====================================================================

setwd(DEVDIR)

# ====  PARAMETERS  ==================================================
#

output <- "hgnc_symbol"

regnet <- file.path("./regnetwork", "human.source")
regout <- file.path("./regnetwork", "regnetworkigraph.RData")

 

# ====  PACKAGES  ====================================================

# biomaRt provides the ID translation
if (!require(biomaRt)) {
  source("http://bioconductor.org/biocLite.R")
  biocLite("biomaRt")
  library("biomaRt")
}

require(igraph)


# ====  MAIN  ========================================================

# ====  Read STRING file into dataframe (~ 1 min.)

# Execute the next three lines all together
src <- read.delim(regnet, sep="\t", header=FALSE, stringsAsFactors=FALSE)

head(src)
nrow(src)  # 372774

src <- src[, c("V1", "V3")]

src <- src[,]

# ====  Create ID map data frame from unique gene ids (fast)
# The key here is that we assign the wikigene names as rownames so we can then
# do fast lookup by subsetting.

IDmap <- unique(c(unique(src$V1), unique(src$V3)))
IDmap <- data.frame(wikigene = IDmap, HGNC = "", stringsAsFactors=FALSE)
rownames(IDmap) <- IDmap$wikigene
head(IDmap)
nrow(IDmap) # 23336


# ====  Create vector of HGNC symbols ====
ensembl <- useMart("ensembl")
ensembl <- useMart("ENSEMBL_MART_ENSEMBL",dataset="hsapiens_gene_ensembl", host = "www.ensembl.org")

BMmap <- getBM(filters = "wikigene_name", 
               attributes = c("wikigene_name", output),
               values = IDmap$wikigene,
               mart = ensembl)

colnames(BMmap) <- c("wikigene", output)
head(BMmap)
nrow(BMmap)  # 18901

#currently does not map properly due to errors

# ====  Replace the proteinID columns in the data frame
src[, "hgnc_1"] <- NA
src[, "hgnc_2"] <- NA

#src$hgnc_1 <- IDmap[src$V1, "hgnc_1"]
#src$hgnc_2 <- IDmap[src$V3, "hgnc_2"]



# ====  Write to output file (~10 sec.)

srcg <- graph.data.frame(src[, c(1,2)])

save(srcg, file = STRINGnew)


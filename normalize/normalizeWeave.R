# STRINGensp2symbol.R
#
# Purpose:   Covert ENSP IDs to HGNC symbols in a STRING file
# Version:   1.1
# Date:      2016-03-01
# Author:    Boris Steipe, Fupan Yao
#
# Input:     STRING file, first two columns are ENSP IDs
# Output:    STRING file, first two columns are HGNC IDs
#                IF BioMart returns a match, UNKXXX0000
#                codes otherwise
#
# Depends:   Bioconductor: biomaRt
#
# ToDo:      Some translations are missing and they have been
#            replaced with UNKSYM0000 or UNKENS0000 symbols. These 
#            need to be seperately retrieved from HGNC in case we
#            need them.
#            Some problems with directory and relative paths   
# Notes:     The STRING files can be downloaded from 
#                http://string.embl.de/newstring_cgi/show_download_page.pl
#            They are large! For sure choose an organism restriction.
#
# V 1.0:     First code
# V 1.1:     Shifted From Regular protein links file to detailed, kept initial values instead of replacement, throws NA instead of default code
# ====================================================================

setwd(DEVDIR)

# ====  PARAMETERS  ==================================================
#

output <- "hgnc_symbol"

STRINGsource <- file.path("./WEAVE", "9606.protein.links.detailed.v10.txt")
                # STRING graph edges. One header line. Values separated by
                # a single blank character. 8,548,003 lines.
                # 
                # protein1 protein2 combined_score
                # 9606.ENSP00000000233 9606.ENSP00000003084 150
                # 9606.ENSP00000000233 9606.ENSP00000003100 215
                # [...]

STRINGnew <- file.path("./WEAVE", "curatedOutput.RData")
                # output file name
                # STRING graph edges. One header line. Values separated by
                # a single blank character. 8,548,003 lines. HGNC
                # symbols
                # 
                # protein1 protein2 combined_score
                # 9606.ENSP00000000233 9606.ENSP00000003084 150
                # 9606.ENSP00000000233 9606.ENSP00000003100 215
                # [...]
 

# ====  PACKAGES  ====================================================

# biomaRt provides the ID translation
if (!require(biomaRt)) {
  source("http://bioconductor.org/biocLite.R")
  biocLite("biomaRt")
  library("biomaRt")
}


# ====  FUNCTIONS  ===================================================

currMem <- function() {
	# Utility function to print out current
	# memory usage, in case you are curious
	sort( sapply(ls(envir=globalenv()), function(x){object.size(get(x))}))
}


# ====  MAIN  ========================================================

# ====  Read STRING file into dataframe (~ 1 min.)

# Execute the next three lines all together
ptm <- proc.time() # Start the stopwatch...
src <- read.delim(STRINGsource, sep=" ", header=TRUE, stringsAsFactors=FALSE)
proc.time() - ptm  # How long did we take?  47.5 sec. on my machine ...

head(src)
nrow(src)  # 8,548,002
currMem()  # src has ~ 174 MB



# ====  Remove "9606." prefix (~ 8 sec. each)
src[, "cprotein1"] <- NA
src[, "cprotein2"] <- NA
src$cprotein1 <- gsub("^9606\\.", "", src$protein1)
src$cprotein2 <- gsub("^9606\\.", "", src$protein2)
head(src)


# ====  Create ID map data frame from unique ENSP IDs (fast)
# The key here is that we assign the ENSP IDs as rownames so we can then
# do fast lookup by subsetting.

IDmap <- unique(c(unique(src$cprotein1), unique(src$cprotein2)))
IDmap <- data.frame(ENSP = IDmap, HGNC = "", stringsAsFactors=FALSE)
rownames(IDmap) <- IDmap$ENSP
head(IDmap)
nrow(IDmap) # 19247


# ====  Create vector of HGNC symbols ====
ensembl <- useMart("ensembl")
ensembl <- useMart("ENSEMBL_MART_ENSEMBL",dataset="hsapiens_gene_ensembl", host = "www.ensembl.org")

ptm <- proc.time() # Start the stopwatch...
BMmap <- getBM(filters = "ensembl_peptide_id",   # (  (~ 30 sec.))
               attributes = c("ensembl_peptide_id", output),
               values = IDmap$ENSP,
               mart = ensembl)
proc.time() - ptm  # How long did we take?  35.5 sec. on my machine ...

colnames(BMmap) <- c("ENSP", "HGNC")
head(BMmap)
nrow(BMmap)  # 18168  


# ====  Map the HGNC symbols back to their ENSP IDs (~ 10s)
# We have ENSPs that return "" as the symbol. We map these to
# the string UNKSYM0000 where 0000 is replaced with a unique integer.
# We also have ENSPs that are not even in BioMart. These we map to
# the similarly composed string UNKENS0000. At a later time we
# might write code to resolve them (the ones I've checked appear
# resolvable).

# This could be much sped up with an apply() function, but 10s
# is still oK. You couldn't run a for-loop over the src dataframe
# though...

rownames(BMmap) <- BMmap$ENSP
iUnkSym <- 1
iUnkEns <- 1

ptm <- proc.time() # Start the stopwatch...
for (i in 1:nrow(IDmap)) {
	sym <- BMmap[IDmap$ENSP[i], "HGNC"]
	if (is.na(sym)) {
		sym <- sprintf("UNKSYM%04d", iUnkSym)
		iUnkSym <- iUnkSym + 1
	} else if (sym == "") {
		sym <- sprintf("UNKENS%04d", iUnkEns)
		iUnkEns <- iUnkEns + 1
	}
	IDmap$HGNC[i] <- sym
}
proc.time() - ptm  # How long did we take?  9.7 sec. on my machine ...

head(IDmap)
cat(sprintf("%d symbols not in BioMart for recognized ENSP IDs\n", iUnkSym - 1))
cat(sprintf("%d ENSP IDs not recognized in BioMart\n", iUnkEns - 1))


# ====  Replace the proteinID columns in the 8 million row data frame
src[, "hgnc_1"] <- NA
src[, "hgnc_2"] <- NA
src$hgnc_1 <- IDmap[src$cprotein1, "HGNC"]
src$hgnc_2 <- IDmap[src$cprotein2, "HGNC"]
# Fast, isn't it? Subsetting FTW

# ==== general cleanup 

src <- src[, c(13,14,1,2,3,4,5,6,7,8,9,10,11,12)]

# ====  Write to output file (~10 sec.)

# ptm <- proc.time() # Start the stopwatch...
# write.table(src,
#             file = STRINGnew,
#             quote = FALSE,
#             sep = " ",
#             row.names = FALSE,
#             col.names = TRUE)
# proc.time() - ptm  # How long did we take?  8.4 sec. on my machine ...

save(src, file = STRINGnew)

# DONE


# ====  TESTS  =======================================================
#

IDmap[c("ENSP00000000233", "ENSP00000007414"), "HGNC"]
# "ARF5"   "OSBPL7" ... confirmed in STRING database online
# http://string-db.org/version_10/newstring_cgi/show_network_section.pl?all_channels_on=1&identifier=9606.ENSP00000000233


# [END]

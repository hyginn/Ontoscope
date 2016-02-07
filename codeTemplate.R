# codeTemplate.R
#
# Purpose:   <explain purpose>
# Version:   <current version number>
# Date:      YYYY-MM-DD
# Author:    <author(s)>
#
# Input:     <if applicable: define format and semantics>
# Output:
# Depends:
#
# ToDo:      <list bugs, issues and enhancements>
# Notes:     <more notes>
#
# V 0.1:     First code <List key changes for versions>
# ====================================================================

setwd(DEVDIR)

# ====  PARAMETERS  ==================================================
# (these are examples ... delete.)
# Don't put "magic numbers" and files in your code. Place them here,
# assign them to a well-named variable and explain the meaning!
#
inFile <- "genes.csv"   # explain contents of this file
RT <- 8.314 * (273.16 + 25.0)  # explain meaning of constant


# ====  PACKAGES  ====================================================
# (these are examples ... delete.)
#

# package example ... code paradigm to quietly install missing
#                     packages and load them
if (!require(RUnit, quietly=TRUE)) {
  install.packages("RUnit")
  library(RUnit)
}


# function example ...
wrapString <- function(s, w = 60) {  # give parameters defaults
  # Wrap string s into lines of width w.  # comment purpose
  # All lines are terminated with a newline "\n"

  pattern <- paste(".{1,", w, "}", sep="")
  tmp <- paste(unlist(str_match_all(s, pattern)[[1]]),
               collapse = "\n")
  return(paste(tmp, "\n", sep=""))   # return explicitly
}


# ====  FUNCTIONS  ===================================================
# Define functions or source external files
# (these are examples ... delete.)
#

source("../Ontoscope/Utilities.R")





# ====  ANALYSIS  ====================================================
# This is the main working section of the script where you use the
# functions to process data.

# example ...
TFlist <- read.csv("..data/canonicalTFs.csv", stringsAsFactors=FALSE)


# ====  TESTS  =======================================================
# (these are examples ... delete.)
#

test_myTaxID <- function() {
  checkEquals(myTaxID(c("taxID: 9606", "KLF4")), "9606")
  checkException(myTaxID(c("ZFP36", "KLF4")), silent=TRUE)
}



# [END]

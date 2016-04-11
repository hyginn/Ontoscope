# Gene_cov.R
#
# Purpose:   To plot the cumulative coverage of regulation of for genes by the top ranked TFs.
# Version:   0.1
# Date:      2016-04-11
# Author:    Anam Qudrat
#
# Input:     List of top-ranked TFs.
#            List regulatory genes required for the conversion.
#
# Output:    Bar graph of percent coverage data.
# Depends:   NA
#
# ToDo:      Test with working dataset.
# Notes:
#
# V 0.1:     First code
# ====================================================================

# ====  PARAMETERS  ==================================================

# "cov.txt" # Output of Read_Gsx file with top genes.
# "top.txt" # Output of Read_cTF file with top ranked TFs.

# ====  PACKAGES  ====================================================

# ====  FUNCTIONS  ===================================================

# ====  ANALYSIS  ====================================================

# Input data from Analyze submodules.

setwd(paste(DEVDIR, "/Analyze", sep=""))

source("Read_Gsx.R")
source("Read_cTF.R")

# As an example, here I am using the following as sample output.
coverage <- c(53, 81, 45, 69, 45, 89, 45, 33)
barplot(coverage, main="Cumulative coverage of regulation", xlab="TFs", ylab="Percent coverage",
        names.arg=c("TF1", "TF2", "TF3", "TF4", "TF5", "TF6", "TF7", "TF8"),
        border="blue",density=c(20,20,20,20,20,20,20,20))

# Export bargraph to working directory.

# ====  TESTS  =======================================================

# [END]





## Contrast Module

Version: **0.1**


**Features:**

 - Create requirements for DESeq2 package 
 - Runs DESeq2 to calculate differential expressions
 - Return Gsx score (s = sample ; x = gene)
 
 Note : Current version contains function to perform analysis on one sample. 

**To Do:**

 - Prepare input FANTOM gene sample expression file in specific format (sample.csv) 
 - Use the sample1_contrast.RData to load the sample files 

Introduction:
-------------

This module is designed to calculate the Gsx score. This uses the DESeq R package by bioconductor. 
Please refer the wiki page to know more


Instructions:
-------------

-Make sure you have the sample file in the current working directory 
 Use the following command to load the sample file. 
 colData <- read.csv("coldata.csv", row.names=1, header=T)
-Load the file and run to creat the function- contrast_<latestversion>
-Run using contrast_<latestversion>(<filename>)

NOTEBOOK:
----------

24 MARCH 2016

 - small update to v1. v2 released.
 - sample .RData files now  available- "sample1_contrast.RData"
 -Copy of email : 
To work out yourself, you can load this file to your Rstudio.   Here are the data-frame info contained within:
{These dataframes are subset of Dmitry's file}
fantomCounts_10Kg_6s : Raw counts of 10,000 genes in 6 samples
fantomCounts_500g_5s : Raw counts of 500 genes in 5 samples

Running time is far much better! 

fantomCounts_10Kg_6s : 7.58sec
fantomCounts_500g_5s : 1.87sec

Other data-frames: 

gsx_fantomCounts_10Kg_6s : Gsx score corresponding to the file
gsx_fantomCounts_500g_5s : Gsx score corresponding to the file  
## Contrast Module

Version: **0.1**


**Features:**

 - Create requirements for DESeq2 package 
 - Runs DESeq2 to calculate differential expressions
 - Return Gsx score (s = sample ; x = gene)
 
 Note : Current version contains function to perform analysis on one sample. 

**To Do:**

 - Prepare input FANTOM gene sample expression file in specific format (sample.csv) 

Introduction:
-------------

This module is designed to calculate the Gsx score. This uses the DESeq R package by bioconductor. 
Please refer the wiki page to know more


Instructions:
-------------

-Make sure you have the sample file in the current working directory 
 Use the following command to load the sample file. 
 colData <- read.csv("coldata.csv", row.names=1, header=T)
-Load the file and run to creat the function- contrast_v1
-Run using contrast_v1(<filename>)

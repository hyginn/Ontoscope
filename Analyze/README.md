## Read Modules

Version: **1.0**

**Features**: These modules generate .txt files of organized data for further analysis and visualization. There are two Read               Modules, one for the differential gene expression (Gsx) scores and the other for the transcription factor (TF)               scores. 

Notes on Variables
-------------
This module assumes the following:

1. The Gsx scores have been calculated in the Contrast Module. 
2. The ranked TF list has been generated through the RANK/COMBINE/PRUNE Modules. 

Usage
-------------
Usage of this module, assuming variables been defined, requires sourcing the respective files.

Notes on Functionality
-------------
Both Modules convert imported data into a matrix format, rank/sort the data applying pre-determined or user-defined thresholds and export the data as text files.

## Transcription Factor Validation - Literature Search with Pubmed.MineR

Version: **1.1**

**Features**: All abstracts downloaded from Pubmed for our TF list.
	      Ability to text mine these abstracts for source/target cell hits.

**New**: 
 - Test available to make sure that the module runs as intended
 - Pubmed.MineR now accounts for TFs that do not have any Pubmed abstract text hits (of which there are surprisingly many).
 
Notes on Variables
-------------
This module assumes the following:

1. The user has already generated and output a list of candidate TFs titled "top.txt" using the Analyze_read submodules.
2. The user has defined some source (sourcecell) and some target (target) cell previously in the workflow.

Variable 2 *must* be accounted for in runOntoscope.R.

Usage
-------------
The module has two primary functions:

1) Ranking each TF on the list based on available evidence for that TF's being involved in target cell processes
   and not source cell processes, as well as the amount of literature evidence available for each TF.

2) Assigning a confidence score to each TF based on the strength of its association with the target cell type.

Usage of this module, assuming abstracts are already available, is straightforward and requires only the sourcing of the file.

Should abstracts *not* be available or undergo corruption for some reason, the **Background** section of the module should
be uncommented and rerun. Currently, this section runs through the *entire* list of TFs output from Normalize_TF, but can
easily be modified for a specific list of TFs.

Be warned if you need to redo this - this step takes a *long* time.

Workflow
-------------
 
Let us take the following list of TFs, source and target cells:
 
```
> TFList <- c("TP53", "TP63", "TP73", "MYC", "HIPPO")
  sourcecell <- "brain"
  target <- "fibroblast"
```
Note that HIPPO is not a real transcription factor!

First, the program will automatically access abstracts available for each TF from your Abstracts subfolder. If a TF does not
have any abstracts available, the program will assign that TF as having inapplicable confidence scores and will give it the
lowest rank.

Next, several variables will be assigned to each TF with abstracts available:

- BGVals: The number of hits for that TF and the cell of origin (in our case, brain).
- TargetVals: The number of hits for that TF and the target cell (in our case, fibroblast).
- RatioVals: The ratio of target cell hits to source cell hits. 
- LengthVals: The total number of abstracts available for each TF.
- PercentHits: The percentage of abstracts mentioning the target cell out of the total abstract number for that TF.

The higher the ratio of target cell hits to source cell hits, the greater the association is between that TF and the target
cell compared to the source. Thus, we first rank the TFs based on ratio (with the highest ratio TFs getting the highest rank).

If there is a tie, we also look at the total number of abstracts for each TF. Those with more abstracts available will then
be ranked higher than those with less abstracts available.

At this point, you may be questioning - what if a TF has a high ratio just because it doesn't have many abstracts?

This is where the confidence score comes in.

**Confidence Score Calculations**

Firstly, let us consider exceptional cases. Although some TFs have tens of thousands of abstract hits, the bottom 20% have
less than 44 abstracts. Thus, if a TF has <44 abstracts, the confidence score is automatically assigned an NA, since we
do not know if we have enough evidence of association to assign a confidence score.

Furthermore, it is evident that, if the ratio of target cell to source cell hits is less than 1, the evidence for association for that TF
is stronger in the source cell than in the target cell, and we will have no confidence in this TF being needed for conversion
based on literature search. Thus, all such TFs will receive a confidence score of 0.

To assign a confidence score for the rest of the TFs, we will define and use a "gold standard". AR (androgen receptor) is the
TF with the highest number of abstract hits at 36 191 total abstracts. Of course, the androgen receptor is best associated
with prostate cells. Thus, if we search for abstracts containing "AR" and "prostate", we find that 12.1% of all AR abstracts
(4390/36191) mention prostate, or the associated cell type.

We shall then use 12.1% as our gold standard cutoff. The confidence score is thus determined as the percentage of hits for
each TF divided by the percentage of hits for AR.

In the event that this is greater than 1, the confidence score will be set to 1.

For our TF list, this results in the following output table:

|  TFList      |  RatioVals  |Confidence Score|
|-------------:|------------:|---------------:|
|          TP63|          4.1|          0.25  |
|           MYC|          2.7|          0.63  |
|          TP53|          0.9|          0.00  |
|          TP73|          0.2|          0.00  |
|         HIPPO|          NaN|            NA  |


As you can see, HIPPO gives an NA confidence score, and is ranked last.

TP53 and TP73 show stronger associations in brain than in fibroblast, and thus we have no confidence in them.

Out of MYC and TP63, although TP63 has the higher ratio, the high percentage of abstract hits for MYC means that we actually
have higher confidence in our prediction of Myc than of TP63.

And that's it!

## Visualization

Version: **1.0**

**Features**: Heatmaps showing conversion TF expression in source, target, and background cells.
	      Dmitry's TRRUST network visualization of the genes regulated by the conversion TFs.
 
Notes on Variables
-------------
This module assumes the following:

1. The fantomCounts file with counts for source, target, and background cells has already been generated.
2. Source, target, and backgrounds have been identified previously in the workflow.

Usage
-------------
Usage of this module, assuming variables and conversion TFs have been defined, is straightforward and requires only the sourcing of the file.

Notes on Functionality
-------------

For more information about Dmitry's TRRUST network, click [(here) ](https://github.com/hyginn/Ontoscope/tree/master/TRRUST_network).

## Gene coverage

Version: **1.0**

**Features**: To plot the cumulative coverage of regulatory genes of top ranked TFs. 
 
Notes on Variables
-------------
This module assumes the following:

1. The list of top-ranked TFs has been generated (i.e., "top.txt).
2. The list of regulatory genes required for the coversion is available. 

Usage
-------------
Usage of this module, assuming variables and requires sourcing of the file. 

Workflow
-------------

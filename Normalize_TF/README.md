## Normalize_TF

Version: **1.1**

**Features**: Ability to generate a list of TFs based on the following five datasets:

- [TFCAT] (http://www.tfcat.ca/index.php)

- [The DBD database] (http://www.transcriptionfactor.org/index.cgi?Genome+gn:hs)

- [This manually assembled list of TFs with annotations] (http://www.nature.com/nrg/journal/v10/n4/extref/nrg2538-s3.txt)

- [The FANTOM transcription factor dataset] (http://fantom.gsc.riken.jp/5/sstar/Browse_Transcription_Factors_hg19)

- [ENCODE data, derived from their list of antibodies] (http://genome.ucsc.edu/ENCODE/antibodies.html)

**New**: 
 - Updated module to now draw TFs from a minimum of two (rather than three) database hits.
 
Usage
-------------
The module does not require any special user input and merely needs to be suourced in order to function.

Only the manual TF list allows automated downloading from the Internet. Should a user wish to update the TF lists or add new
TF lists, this can easily be done by replacing or adding additional .csv TF lists to the Normalize_TF directory and adding them
to the code. The code can also be easily modified to select TFs present in only one dataset, or in any combination of
datasets, using subsetting of MergedList.

The module generates three primary output files:

- **The actual output**: a .txt file with a list of TFs
- **An R object titled MergedList**: a data table with a list of all TFs present in at least one dataset, and showing which
  dataset each TF is present in
- **An R object titled RefList**: a data table with a list of all TFs present in at least one dataset, with supporting data
  (such as Ensembl ID, Interpro DNA binding family, etc.) shown.

For more information regarding the background of this module, see [here] (http://steipe.biochemistry.utoronto.ca/abc/students/index.php/User:Shivani_Kamdar/NormalizedTFs).

Output
-------------
This module currently outputs a list of 1564 transcription factors named by HGNC IDs for downstream processing.
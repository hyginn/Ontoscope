# OBO Parsing Heuristic

or, how to make sense of 12000 edges.

## Summary, Common Ideas

WIP...

## Submissions

### Eugenia

Since we want to work only with human cells we need to first select only CL and FF without dash objects from the OBO.
In addition, since we're interested only in the human cells we need to get rid of all FFs that have 'mouse' in their name. Unfortunately, there's no other way to do this since there's no distinction in ids for human or mouse cells, for example, FF:0000195 is a human astrocyte of the cerebellum sample while FF:0000196 is a mouse astrocyte of the cerebellum sample.
For the samples that are related to EFO or BFO, however, we might want to include only cancer cells themselves, but not the treatment i.e. only controls of the experiment. (Please confirm if it is reasonable) Algorithmically, for all FFs that is_a or intersection_of or reference EFO/BFO, include only FFs with word 'control' in their name.

### KartiKay

We are using the CO to create a graph using which we can select the background cell lines for a specific cell type to run the DEseq2 package to get the Gsx score. To run Deseq, we need raw expression data for the genes in that sample. I was wondering if all the data that we have in the OBO ("cells") has corresponding expression data? If not so how about back tracking by creating the graph only for the cell line (like 700 libraries in the paper) and use it to select background? I am well aware of possibilities to miss information here but certainly we can not have cell lines selected without expression data, as it will limit us at DEseq level. Hope this make sense. Any comments? 

### Jialun

1. Only keep terms with CL and FF in their ID. Remove all other IDs with diseases/molecules/... terms. Our root should be FF:0000210 (human sample), that will exclude all mouse samples.

2. Terms with FF:AA-BB seem not necessary and excluding them can save us a lot of work, as a lot of them are the same cell type from different donors, or same cell type under different treatments within different time frames.

### Phil

### Dmitry

The main idea is that instead of constructing a network of the entire OBO file, we filter the OBO file to only use the Ontology IDs that are directly useful for background selection - the CL: + FF:nodash. So we will create new OBO file: fantom_filtered.OBO. The IDs are already present in a relatively decent network (confirm it with OBOedit) so it should be pretty easy to construct a network out of them (and "subset" by nodes).. A downside to this approach is that we might miss some other functional relation, but if we do this semi-manually, I think this error will be minimized

[Lots more and pictures on student wiki](http://steipe.biochemistry.utoronto.ca/abc/students/index.php/User:Dmitry_H/Background_Selection_Theory)

### Shivani

Perhaps we could use [OBOEdit](http://bioinformatics.oxfordjournals.org/content/23/16/2198.full.pdf) or a similar function like grep to filter the OBO file for "human" in the name/terms/ID or associations sections? Also, since terms like "sample" or "biological process", etc. seem to be common, we might also try filtering the most common extraneous terms out if the "human" filter isn't enough and then seeing which terms are most common among the extraneous terms left to perform further filters.

### Tamara

### Chris

FANTOM5 has a data file containing all the Source names and FF_ontology values with categorical data such as time_course, tissues, primary cell etc.
Take this file [1](http://fantom.gsc.riken.jp/5/datafiles/phase2.0/basic/HumanSamples2.0.sdrf.xlsx) and turn it into an R-dataframe. Subset the rows that do not have Characteristics(Category) = time course or fractionation.
I think this is the easiest way to clean the data.

### Ryoga

OBO File Filtering suggestions
- In order to filter the .obo file, I think we can use OBO-Edit
- You can select, replace and merge ontology entries. It provides a nice overview and edit for the .obo file
[edit]OBO Edit 2
- I tried to download the software but I can't install it on my computer
- Here is a screen shot of the OBO-edit 2
- I have found a detailed manual [link](http://www.usc.es/keam/PhenotypeAnnotation/OBOANNOTATORUSERSMANUAL.pdf)

### Dan

1. I think Dmitry's idea of using only children of the cellular component root node sounds promising, it's biologically/semantically motivated. Maybe we could also generalize this to comparing the performance of Ontoscope when using other subgraphs that are not constrained to originate from one of the seven global roots. But then how do pick subgraphs to try? topological graph clustering?

2. Maybe we could try to reverse engineer the filtered ontology Mogrify is using. We could query their website for all (starting, ending) cell type transformations. I just now queried Mogrify (manually) for the conversions (CD19-positive B cell ---> embryonic stem cell line) & (fibroblast ---> embryonic stem cell line) and I get back a different list of TFs. So if we wanted to query Mogrify for all available cell transformation pairs, for any given target/destination cell type, in general we would get back a different TF list for each cell transformation pair with a given target cell type. For each target cell type we could take the union of all Mogrify TF lists of cell transformations with that target/destination cell type. Then for each target cell type we could form a histogram with the frequency of listing each TF. Presumably in the filtered ontology used by Mogrify behind the scenes, any pair of nearby nodes (i.e. target cell types) would imply greater similarity of their TF histograms/lists. Conversely, similarity of histograms between nodes probably/typically indicates closeness of the nodes. From this we could potentially infer the cell ontology graph Mogrify has created under the hood. Then we could put it as-is into our Ontoscope, or try to understand the biological semantics of the connections and why the Mogrify authors choose that filter

### Burton

Hey, here are some guidelines (heuristics) that I would follow to clean up the OBO file before converting to a cell lineage graph. Not sure if this helps you... Let me know if you were wanting something else.

- Keep terms that have 'CL' in their ID
- If you don't want to include cell samples, remove any terms with 'FF' in the ID. But maybe you want to include cell samples so that GATHER can use the tree to obtain expression profiles for cells and their backgrounds? I'm not sure about this...
- Remove anatomical parts (terms which contain 'UBERON' in the ID)
- Remove NCBI Taxons, which have 'NCBITaxon' in the ID
- Remove 'mouse' terms (if any part of the term (ID, is_a, etc.) contains 'mouse')
- Remove diseases ('DOID' in the ID)
- Remove molecules ('CHEBI' in the ID)

### Anam

You may consider using [ONTO-PERL](http://bioinformatics.oxfordjournals.org/content/24/6/885). You have [sample scripts](http://search.cpan.org/dist/ONTO-PERL/) as well such as "Find all root terms in a given ontology" or "Get child terms from a given ontology". A simple [OBO parser](https://gist.github.com/lindenb/2762967) in JS [(Java)] is also available on GitHub to try. Another approach would be to use the Ontology Lookup Service (OLS) and identify all cell lineage terms and use these terms to parse through the data.

### Howard

1. Create igraph object from raw data 
2. Generate list of nodes using V() 
3. Parse through the nodes by subsetting and filter out unwanted nodes by grep (grep(nodes$name, "sample") or something) 
4. Use remaining nodes and existing edges between them to create new igraph object (igraph has a function to do that I believe)

### Fupan

So for OBO files, shamelessly borrowing oboedit from Dmitry to better visualize the OBO file.
Unlike Burton, I believe that we should be keeping FF IDs in. From what I understand, we will be solely basing this on Homo Sapien inputs, and as a result, the only FF ID we care about is FF:0000210 (Homo Sapien).
In addition, under sample, the only nodes that should be included are the ones under human sample, and possible intersections with those under in vivo sample cell samples and tissue samples. From previous knowledge, cell line samples are not the best representative of real world performance, mainly due to immortal cell lines accumulating mutations and the general idea of isolated testing does not take into account many inter system relationships and interactions.
From this base, we can start branching out to include more information. I agree with the others on removing root, as it is mostly curation that does not pertain to the project, and disease for the same reasons.
Finally, in terms of finding the two target cell types for comparison, we need to determine some form of synonym system, discerning the differences between cell info that localize to the same place but perform different actions, such as cardiac fibroblast and myoblasts all localizing to "heart cells". Finally, we should develop some system of combining those samples with multiple info points, such as the T cell samples coming from multiple donors.

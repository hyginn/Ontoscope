# OBO Parsing Heuristic

or, how to make sense of 12000 edges.

## Summary, Common Ideas

WIP...

## Submissions

### Eugenia

### KartiKay

We are using the CO to create a graph using which we can select the background cell lines for a specific cell type to run the DEseq2 package to get the Gsx score. To run Deseq, we need raw expression data for the genes in that sample. I was wondering if all the data that we have in the OBO ("cells") has corresponding expression data? If not so how about back tracking by creating the graph only for the cell line (like 700 libraries in the paper) and use it to select background? I am well aware of possibilities to miss information here but certainly we can not have cell lines selected without expression data, as it will limit us at DEseq level. Hope this make sense. Any comments? 

### Jialun

### Phil

### Dmitry

The main idea is that instead of constructing a network of the entire OBO file, we filter the OBO file to only use the Ontology IDs that are directly useful for background selection - the CL: + FF:nodash. So we will create new OBO file: fantom_filtered.OBO. The IDs are already present in a relatively decent network (confirm it with OBOedit) so it should be pretty easy to construct a network out of them (and "subset" by nodes).. A downside to this approach is that we might miss some other functional relation, but if we do this semi-manually, I think this error will be minimized

[Lots more and pictures on student wiki](http://steipe.biochemistry.utoronto.ca/abc/students/index.php/User:Dmitry_H/Background_Selection_Theory)

### Shivani

Perhaps we could use [OBOEdit](http://bioinformatics.oxfordjournals.org/content/23/16/2198.full.pdf) or a similar function like grep to filter the OBO file for "human" in the name/terms/ID or associations sections? Also, since terms like "sample" or "biological process", etc. seem to be common, we might also try filtering the most common extraneous terms out if the "human" filter isn't enough and then seeing which terms are most common among the extraneous terms left to perform further filters.

### Tamara

### Chris

### Ryoga

### Dan

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

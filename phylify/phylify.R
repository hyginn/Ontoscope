# phylify 0.0.1 pre-release
# see: https://github.com/thejmazz/ontoscope-phylify
# very beta,
# but takes ndjson produced by bionode-obo and creates an igraph
# plot is very basic atm, need to look into customizations,etc

# Packages
if (!require(jsonlite, quietly=TRUE)) {
    install.packages("jsonlite")
}

if (!require(igraph, quietly=TRUE)) {
    install.packages("igraph")
}

# ndjson to data frame
# TODO open/close file nicely
terms <- stream_in(file("fantom.ndjson", "r"))

# trim whitespace utility function
# thanks f3lix http://stackoverflow.com/a/2261149/1409233
trim <- function (x) gsub("^\\s+|\\s+$", "", x)


# Make vector of parsed terms$is_a
isases <- c()
# for (i in 1:length(terms$is_a)) { isases <- c(isases, trim(strsplit(terms$is_a[i], "!")[[1]][1]) ) }

sources <- c()
targets <- c()
for (i in 1:length(terms$is_a)) {
    src <- trim(strsplit(terms$is_a[i], "!")[[1]][1])
   
    # sketchily assume source is a valid id if it contains : or _ 
    validSrc <- grepl(":|_", src)
    
    # print invalids to test feasiblity of sketchy code
    # if (!validSrc) {
    #     print(src)
    # }

    if (validSrc) {
        sources <- c(sources, src)
        targets <- c(targets, terms$id[i])
    }
}

# length(sources)
# length(targets)

relations <- data.frame(from=sources, to=targets)
ids <- terms$id
g <- graph_from_data_frame(relations, directed=TRUE, vertices=ids)

# source and do this yourself, heavy atm
plot(g)

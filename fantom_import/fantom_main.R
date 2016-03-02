# Purpose:   Access the Fantom Database and Extract the Relevant Counts/Annotation for Requested Cells
# Version:   0.7.9
# Date:      2016-03-02
# Author(s): Dmitry Horodetsky
#            Dan Litovitz
#
# Input:     string/list
# Output:    list of dataframes
# Depends:
#
# ToDo:      Implement all the other functions (as seen in the wiki)
# Notes:     
#
# V 0.5:     has fantomImport, fantomSearch, fantomList
#
# V 0.5.1:   fantomDirect added
#
# V 0.7:     fantomImport is replaced by fantomKeyword. fantomOntology Added
#
# V 0.7.5:   FANTOM Phase 2 Support Added (now we have both phase 1 and phase 2)
#            added a mode switch (return_counts)  
#
# V 0.7.7:   added fantomSummarize(), added Dan to authors
#
# V 0.7.8:   added exportCounts()
#
# V 0.7.9:   added .RData export capability (and set it as default)

#Libraries Install and Load
if (!require(iterators, quietly=TRUE)) {
  install.packages("iterators")
  library(iterators)
}

if (!require(data.table, quietly=TRUE)) {
  install.packages("data.table")
  library(data.table)
}

if (!require(stringr, quietly=TRUE)) {
  install.packages("stringr.")
  library(stringr)
}


#Load Sample_DB
fantom_samples <- read.table('Sample_DB.txt')

#THIS SETS THE MODE
#return_counts <- TRUE returns Counts
#return_counts <- FALSE returns NORMALIZED COUNTS

return_counts <- TRUE

#Initiate List
fantomResults <- list() 

####################
#MAIN FUNCTIONS
####################

fantomKeyword <- function(keywords){
  #Check Whether Samples_DB is Loaded (in the working Directory)
  .checkDB()
  
  #Check Mode (counts or normalized)
  .modeSelect()
  
  #Clear the list
  .resetFantom()
  
  #Prepare the Input for the Main Function
  
  #This is to fix inconsistant comma spacing
  keyword_list1 <- gsub(" ", "", keywords, fixed = TRUE)
  keyword_list2 <- c(str_split(keyword_list1, pattern = ','))
  
  final_FAN_list <- list()
  
  for (i in keyword_list2[[1]]){
    query_results <- fantom_samples[ grep(i, fantom_samples$V1) , ]
    processed_results <- c(query_results[,3])
    final_FAN_list <- c(processed_results, final_FAN_list)
  }
  .fantomImport((unlist((unique(final_FAN_list)))))
}

fantomDirect <- function(fantom_access_numbers) {
  #Check Whether Samples_DB is Loaded (in the working Directory)
  .checkDB()
  
  #Clear the list
  .resetFantom()
  
  #Check Mode (counts or normalized)
  .modeSelect()
  
  #Prepare the input for the Main Function
  user_query <- .character_to_numbers(fantom_access_numbers)
  
  #Boundary Check
  if (max(user_query) <= 1835 & min(user_query) >=7) {
    
    #Pass to Main Function
    fantom_access_numbers <- c(user_query)
    .fantomImport(unique(fantom_access_numbers))
  }
  
  else{
    stop("Fantom Access Numbers must be between 7 and 1835")
  }
}

fantomOntology <- function(ontology_IDs){
  #Check Whether Samples_DB is Loaded (in the working Directory)
  .checkDB()
  
  #Clear the list
  .resetFantom()
  
  #Check Mode (counts or normalized)
  .modeSelect()
  
  #Processing for fantomImport
  ontology_list1 <- gsub(" ", "", ontology_IDs, fixed = TRUE)
  ontology_list2 <- c(str_split(ontology_list1, pattern = ','))
  
  list_of_IDs <- list()
  for (i in ontology_list2[[1]])
  {
    if (substr(i,start = 1, stop = 3) == "FF:"){
      query_results <- fantom_samples[ grep(i, fantom_samples$FANTOM.5.Ontology.ID) , ]
      if (length(row.names(query_results)) == 0){
        list_of_IDs[i] <- NULL
      } else {
        list_of_IDs[i] <- c(query_results[,3])
      }
    } else {
      stop("Ontology IDs must be in a FF:XXXXX format")
    }
  }
  
  fantom_access_numbers <- as.numeric(list_of_IDs)
  
  match_num <- length(fantom_access_numbers)
  match_denom <- length(ontology_list2[[1]])
  
  #Matching Message
  message(paste("MATCHED:",match_num,"of",match_denom))
  
  #Load the Main Function
  .fantomImport(unique(fantom_access_numbers))
}

fantomSearch <- function(x){
  #Check Whether Samples_DB is Loaded (in the working Directory)
  .checkDB()
  
  query_results <- fantom_samples[ grep(x, fantom_samples$V1) , ]
  return (query_results)
  
}

fantomList <- function(){
  #Check Whether Samples_DB is Loaded (in the working Directory)
  .checkDB()
  
  return(fantom_samples)
}

###############
##BETA FUNCTION. MIGHT BREAK AT ANY TIME
###############

fantomSummarize <- function(){
  if(length(fantomResults) < 1)
    stop("action skipped: fantomResults cannot be empty")
  
  message("Filtering Relevant Results. This step takes awhile ...")
  deleteEmpty()
  
  message("Fixing IDs")
  fixID()
  
  fantomCounts <<- list()
  
  #Prepare list
  message("Preparing the Genes")
  fantomCounts[[1]] <<- fantomResults[[1]][3]
  fantomCounts[[2]] <<- fantomResults[[1]][4]
  
  iterator_counter2 <- icount(length((fantomResults)))
  
  for (k in fantomResults){
    current_count3 <- nextElem(iterator_counter2)
    fantomCounts[[2+current_count3]] <<- k[6]
    message(paste0("Summaryzing:",colnames(k[6])))
    
  }
  fantomCounts <<- data.frame(fantomCounts)
  message("Your results have been summarized in: fantomCounts")
  
}

#################################

exportCounts <-function(export_type){
  
  if (missing (export_type)){
    export_type <- ".RData"
  }
  
  if(length(fantomResults) < 1)
    stop("fantomResults cannot be empty") else{
      if (exists("fantomCounts")){
        
        #select your Gene Column
        #gene_to_null <- 1 ; return HGNC IDs
        #gene_to_null <- 2; return entrez gene IDs
        #default is HGNC IDs
        
        gene_to_null <- 1
        fantomCounts[gene_to_null] <- NULL
        
        if (export_type == ".csv") {
          message("Generating fantomCounts.csv ...")
          write.csv(fantomCounts, "fantomCounts.csv", row.names=FALSE)
          message("fantomCounts.csv generated (in your working directory)!")
        } 
        
        if (export_type == ".RData"){
          message("Generating fantomCounts.RData ...")
          save(fantomCounts, file = "fantomCounts.RData", compress = TRUE)
          message("fantomCounts.RData generated (in your working directory)!")
          }
          
        if (export_type != ".RData" & export_type != ".csv"){
          message("Only two arguments are supported \".csv\" or \".RData\"")
        }
        
        
      } else {
        message(("fantomCounts not present. Please use fantomSummarize() to generate"))
      }
    } 
}


loop_fantom_list <- function(call_func){
  if(length(fantomResults) < 1)
    stop("action skipped: fantomResults cannot be empty")
  
  IDENTIFIERS = c("entrezgene_id", "hgnc_id", "uniprot_id")
  ID_KEY_VALUE_LINK = ":"
  for(loop_index in 1:length(fantomResults))
    call_func(loop_index, IDENTIFIERS, ID_KEY_VALUE_LINK)
}

deleteEmpty <- function(){
  loop_fantom_list(function(i, IDENTIFIERS, ID_KEY_VALUE_LINK){
    fantomResults[[i]] <<- fantomResults[[i]][apply(fantomResults[[i]][, IDENTIFIERS], 1, function(x){length(grep("[[:alnum:]]", x)) > 0}), ]
    rownames(fantomResults[[i]]) <<- NULL
  })
}

fixID <- function(){
  loop_fantom_list(function(i, IDENTIFIERS, ID_KEY_VALUE_LINK){
    replace_str = paste("(?<![[:word:]])[[:word:]]+?", ID_KEY_VALUE_LINK, sep = "")
    fantomResults[[i]][, IDENTIFIERS] <<- apply(fantomResults[[i]][, IDENTIFIERS], 2, function(x){gsub(replace_str, x, perl = TRUE, replacement = "")})
  })
}




##########################
#INTERNAL HELPER FUNCTIONS
##########################


#Function to clear the fantomResults list
.resetFantom <- function(){
  fantomResults[] <<- NULL
  
}

#Takes a user's query (ie character type) and extracts numbers from it
.character_to_numbers <- function(user_query){
  
  #shout out to http://stackoverflow.com/a/17009777
  number_list <-unique(na.omit(as.numeric(unlist(strsplit(
    unlist(user_query),"[^0-9]+")))))
  return (number_list)
}


#The main "ENGINE" of the fantom Import system. 
#This function accesses the fantom Server and
#retrieves the cells based on "Fantom Access Numbers"
#Fantom Access Numbers are simply "columns", which
#correspond to cells in the Fantom Data Base

#Most other functions just prepare the input for this function

.fantomImport <- function(fantom_access_numbers) {
  length_of_FANs <- length(fantom_access_numbers)
  iterator_counter <- icount(length_of_FANs)
  
  message(paste(length_of_FANs, "Search Result(s) Were Found. Loading..."))
  
  for(i in fantom_access_numbers)
  {
    current_count <- nextElem(iterator_counter)
    message((paste("Loading Results from Fantom Access Number",i,
                   "(",current_count,"/",length_of_FANs,")","...")))
    fantomResults[[current_count]] <<- 
    {
      fantom_df <- fread(
        paste0(URL1,as.character(i),URL2),
        sep="\t", header=TRUE, stringsAsFactors = FALSE, showProgress = FALSE, data.table = FALSE)
    }
    message((paste("Results from Fantom Access Number",i, "Loaded!")))
  }
  message(paste("All results have been loaded into fantomResults")) 
  
}

.modeSelect <- function(){
  if (as.logical(return_counts) == TRUE) {
    message ("Returning RAW COUNTS")
    URL1 <<- "http://fantom.gsc.riken.jp/5/tet/search/?c=0&c=1&c=4&c=5&c=6&c="
    URL2 <<- "&filename=hg19.cage_peak_phase1and2combined_counts_ann_decoded.osc.txt.gz"
  } else {
    message (("Returning RLE NORMALIZED COUNTS"))
    URL1 <<- "http://fantom.gsc.riken.jp/5/tet/search/?c=0&c=1&c=4&c=5&c=6&c="
    URL2 <<- "&filename=hg19.cage_peak_phase1and2combined_tpm_ann_decoded.osc.txt.gz"
  }
  
}

.checkDB <- function(){
  if (file.exists("Sample_DB.txt")){
    print ('Sample_DB Loaded!')
  } else { stop("Sample_DB not found. Please put it in your working directory")
  }
}

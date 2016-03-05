# Purpose:   Access the Fantom Database and Extract the Relevant Counts/Annotation for Requested Cells
# Version:   0.9.0
# Date:      2016-03-04
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
#
# V 0.8.5:   MAJOR RELEASE
#             fantomSummarize() upgraded. 
#             Returns [FANTOM] normalized gene names
#
# V 0.9.0    added filterTFs()

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
  install.packages("stringr")
  library(stringr)
}

if (!require(plyr, quietly=TRUE)) {
  install.packages("plyr")
  library(plyr)
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
#FantomKeyword()
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

#########################
#fantomDirect()
#########################

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

################
#fantomOntology()
################

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

###############
#fantomSearch()
###############

fantomSearch <- function(x){
  #Check Whether Samples_DB is Loaded (in the working Directory)
  .checkDB()
  
  query_results <- fantom_samples[ grep(x, fantom_samples$V1) , ]
  return (query_results)
  
}

###############
#fantomList()
###############

fantomList <- function(){
  #Check Whether Samples_DB is Loaded (in the working Directory)
  .checkDB()
  
  return(fantom_samples)
}

###################
#fantomSummarize()
###################

fantomSummarize <- function(){
  if(length(fantomResults) < 1)
    stop("action skipped: fantomResults cannot be empty")
  
  message("Filtering Relevant Results. This step takes awhile ...")
  deleteEmpty()
  
  fantomCounts <<- list()
  
  #Prepare list
  message("Preparing the Genes")
  fantomCounts[[1]] <<- fantomResults[[1]][2]
  
  iterator_counter2 <- icount(length((fantomResults)))
  
  for (k in fantomResults){
    current_count3 <- nextElem(iterator_counter2)
    fantomCounts[[1+current_count3]] <<- k[6]
    message(paste0("Summarizing:",colnames(k[6])))
    
  }
  
  fantomCounts <<- data.frame(fantomCounts)
  
  message("Preparing Normalized Gene Names")
  
  iterator_counter3 <- icount(length((fantomCounts[[1]])))
  
  for (i in fantomCounts[[1]]){
    current_count4 <- nextElem(iterator_counter3)
    fantomCounts[current_count4,1] <<- gsub(".+@", "",fantomCounts[current_count4,1])
    if (current_count4 %% 1000 == 0){
      message(paste("Normalized:",current_count4,"/",length((fantomCounts[[1]])), "Genes"))
    }
  }
  
  message ("All Genes Normalized!")
  
  message("Fixing Duplicates ...")
  #Shout out to Ben Bolker @
  #http://stackoverflow.com/a/10180178
  
  fantomCounts <<- ddply(fantomCounts,"short_description",numcolwise(sum))
  
  message("Your results have been summarized in: fantomCounts!")
  
}

###########################
#exportCounts()
###########################

exportCounts <-function(export_type){
  
  #Check whether fantomCounts exist
  .checkFantomCounts()
  
  if (missing (export_type)){
    export_type <- ".RData"
  }
  
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
    message("Only two arguments are supported: \".csv\" or \".RData\"")
  }
  
} 

##############
#filterTFs()
##############

filterTFs <- function(){
  #Load the Transcription Factor datbases
  .TFdatabaseLoad()
  
  #Check whether fantomCounts exist
  .checkFantomCounts()
  
  #convert TF database to a vector
  TF_vector <- TF_database[,1]
  
  #Clone fantomCounts
  fantomTFs <<-fantomCounts
  
  #yet another loop
  iterator_counter7 <- icount(length((fantomCounts[[1]])))
  
  #Goal is to "blank out" Genes that don't exist in TF_database
  for (m in fantomCounts[[1]]){
    current_count7 <- nextElem(iterator_counter7)
    if (m %in% TF_vector == FALSE) {
      fantomTFs[current_count7,] <<- NA
    } 
    if (current_count7 %% 1000 == 0){
      message(paste("Processed:",current_count7,"/",length((fantomCounts[[1]])), "Genes")) 
    }
  }
  message("Filtering ...")
  
  #Remove the Null Results
  #Shoutout @ Wookai
  #http://stackoverflow.com/a/6437778
  fantomTFs <<- fantomTFs[rowSums(is.na(fantomTFs)) == 0,]
  
  save(fantomTFs, file = "fantomTFs.RData", compress = TRUE)
  message("1. fantomTFs dataframe created!")
  message("-and-")
  message("2. fantomTFs.RData saved to your working directory")
  
  
  

}     
        
        

###############
#Processing Functions
###############

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

## File created thanks to Shivani Kamdar
.TFdatabaseLoad <- function(){
  
  if (file.exists("TF_database.RData")){
    load("TF_database.RData", envir = globalenv())
    message("TF_database Loaded!")
    
  } else {
    message("You are missing the \"TF_database.RData\" file. Please put it in your working directory")
  }
}

.checkFantomCounts <- function(){
  if (exists("fantomCounts") == FALSE){
    message("fantomCounts does not exist. Please use fantomSummarize() to generate it") & stop()
  } else { message("fantomCounts Loaded!")
  }
}

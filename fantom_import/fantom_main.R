# Purpose:   Access the Fantom Database and Extract the Relevant Counts/Annotation for Requested Cells
# Version:   0.7.5
# Date:      2016-02-28
# Author:    Dmitry Horodetsky
#
# Input:     string/list
# Output:    list of dataframes
# Depends:
#
# ToDo:      Implement all the other functions (as seen in the wiki)
# Notes:     
#
# V 0.5:     has fantomImport, fantomSearch, fantomList
# V 0.5.1:   fantomDirect added
# V 0.7:     fantomImport is replaced by fantomKeyword. fantomOntology Added
# V 0.7.5:   FANTOM Phase 2 Support Added (now we have both phase 1 and phase 2)
#            added a mode switch (return_counts)      


#Libraries Install
if (!require(iterators, quietly=TRUE)) {
  install.packages("iterators")
}

if (!require(iterators, quietly=TRUE)) {
  install.packages("data.table")
}

if (!require(iterators, quietly=TRUE)) {
  install.packages("stringr.")
}

#Libraries Load
library(data.table)
library(iterators)
library(stringr)

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
  if (file.exists("Sample_DB.txt")){
    print ('Sample_DB Loaded!')
  } else { stop("Sample_DB not found. Please put it in your working directory")
    
  }
  
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
  if (file.exists("Sample_DB.txt")){
    print ('Sample_DB Loaded!')
  } else { stop("Sample_DB not found. Please put it in your working directory")
    
  }
  
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
  if (file.exists("Sample_DB.txt")){
    print ('Sample_DB Loaded!')
  } else { stop("Sample_DB not found. Please put it in your working directory")
    
  }
  
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
  if (file.exists("Sample_DB.txt")){
    print ('Sample_DB Loaded!')
  } else { stop("Sample_DB not found. Please put it in your working directory")
    
  }
  query_results <- fantom_samples[ grep(x, fantom_samples$V1) , ]
  return (query_results)
  
}

fantomList <- function(){
  #Check Whether Samples_DB is Loaded (in the working Directory)
  if (file.exists("Sample_DB.txt")){
    print ('Sample_DB Loaded!')
  } else { stop("Sample_DB not found. Please put it in your working directory")
  }
  
  return(fantom_samples)
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
        sep="\t", header=TRUE, stringsAsFactors = FALSE, showProgress = FALSE)
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
  
  

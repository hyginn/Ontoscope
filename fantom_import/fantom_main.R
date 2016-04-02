# Purpose:   Access the Fantom Database and Extract the Relevant Counts/Annotation for Requested Cells
# Version:   1.0.1
# Date:      2016-04-01
# Author(s): Dmitry Horodetsky
#            Dan Litovitz
#
# Input:     string/list
# Output:    list of dataframes
# Depends:
#
# ToDo:      N/A
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
#
# V 0.9.1    significantly improved the speed of fantomSummarize() and filterTFs()
#             (replaced for-loop with apply())
#
# V 0.9.5    improved code readability/refactoring, can now pass lists/vectors into the module,
#            fantomSummarize() now takes threshold values
#
# V 1.0.0    MAJOR Release
#               -Offline Mode added to all fantom retrieval functions
#               -Processing Functions Improved
#               
# V 1.0.1   Reverse Search Implemented (Given FF:A-B, return name)
#

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

if (!require(tidyr, quietly=TRUE)) {
  install.packages("tidyr")
  library(tidyr)
}


#Load Sample_DB

#Try the 'default' directory load or 'Ontology' directory load

#Shout out to Jonathan Callahan @
#http://mazamascience.com/WorkingWithData/?p=912

fantom_samples <- tryCatch({
  read.table('Sample_DB.txt')
}, error = function(e){
  read.table('./fantom_import/Sample_DB.txt')
}, warning = function(w){
  read.table('./fantom_import/Sample_DB.txt')
}

)

#THIS SETS THE MODE
#return_counts <- TRUE returns Counts
#return_counts <- FALSE returns NORMALIZED COUNTS

return_counts <- TRUE

#Initiate List
fantomResults <- list() 

####################
#FantomKeyword()
####################

fantomKeyword <- function(keywords, online){
  if (missing(online)){
    online <- TRUE
  }
  .fantomImport(online, keywords, function(fantom_query){ #Prepare the Input for the Main Function
    
    final_FAN_list <- list()
    
    for (i in fantom_query){
      query_results <- fantom_samples[ grep(i, fantom_samples$V1, ignore.case = TRUE) , ]
      processed_results <- c(query_results[,3])
      final_FAN_list <- c(processed_results, final_FAN_list)
    }
    
    return(unlist(final_FAN_list))
    
  })
}

#########################
#fantomDirect()
#########################

fantomDirect <- function(fantom_access_numbers, online) {
  if (missing(online)){
    online <- TRUE
  }
  
  .fantomImport(online,fantom_access_numbers, function(fantom_query){ #Prepare the Input for the Main Function
    
    user_query <- strtoi(fantom_query)
    
    #Boundary Check
    if (max(user_query) <= 1835 & min(user_query) >=7)
      return(user_query)
    else
      stop("Fantom Access Numbers must be between 7 and 1835")
    
  })
}

################
#fantomOntology()
################

fantomOntology <- function(ontology_IDs, online){
  if (missing(online)){
    online <- TRUE
  }
  
  .fantomImport(online, ontology_IDs, function(fantom_query){ #Prepare the Input for the Main Function  
    
    list_of_IDs <- list()
    for (i in fantom_query)
    {
      if (substr(i,start = 1, stop = 3) == "FF:"){
        query_results <- fantom_samples[ grep(i, fantom_samples$FANTOM.5.Ontology.ID, ignore.case = TRUE) , ]
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
    match_denom <- length(fantom_query)
    
    #Matching Message
    message(paste("MATCHED:",match_num,"of",match_denom))
    
    #Load the Main Function
    return(fantom_access_numbers)
  })
}

###############
#fantomSearch()
###############

fantomSearch <- function(query, type){
  #Check Whether Samples_DB is Loaded (in the working Directory)
  #.checkfantomDB()
  
  if (missing(type)){
    type <- TRUE
  }
  
  if (type == TRUE){
    query_results <- fantom_samples[ grep(query, fantom_samples$V1, ignore.case = TRUE) , ]
    return (query_results)
  }
  
  if (type == FALSE){
    indexes <- c(1:length(query))
    results <- c()
    
    for (i in indexes){
      query_results <- fantom_samples[grep(query[i], fantom_samples$FANTOM.5.Ontology.ID), ]
      results[i] <- c(as.character(query_results[[1]]))
    }
    return (results)
  }

  
}

###############
#fantomList()
###############

fantomList <- function(){
  #Check Whether Samples_DB is Loaded (in the working Directory)
  .checkfantomDB()
  
  return(fantom_samples)
}

###################
#fantomSummarize()
###################

fantomSummarize <- function(threshold){
  if(length(fantomResults) < 1)
    stop("action skipped: fantomResults cannot be empty")
  
  if (missing(threshold)){
    threshold <- NA
  }
  
  
  message("Filtering Relevant Results. This step takes awhile ...")
  
  IDENTIFIERS = c("entrezgene_id", "hgnc_id", "uniprot_id")
  deleteEmpty(IDENTIFIERS)
  
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
  
  message("Preparing Normalized Gene Names ...")
  
  #Shout out to RoyalTS @
  #http://stackoverflow.com/a/22656776
  fantomCounts[1] <<- apply(fantomCounts[1],2,function(x) gsub(".+@",'',x))
  
  message ("All Genes Normalized!")
  
  message("Fixing Duplicates ...")
  
  #Shout out to Ben Bolker @
  #http://stackoverflow.com/a/10180178
  
  fantomCounts <<- ddply(fantomCounts,"short_description",numcolwise(sum))
  
  message("Applying Threshold ...")
  
  #Shout out to deseq2 manual and 
  #akrun @ http://stackoverflow.com/a/30967066
  fantomCounts <<- fantomCounts[!rowSums(fantomCounts <= (threshold-1), 2:ncol(fantomCounts)),]
  
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
  
  message("Filtering ...")
  
  tf_found <- (fantomTFs[1][,] %in% TF_vector)
  fantomTFs <<- fantomTFs[tf_found,]
  
  save(fantomTFs, file = "fantomTFs.RData", compress = TRUE)
  message("1. fantomTFs dataframe created!")
  message("-and-")
  message("2. fantomTFs.RData saved to your working directory")
  
}     

###############
#Processing Functions
###############

deleteEmpty <- function(identifiers){
  .loop_fantom_list(function(i){
    fantomResults[[i]] <<- fantomResults[[i]][apply(fantomResults[[i]][, identifiers, drop = FALSE], 1, function(x){length(grep("[[:alnum:]]", x)) > 0}), ]
    rownames(fantomResults[[i]]) <<- NULL
  })
}

fixID <- function(identifiers, id_key_value_link){
  .remove_pattern(paste("(?<![[:word:]])[[:word:]]+?", id_key_value_link, sep = ""), identifiers)
}

fixAnnotation <- function(annotation_column){
  .split_column(annotation_column, ":|,|\\.\\.", c("Chr", "Start", "End", "Strand"))
  .remove_pattern("chr", "Chr")
}

fixDescription <- function(description_column){
  .split_col_across_rows(description_column, ",")
  .split_column(description_column, "@", c("Peak", "Gene"))
  .remove_pattern("p", "Peak")
  .loop_fantom_list(function(i){
    fantomResults[[i]][apply(fantomResults[[i]][, "Peak", drop = FALSE], 1, function(x){length(grep("^\\s*$", x)) > 0}), c("Peak", "Gene")] <<- c(NA, NA)
  })
}

fantomProcess <- function(){
  IDENTIFIERS = c("entrezgene_id", "hgnc_id", "uniprot_id")
  ID_KEY_VALUE_LINK = ":"
  ANNOTATION_COL = "X00Annotation"
  DESCRIPTION_COL = "short_description"

  deleteEmpty(IDENTIFIERS)
  fixID(IDENTIFIERS, ID_KEY_VALUE_LINK)
  fixDescription(DESCRIPTION_COL)
  fixAnnotation(ANNOTATION_COL)
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

.fantomImport <- function(online, raw_fantom_query, get_fantom_access_numbers) {
  #Check Whether Samples_DB is Loaded (in the working Directory)
  .checkfantomDB()
  
  #Clear the list
  .resetFantom()
  
  #Check Mode (counts or normalized)
  .modeSelect()
  
  fantom_access_numbers <- get_fantom_access_numbers(.flatten_split_str_vec(raw_fantom_query))
  
  length_of_FANs <- length(fantom_access_numbers)
  iterator_counter <- icount(length_of_FANs)
  
  message(paste(length_of_FANs, "Search Result(s) Were Found. Loading..."))
  
  for(i in fantom_access_numbers)
  {
    current_count <- nextElem(iterator_counter)
    message((paste("Loading Results from Fantom Access Number",i,
                   "(",current_count,"/",length_of_FANs,")","...")))
    
    #The default online mode
    if (online == TRUE){
      fantomResults[[current_count]] <<- 
      {
        fantom_df <- fread(
          paste0(URL1,as.character(i),URL2),
          sep="\t", header=TRUE, stringsAsFactors = FALSE, showProgress = FALSE, data.table = FALSE)
      }
      message((paste("Results from Fantom Access Number",i, "Loaded!")))
    }
    
    #offline mode
    if (online == FALSE){
      file_directory <- "fantom_import/fantomOffline/"
      file_prefix <- "?c=0&c=1&c=4&c=5&c=6&c="
      file_suffix <- "&filename=hg19.cage_peak_phase1and2combined_counts_ann_decoded.osc.txt.gz"
      file_to_import <- paste0(file_directory,file_prefix,i,file_suffix)
      
      if (file.exists(file_to_import)){
        fantomResults[[current_count]] <<- 
        {
          fantom_df <- fread(file_to_import,
                             sep="\t", header=TRUE, stringsAsFactors = FALSE, showProgress = FALSE, data.table = FALSE)
        }
        message((paste("Results from Fantom Access Number",i, "Loaded!")))
      } else {
        message(paste("WARNING: file",file_to_import,"does not exist"))
        message("#####################")
        message("Reminder: OFFLINE functionality ONLY works if 'ontoscope' is set as the work directory and your offline files are in 'Ontoscope/fantom_import/fantomOffline'")
        message("#####################")
        }
      }
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

.checkfantomDB <- function(){
  if (exists("fantom_samples")){
    print ('Sample_DB Loaded!')
  } else { stop("Sample_DB not found. 'Ontoscope' should be your working directory and Sample_DB.txt should be in the 'fantom_import' folder")
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

.loop_fantom_list <- function(call_func){
  if(length(fantomResults) < 1)
    stop("action skipped: fantomResults cannot be empty")

  for(loop_index in 1:length(fantomResults))
    call_func(loop_index)
}

.remove_pattern <- function(perl_regex, col_names){
  .loop_fantom_list(function(i){
    fantomResults[[i]][, col_names] <<- apply(fantomResults[[i]][, col_names, drop = FALSE], 2, function(x){gsub(perl_regex, x, perl = TRUE, replacement = "")})
  })
}

.split_column <- function(col_name, separator_regex, new_col_names){
  .loop_fantom_list(function(i){
    fantomResults[[i]] <<- separate_(fantomResults[[i]], col_name, new_col_names, separator_regex)
  })
}

#pre-condition: there is not a column "temp_col" in fantomResults[[i]]
.split_col_across_rows <- function(col_name, separator_regex){
  .loop_fantom_list(function(i){
    fantomResults[[i]] <<- fantomResults[[i]] %>% unnest(temp_col = strsplit(fantomResults[[i]][, col_name], separator_regex))
    fantomResults[[i]] <<- data.frame(fantomResults[[i]])
    set(fantomResults[[i]], j = col_name, value = NULL)
    colnames(fantomResults[[i]])[colnames(fantomResults[[i]]) == "temp_col"] <<- col_name
  })
}

.flatten_split_str_vec <- function(vector_in){
  vector_out <- paste(vector_in, collapse = ",")
  vector_out <- strsplit(vector_out, ",")[[1]]
  vector_out <- unique(toupper(str_trim(vector_out)))
  return(vector_out[vector_out != ""])
}






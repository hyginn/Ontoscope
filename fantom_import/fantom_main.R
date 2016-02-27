# Purpose:   Access the Fantom Database and Extract the Relevant Counts/Annotation for Requested Cells
# Version:   0.5.2
# Date:      2016-02-27
# Author:    Dmitry Horodetsky
#
# Input:     string
# Output:    list of dataframes
# Depends:
#
# ToDo:      Implement all the other functions (as seen in the wiki)
# Notes:     
#
# V 0.5:     has fantomImport, fantomSearch, fantomList
# V 0.5.1:   fantomDirect added
# V 0.5.2:   Code Readability Improved


#Libraries Install
if (!require(iterators, quietly=TRUE)) {
  install.packages("iterators")
}

if (!require(iterators, quietly=TRUE)) {
  install.packages("data.table")
}

#Libraries Load
library(data.table)
library(iterators)

#Load Sample_DB
fantom_samples <- read.table('Sample_DB.txt')


URL1 <- "http://fantom.gsc.riken.jp/5/tet/search/?c=0&c=1&c=4&c=5&c=6&c="
URL2 <- "&filename=hg19.cage_peak_counts_ann_decoded.osc.txt.gz&q=&skip=0"

fantomResults <- list() 

####################
#MAIN FUNCTIONS
####################

fantomImport <- function(keyword){
  #Check Whether Samples_DB is Loaded (in the working Directory)
  if (file.exists("Sample_DB.txt")){
    print ('Sample_DB Loaded!')
  } else { stop("Sample_DB not found. Please put it in your working directory")
    
  }
  
  #Clear the list
  .resetFantom()
  
  #Prepare the Input for the Main Function
  query_results <- fantom_samples[ grep(keyword, fantom_samples$V1) , ]
  fantom_access_numbers <- c(query_results[,3])
  
  #Main Function
  .fantomMain(fantom_access_numbers)
  
}

fantomDirect <- function(fantom_access_numbers) {
  #Check Whether Samples_DB is Loaded (in the working Directory)
  if (file.exists("Sample_DB.txt")){
    print ('Sample_DB Loaded!')
  } else { stop("Sample_DB not found. Please put it in your working directory")
    
  }
  
  #Clear the list
  .resetFantom()
  
  #Prepare the input for the Main Function
  user_query <- .character_to_numbers(fantom_access_numbers)
  
  #Boundary Check
  if (max(user_query) <= 895 & min(user_query) >=7) {
    
    #Pass to Main Function
    fantom_access_numbers <- c(user_query)
    .fantomMain(fantom_access_numbers)
  }
  
  else{
    stop("Fantom Access Numbers must be between 7 and 895")
  }
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

.fantomMain <- function(fantom_access_numbers) {
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
  
  

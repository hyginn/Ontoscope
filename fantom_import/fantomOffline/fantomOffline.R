#fantomOffline
#V 1.0
#By: Dmitry Horodetsky and Dan Litovitz


source("fantom_import/fantom_main.R")

fantomOffline <- function(fantom_IDs){
  
  .checkfantomDB()
  .resetFantom()
  
  list_of_IDs <- list()
  
  #Convert fantom IDs to Fantom Access Numbers
  for (i in fantom_IDs)
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
  
  #Import those Fantom Access Numbers
  fantom_files <- "fantom_import/fantomOffline/fantom_files/"
  length_of_FANs <- length(list_of_IDs)
  iterator_counter8 <- icount(length_of_FANs)
  
  message(paste(length_of_FANs, "Search Result(s) Were Found. Loading..."))
  
  for (i in list_of_IDs) {
    current_count <- nextElem(iterator_counter8)
    item_to_import <- paste0(fantom_files,list_of_IDs[current_count])
    if (file.exists(item_to_import)){
      message((paste("Loading Results from Fantom Access Number",i,
                     "(",current_count,"/",length_of_FANs,")","...")))
      
      
      fantomResults[[current_count]] <<- 
      {
        fantom_df <- fread(
          item_to_import,
          sep="\t", header=TRUE, stringsAsFactors = FALSE, showProgress = FALSE, data.table = FALSE)
      }
      message((paste("Results from Fantom Access Number",i, "Loaded!")))
    } else {
      message(paste("WARNING: file",list_of_IDs[current_count],"does not exist"))
    }
  }
  message(paste("All results have been loaded into fantomResults"))
}
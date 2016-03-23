# Purpose:   Access the Fantom Database and etrieve the Relevant .bed files
# Version:   1.0.0
# Date:      2016-03-21
# Author(s): Dmitry Horodetsky
#  
#
# Input:     List/Character Vector
# Output:    .bed files downloaded
#
#
# V 1.0.0     Initial Commit


#Check whether the BED_DB file is present

.checkDB <- function(){
  if (file.exists("BED_DB.RData")){
    load("BED_DB.RData",envir = globalenv())
    message ('BED_DB Loaded!')
  } else { stop("BED_DB not found. Please put it in your working directory")
  }
}
.checkDB()

#Main Function
getBED <- function(IDs){
  for (i in IDs){
    if (substr(i,start = 1, stop = 3) == "FF:"){
      fixed_ID <- gsub("FF:","",i)
      dl_index <- grep(fixed_ID,BED_DB[,1])
      message(paste("Downloading...",i))
      download.file(as.character(BED_DB[dl_index,1]),paste0(fixed_ID,".bed.gz"))
      message(paste(i,"Saved!"))
    } else {
      stop("Ontology IDs must be in a FF:XXXXX format")
    }
  }
}

    




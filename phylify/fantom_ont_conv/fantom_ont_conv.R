# A Simple CNhsXXXXXX to FF:A-B converter
# By Dmitry


#####
#Load the Database
#####
.check_ID_DB <- function(){
  if (file.exists("ID_database.RData")){
    load("ID_database.RData",envir = globalenv())
    message ('ID_database Loaded!')
  } else { stop("ID_database.RData not found. Please put it in your working directory")
  }
}

.check_ID_DB()

####
#Main Function
####

#List/Character in, Character out

convertIDs <- function (IDs) {
  result <- c()

  for (i in IDs){
    index <- grep(i,ID_database[,2])
    result <- c(result, ID_database[index,1])
  }
  return (unique(as.character(result)))
}

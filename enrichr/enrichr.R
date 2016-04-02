# Enrichr_api.R
#
# Purpose:   Parse gene enrichment result from Enrichr
# Version:   1.0
# Date:      2016-03-23
# Author:    Jialun Tom Chen
#
# Input:     A list of gene name in offical gene symbol
# Output:    Enrichment result score presented in plot
# Depends:
#
# ToDo:      data interpretation and ggplot2 visualization. 
# Notes:     <more notes>
#
# ====  PARAMETERS  ==================================================

# (these are examples ... delete.)
# Don't put "magic numbers" and files in your code. Place them here,
# assign them to a well-named variable and explain the meaning!
#
baseURL <- "http://amp.pharm.mssm.edu/Enrichr"  #baseURL
URL <- sprintf('%s%s', baseURL, "/addList")     #URL
load("~/DAVIS/libraries.Rda")
featuregeneset <- c("2","6","10","11","12","25","26","27","55","57")

# ====  PACKAGES  ====================================================
# (these are examples ... delete.)
#

# package example ... code paradigm to quietly install missing
#                     packages and load them
if (!require(httr, quietly=TRUE)) { 
  install.packages("jsonlite")
  library(jsonlite)
}

if (!require(httr, quietly=TRUE)) { 
  install.packages("httr")
  library(httr)
}

if (!require(httr, quietly=TRUE)) { 
  install.packages("ggplot2")
  library(ggplot2)
}


# ====  FUNCTIONS  ===================================================
getID <- function(input){
  addListResp <- POST(URL,
                      body = list(species = "HUMAN",
                                  list = paste(input, collapse="\n"),
                                  description = "test"))
  if (addListResp$status_code == 200) {
    message("Response OK")}
  else {
    message("No response")}
  respHTML <- content(addListResp, as="text")
  m <- regexec('.*(\\{.*\\})', respHTML)
  respJSON <- regmatches(respHTML, m)[[1]][2]
  respIDs <- fromJSON(respJSON)
}

GetFeatures <- function(input, descri){
  for (x in featuregeneset){
    type <- libraries$Geneset[libraries$ID == x]
# get ID
    addListResp <- POST(URL,
                        body = list(species = "HUMAN",
                                    list = paste(input, collapse="\n"),
                                    description = "test"))
    if (addListResp$status_code == 200) {
      message("Response OK")}
    else {
      message("No response")}
    respHTML <- content(addListResp, as="text")
    m <- regexec('.*(\\{.*\\})', respHTML)
    respJSON <- regmatches(respHTML, m)[[1]][2]
    respIDs <- fromJSON(respJSON)
# get results
    URL_analysis <- sprintf('%s/enrich?backgroundType=%s&userListId=%s',
                            baseURL, type, respIDs$userListId)
    JSONResult <- GET(URL_analysis)
    resultList <- fromJSON(content(JSONResult, as="text"))
    nRows <- length(resultList[[1]])
    resultDF <- data.frame(name=character(nRows),
                           genes=character(nRows),
                           P=numeric(nRows),
                           Z=numeric(nRows),
                           score=numeric(nRows),
                           stringsAsFactors=FALSE)
    for (i in 1:nRows) { #only store the top10 ranked by combined scores
      resultDF$name[i]  <- resultList[1][[1]][[i]][[2]]
      resultDF$genes[i] <- paste(resultList[1][[1]][[i]][[6]], collapse=" ")
      resultDF$P[i]     <- resultList[1][[1]][[i]][[3]]
      resultDF$Z[i]     <- resultList[1][[1]][[i]][[4]]
      resultDF$score[i] <- resultList[1][[1]][[i]][[5]]
    }
    if (x == 2) {
      resultDF <- resultDF[grep("human",resultDF$name),]
    }
    resultDF <- resultDF[1:10,]
    date <- Sys.Date()
    filename <- paste(date, "_", descri, "_", type, ".csv", sep = "")
    write.table(resultDF, file = filename,sep = ",")}
}

# ====  TESTS  =======================================================


input <- c("Nsun3", "Polrmt", "Nlrx1", "Sfxn5",
           "Zc3h12c", "Slc25a39", "Arsg", "Defb29",
           "Ndufb6", "Zfand1", "Tmem77")
GetFeatures(input, "testv4")

nicePath <- function (filename) {
  tryCatch({
    return(file.path(getwd(), dirname(sys.frame(1)$ofile), filename))
  }, error = function (error) {
    return(filename)
  })
}

print(read.csv(nicePath("cool.csv")))
print(read.csv(nicePath("../hot.csv")))

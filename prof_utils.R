# Purpose:   Super friendly profiling
# Date:      2016-03-13

time <- function(func, ...)
{
  ptm <- proc.time()
  func(...)
  diff <- proc.time() - ptm
  print(paste(round(diff["elapsed"], 2), "seconds"))
}

profile <- function(func, ...) {
  Rprof(tmp <- tempfile(), memory.profiling = TRUE, interval = 0.01)
  func(...)
  Rprof(NULL)
  prof_data <- summaryRprof(tmp, memory = "both")

  selected_data <- data.frame(transpose(list(prof_data$by.self$mem.total, prof_data$by.self$self.pct)))
  colnames(selected_data) <- gsub("^\"|\"$", "", rownames(prof_data$by.self))
  rownames(selected_data) <- c("mem_pct", "time_pct")
  mem_allocs <- sum(selected_data["mem_pct",])
  if(mem_allocs != 0)
      selected_data["mem_pct", ] <- selected_data["mem_pct", ] * 100 / mem_allocs

  color_scheme <- c("blue", "purple")
  barplot(as.matrix(selected_data), beside = TRUE, horiz = TRUE,
	  main = "Resource Usage", xlab = "Percentage (%)", ylab = "Functions Executed:",
	  legend.text = c("Time", "Memory"), col = color_scheme, args.legend = list(x = "topright", fill = color_scheme))
}

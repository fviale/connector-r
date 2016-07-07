
formatted_date <- function(datetime) {
  return (J("org.ow2.proactive.utils.Tools")$getFormattedDate(.jlong(datetime)))
}

formatted_duration <- function(start, end) {
  return (J("org.ow2.proactive.utils.Tools")$getFormattedDuration(.jlong(start), .jlong(end)))
}

get_job_data <- function (job.infos) {
  return (
    sapply(job.infos, function(job.info) {
      id <- job.info$getJobId()$value()
      name <- job.info$getJobId()$getReadableName()
      owner <- job.info$getJobOwner()
      priority <- job.info$getPriority()$name()
      status <- job.info$getStatus()$name()
      start.time <- job.info$getStartTime()
      start.at <- formatted_date(start.time)
      finished.time <- job.info$getFinishedTime()
      duration <- formatted_duration(start.time, finished.time)
      return (list(
        id = id, name = name, owner = owner, priotiry = priority, 
        status = status, start.at = start.at, duration = duration))
    })
  )
}
print_job_data <- function(job.data)  {
  matrix <- matrix(unlist(job.data), nrow = length(job.data) / 7, byrow = T)
  write.table(matrix, "", quote = F, row.name = F, col.names = 
                c("ID", "NAME", "OWNER", "PRIORITY", "STATUS", "START_AT", 
                  "DURATION"))
}


#' Display the list of jobs in the scheduler wether pending, running or finished
#' 
#' \code{PAState} display the current state of the scheduler with a list of jobs
#' 
#' @param client connection handle to the scheduler, if not provided the handle created by the last call to PAConnect will be used
#' @seealso \code{\link{PAConnect}}
#' @export
PAState <- function(client = PAClient()) {
  
  if (client == NULL || is.jnull(client) ) {
    stop("You are not currently connected to the scheduler, use PAConnect")
  } 
  
  
  job.infos <- j_try_catch ({
    jobs <- J(client,"getJobs", as.integer(0), as.integer(-1), NULL, NULL)
    return (jobs$getList());
  })
  job.data <- get_job_data(job.infos)
  print_job_data(job.data)
}



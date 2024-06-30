# utils #


# cli messages
error <- function(message) {
  cli::cli_abort(cli::col_red(message))
  invisible(NULL)
}

alert <- function(message) {
  cli::cli_alert(cli::col_blue(message))
  invisible(NULL)
}

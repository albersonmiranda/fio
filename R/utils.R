# utils #


# cli messages
error <- function(message) {
  cli::cli_abort(cli::col_red(message))
}

alert <- function(message) {
  cli::cli_alert(cli::col_blue(deparse(message)))
}

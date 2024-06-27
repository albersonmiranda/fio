# utils #


# cli messages
error <- function(say) {
  cli::cli_abort(cli::col_red(say))
}
alert <- function(say) {
  cli::cli_alert(cli::col_blue(say))
}

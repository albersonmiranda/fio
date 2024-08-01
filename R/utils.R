# utils #


# cli messages
error <- function(message) {
  cli::cli_abort(cli::col_red(message))
}

alert <- function(message) {
  cli::cli_alert(cli::col_blue(message))
}

# get variable from current environment only, without parent environments
get_var <- function(var_name) {
  get(var_name, envir = parent.frame())
}
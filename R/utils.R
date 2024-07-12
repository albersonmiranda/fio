# utils #


# cli messages
error <- function(message) {
  cli::cli_abort(cli::col_red(message))
}

alert <- function(message) {
  cli::cli_alert(cli::col_blue(deparse(message)))
}

# disable parallelism on CRAN
# nocov start
.onAttach <- function(libname, pkgname) {
  if (Sys.getenv("_R_CHECK_LIMIT_CORES_") != "") {
    if (as.logical(Sys.getenv("_R_CHECK_LIMIT_CORES_"))) {
      packageStartupMessage("_R_CHECK_LIMIT_CORES_ is set to TRUE. Running on 2 cores")
      Sys.setenv("RAYON_NUM_THREADS" = 2)
    }
  }
}
# nocov end
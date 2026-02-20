#' @title Download WIOD tables
#' @description Downloads World Input-Output Database tables.
#'
#' @details
#' Multi-region input-output tables from the World Input-Output Database
#' (WIOD) from University of Groningen, Netherlands.
#'
#' @param year (`string`)\cr
#'   Release year from WIOD. One of "2016", "2013" or "long-run".
#'   Defaults to "2016".
#' @param out_dir (`string`)\cr
#'   Path to download. Defaults to current working directory.
#'
#' @return
#'   Invisibly returns the path to the downloaded file.
#'
#' @examples
#' \dontrun{
#' file_path <- tempfile()
#' fio::download_wiod("2016", file_path)
#' }
#' @export
download_wiod <- function(year = "2016", out_dir = tempdir()) {
  valid_years <- c("2016", "2013", "long-run")
  if (!year %in% valid_years) {
    stop("year must be one of 2016, 2013 or long-run")
  }

  file_id <- switch(year,
    "2016" = "199101",
    "2013" = "199123",
    "long-run" = "268666"
  )

  url <- paste0("https://dataverse.nl/api/access/datafile/", file_id, "/")
  out_path <- file.path(out_dir, paste0(year, ".zip"))

  message("Downloading WIOD data for year ", year, "...")
  utils::download.file(url, out_path, mode = "wb", quiet = FALSE)
  message("File successfully saved to: ", out_path)

  invisible(out_path)
}

#' @title
#' Import IOM data
#' @description
#' Import data from a input-output matrix (IOM) from Excel format.
#' @param file
#' Path to the Excel file.
#' @param sheet
#' Name of the sheet in the Excel file.
#' @param range
#' Range of cells in the Excel file.
#' @param col_names
#' Range of cells with column names.
#' @param row_names
#' Range of cells with row names.
#' @return
#' A matrix with row and column names.
#' @examples
#' \dontrun{
#' z = import_element(
#'  file = "MIP-BR (2020).xlsx",
#'  sheet = "MIP",
#'  range = "D6:BB56",
#'  col_names = "D4:BB4",
#'  row_names = "D4:BB4"
#' )
#' }
#' @export

import_element = function(file, sheet, range, col_names = FALSE, row_names = FALSE) {

  if (col_names == FALSE) {
    col_names = NULL
  } else {
    col_names = readxl::read_excel(file, sheet = sheet, range = col_names, col_names = FALSE) |>
      suppressMessages() |>
      as.character()
  }

  if (row_names == FALSE) {
    row_names = NULL
  } else {
    row_names = readxl::read_excel(file, sheet = sheet, range = row_names, col_names = FALSE) |>
      suppressMessages() |>
      as.character()
  }

  data = readxl::read_excel(file, sheet = sheet, range = range, col_names = FALSE) |>
    suppressMessages()

  # convert to matrix
  data = as.matrix(data)
  dimnames(data) = list(row_names, col_names)

  return(data)
}

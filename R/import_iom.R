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
#'  intermediate_transactions = import_element(
#'    file = "path/to/file.xlsx",
#'    sheet = "sheet_name",
#'    range = "B2:Z56",
#'    col_names = "B2:Z2",
#'    row_names = "A2:A56"
#'  )
#' }
#' @export

import_element = function(file, sheet, range, col_names = FALSE, row_names = FALSE) {

  if (col_names == FALSE) {
    col_names = NULL
  } else {
    col_names = readxl::read_excel(file, sheet = sheet, range = col_names, col_names = FALSE) |>
      suppressMessages()
  }

  if (row_names == FALSE) {
    row_names = NULL
  } else {
    row_names = readxl::read_excel(file, sheet = sheet, range = row_names, col_names = FALSE) |>
      suppressMessages()
  }

  data = readxl::read_excel(file, sheet = sheet, range = range, col_names = FALSE) |>
    suppressMessages() |>
    as.data.frame()

  rownames(data) = row_names[[1]]
  colnames(data) = as.character(col_names)

  # convert to matrix
  data = as.matrix(data)

  return(data)
}

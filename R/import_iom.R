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
#' A (`matrix`).
#' @examples
#' # Excel file with IOM data
#' path_to_xlsx <- system.file("extdata", "iom/br/2020.xlsx", package = "fio")
#' # Import IOM data
#' intermediate_transactions = import_element(
#'   file = path_to_xlsx,
#'   sheet = "MIP",
#'   range = "D6:BB56",
#'   col_names = "D4:BB4",
#'   row_names = "B6:B56"
#' )
#' # Show the first 6 rows and 6 columns
#' intermediate_transactions[1:6, 1:6]
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

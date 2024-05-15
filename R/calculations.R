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

tecnical_coef = function(data) {
  A = with(data, Z %*% diag(1 / as.vector(x)))

  return(A)
}

#' @export
leontief_inverse = function(A) {
  I = diag(nrow(A))
  B = solve(I - A)

  return(B)
}
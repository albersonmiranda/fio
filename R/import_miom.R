#' @title
#' Import Multi-Regional IOM data
#' @description
#' Import data from a multi-regional input-output matrix (MIOM) from Excel format.
#' This function handles the complex structure of multi-regional IOMs where countries
#' and sectors are organized in blocks.
#' @param file
#' Path to the Excel file.
#' @param sheet
#' Name of the sheet in the Excel file.
#' @param countries_range
#' Range of cells with country names.
#' @param sectors_range
#' Range of cells with sector names.
#' @param intermediate_transactions_range
#' Range of cells with the intermediate transactions matrix.
#' @param total_production_range
#' Range of cells with total production data.
#' @param final_demand_range
#' Range of cells with final demand data.
#' @param final_demand_names_range
#' Range of cells with final demand category names.
#' @param value_added_others_range
#' Range of cells with other value added components.
#' @param taxes_range
#' Range of cells with taxes data.
#' @param wages_range
#' Range of cells with wages data (optional).
#' @param operating_income_range
#' Range of cells with operating income data (optional).
#' @return
#' A list containing all imported matrices and metadata for creating a miom object.
#' @examples
#' # Excel file with multi-regional IOM data
#' path_to_xlsx <- system.file("extdata", "iom/world/2000.xlsx", package = "fio")
#'
#' # Import basic multi-regional IOM data (intermediate transactions + total production)
#' miom_basic <- import_miom(
#'   file = path_to_xlsx,
#'   sheet = "2000",
#'   countries_range = "C7:C604",
#'   sectors_range = "B7:B29",
#'   intermediate_transactions_range = "E7:WD604",
#'   total_production_range = "E612:WD612"
#' )
#'
#' # Create a MIOM object
#' world_miom <- miom$new(
#'   id = "world_2000",
#'   intermediate_transactions = miom_basic$intermediate_transactions,
#'   total_production = miom_basic$total_production,
#'   countries = miom_basic$countries,
#'   sectors = miom_basic$sectors
#' )
#'
#' # Import complete multi-regional IOM data with all optional components
#' miom_complete <- import_miom(
#'   file = path_to_xlsx,
#'   sheet = "2000",
#'   countries_range = "C7:C604",
#'   sectors_range = "B7:B29",
#'   intermediate_transactions_range = "E7:WD604",
#'   total_production_range = "E612:WD612",
#'   final_demand_range = "WF7:AAE604",
#'   final_demand_names_range = "WF5:WI5",
#'   value_added_others_range = "E606:WD606",
#'   taxes_range = "E607:WD607"
#' )
#' @export

import_miom <- function(file,
                        sheet,
                        countries_range,
                        sectors_range,
                        intermediate_transactions_range,
                        total_production_range,
                        final_demand_range = NULL,
                        final_demand_names_range = NULL,
                        value_added_others_range = NULL,
                        taxes_range = NULL,
                        wages_range = NULL,
                        operating_income_range = NULL) {
  # Import basic structure
  countries <- import_element(
    file = file,
    sheet = sheet,
    range = countries_range
  ) |>
    na.omit()

  sectors <- import_element(
    file = file,
    sheet = sheet,
    range = sectors_range
  )

  # Import core matrices
  intermediate_transactions <- import_element(
    file = file,
    sheet = sheet,
    range = intermediate_transactions_range
  )

  total_production <- import_element(
    file = file,
    sheet = sheet,
    range = total_production_range
  )

  # Prepare labels
  n_countries <- length(countries)
  n_sectors <- nrow(sectors)

  # Create intermediate transactions labels
  intermediate_transactions_labels <- c()
  for (i in seq_len(n_countries)) {
    country <- countries[i]
    for (j in seq_len(n_sectors)) {
      sector <- sectors[j, 1]
      index <- (i - 1) * n_sectors + j
      intermediate_transactions_labels[index] <- paste(country, sector, sep = "_")
    }
  }

  # Apply labels to intermediate transactions
  rownames(intermediate_transactions) <- intermediate_transactions_labels
  colnames(intermediate_transactions) <- intermediate_transactions_labels

  # Convert total production to matrix and apply labels
  total_production <- matrix(total_production, nrow = 1)
  colnames(total_production) <- intermediate_transactions_labels

  # Initialize result list
  result <- list(
    countries = countries,
    sectors = sectors[, 1],
    intermediate_transactions = intermediate_transactions,
    total_production = total_production,
    n_countries = n_countries,
    n_sectors = n_sectors
  )

  # Import optional matrices
  if (!is.null(final_demand_range)) {
    final_demand <- import_element(
      file = file,
      sheet = sheet,
      range = final_demand_range
    )

    # Apply row labels to final demand
    rownames(final_demand) <- intermediate_transactions_labels

    # Get final demand names if provided
    if (!is.null(final_demand_names_range)) {
      final_demand_names <- import_element(
        file = file,
        sheet = sheet,
        range = final_demand_names_range
      )

      # Create column names: each country gets each final demand category
      final_demand_col_names <- c()
      for (i in seq_len(n_countries)) {
        country <- countries[i]
        for (j in seq_len(ncol(final_demand_names))) {
          category <- as.character(final_demand_names)[j]
          final_demand_col_names <- c(final_demand_col_names, paste(country, category, sep = "_"))
        }
      }
      colnames(final_demand) <- final_demand_col_names
    }

    result$final_demand <- final_demand
  }

  if (!is.null(value_added_others_range)) {
    value_added_others <- import_element(
      file = file,
      sheet = sheet,
      range = value_added_others_range
    )
    names(value_added_others) <- intermediate_transactions_labels
    result$value_added_others <- as.vector(value_added_others)
  }

  if (!is.null(taxes_range)) {
    taxes <- import_element(
      file = file,
      sheet = sheet,
      range = taxes_range
    )
    names(taxes) <- intermediate_transactions_labels
    result$taxes <- as.vector(taxes)
  }

  if (!is.null(wages_range)) {
    wages <- import_element(
      file = file,
      sheet = sheet,
      range = wages_range
    )
    names(wages) <- intermediate_transactions_labels
    result$wages <- as.vector(wages)
  }

  if (!is.null(operating_income_range)) {
    operating_income <- import_element(
      file = file,
      sheet = sheet,
      range = operating_income_range
    )
    names(operating_income) <- intermediate_transactions_labels
    result$operating_income <- as.vector(operating_income)
  }

  return(result)
}

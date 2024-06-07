#' @title
#' R6 class for input-output matrix
#' @description
#' R6 class for input-output matrix.
#' @param id
#' Identifier for the input-output matrix.
#' @param intermediate_transactions
#' Intermediate transactions matrix.
#' @param total_production
#' Total production matrix.
#' @param final_demand
#' Final demand matrix.
#' @param exports
#' Exports matrix.
#' @param imports
#' Imports matrix.
#' @param taxes
#' Taxes matrix.
#' @param wages
#' Wages matrix.
#' @param operating_income
#' Operating income matrix.
#' @param added_value_final_demand
#' Value added final demand matrix.
#' @param added_value
#' Value added matrix.
#' @param occupation
#' Occupation matrix.
#' @param technical_coefficients_matrix
#' Technical coefficients matrix.
#' @param leontief_inverse_matrix
#' Leontief inverse matrix.
#' @param multiplier_output
#' Output multipler vector.
#' @export

# input-output matrix class
iom <- R6::R6Class(
  classname = "iom",
  public = list(
    # data members
    #' @field id
    #' Identifier of the new instance
    id = NULL,

    #' @field intermediate_transactions
    #' Intermediate transactions matrix.
    intermediate_transactions = NULL,

    #' @field total_production
    #' Total production matrix.
    total_production = NULL,

    #' @field final_demand
    #' Final demand matrix.
    final_demand = NULL,

    #' @field exports
    #' Exports matrix.
    exports = NULL,

    #' @field imports
    #' Imports matrix.
    imports = NULL,

    #' @field taxes
    #' Taxes matrix.
    taxes = NULL,

    #' @field wages
    #' Wages matrix.
    wages = NULL,

    #' @field operating_income
    #' Operating income matrix.
    operating_income = NULL,

    #' @field added_value_final_demand
    #' Value added final demand matrix.
    added_value_final_demand = NULL,

    #' @field added_value
    #' Value added matrix.
    added_value = NULL,

    #' @field occupation
    #' Occupation vector
    occupation = NULL,

    #' @field technical_coefficients_matrix
    #' Technical coefficients matrix.
    technical_coefficients_matrix = NULL,

    #' @field leontief_inverse_matrix
    #' Leontief inverse matrix.
    leontief_inverse_matrix = NULL,

    #' @field multiplier_output
    #' Output multiplier vector.
    multiplier_output = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(id,
                          intermediate_transactions,
                          total_production,
                          final_demand = NULL,
                          exports = NULL,
                          imports = NULL,
                          taxes = NULL,
                          wages = NULL,
                          operating_income = NULL,
                          added_value_final_demand = NULL,
                          added_value = NULL,
                          occupation = NULL,
                          technical_coefficients_matrix = NULL,
                          leontief_inverse_matrix = NULL,
                          multiplier_output = NULL) {
      self$id <- id
      self$intermediate_transactions <- intermediate_transactions
      self$total_production <- total_production
      self$final_demand <- final_demand
      self$exports <- exports
      self$imports <- imports
      self$taxes <- taxes
      self$wages <- wages
      self$operating_income <- operating_income
      self$added_value_final_demand <- added_value_final_demand
      self$added_value <- added_value
      self$occupation <- occupation
      self$technical_coefficients_matrix <- technical_coefficients_matrix
      self$leontief_inverse_matrix <- leontief_inverse_matrix
      self$multiplier_output <- multiplier_output
    },

    #' @description
    #' Adds a matrix to a previously imported IO matrix.
    #' @param matrix_name
    #' One of final_demand, exports, imports, added_value_final_demand, added_value or occupation matrix to be added.
    #' @param matrix
    #' Matrix object to be added.
    add = function(matrix_name, matrix) {
      # check arg
      choices <- iom_elements()
      tryCatch(
        match.arg(matrix_name, choices),
        error = function(e) {
          stop("matrix_name must be one of ", paste(choices, collapse = ", "))
        }
      )
      # import matrix
      self[[matrix_name]] <- matrix
      invisible(self)
    },

    #' @description
    #' Removes a matrix from a previously imported IO matrix.
    #' @param matrix_name
    #' One of final_demand, exports, imports, added_value_final_demand, added_value or occupation matrix to be removed.
    #' @param matrix
    #' Matrix object to be removed.
    remove = function(matrix_name) {
      # check arg
      choices <- iom_elements()
      tryCatch(
        match.arg(matrix_name, choices),
        error = function(e) {
          stop("matrix_name must be one of ", paste(choices, collapse = ", "))
        }
      )
      # remove matrix
      self[[matrix_name]] <- NULL
      invisible(self)
    },

    #' @description
    #' Computes the technical coefficients matrix.
    compute_tech_coeff = function() {
      # save row and column names
      row_names <- rownames(self$intermediate_transactions)
      col_names <- colnames(self$intermediate_transactions)
      # calculate technical coefficients matrix
      technical_coefficients_matrix <- compute_tech_coeff(
        intermediate_transactions = self$intermediate_transactions,
        total_production = self$total_production
      )
      # set row and column names
      rownames(technical_coefficients_matrix) <- row_names
      colnames(technical_coefficients_matrix) <- col_names

      # store matrix
      self$technical_coefficients_matrix <- technical_coefficients_matrix
      invisible(self)
    },

    #' @description
    #' Computes the Leontief inverse matrix.
    #' @param technical_coefficients_matrix
    #' Technical coefficients matrix.
    compute_leontief_inverse = function(technical_coefficients_matrix) {
      # save row and column names
      row_names <- rownames(self$technical_coefficients_matrix)
      col_names <- colnames(self$technical_coefficients_matrix)
      # computes leontief inverse matrix
      leontief_inverse_matrix <- compute_leontief_inverse(
        tech_coeff = self$technical_coefficients_matrix
      )
      # set row and column names
      rownames(leontief_inverse_matrix) <- row_names
      colnames(leontief_inverse_matrix) <- col_names

      # store matrix
      self$leontief_inverse_matrix <- leontief_inverse_matrix
      invisible(self)
    },

    #' @description
    #' Computes the output multiplier vector.
    #' @param leontief_inverse_matrix
    #' Leontief inverse matrix.
    compute_multiplier_output = function(leontief_inverse_matrix) {
      # save column names
      col_names <- colnames(self$leontief_inverse_matrix)
      # compute output multiplier vector
      multiplier_output <- compute_multiplier_output(
        leontief_inverse_matrix = self$leontief_inverse_matrix
      )
      # set column names
      names(multiplier_output) <- col_names

      # store vector
      self$multiplier_output <- multiplier_output
      invisible(self)
    }
  )
)

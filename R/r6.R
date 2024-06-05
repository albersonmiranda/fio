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
#' @param tecnical_coefficients_matrix
#' Tecnical coefficients matrix.
#' @param leontief_inverse_matrix
#' Leontief inverse matrix.
#' @export

# input-output matrix class
iom <- R6::R6Class(
  classname = "iom",
  public = list(
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

    #' @field tecnical_coefficients_matrix
    #' Tecnical coefficients matrix.
    tecnical_coefficients_matrix = NULL,

    #' @field leontief_inverse_matrix
    #' Leontief inverse matrix.
    leontief_inverse_matrix = NULL,

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
                          tecnical_coefficients_matrix = NULL,
                          leontief_inverse_matrix = NULL) {
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
      self$tecnical_coefficients_matrix <- tecnical_coefficients_matrix
      self$leontief_inverse_matrix <- leontief_inverse_matrix
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
    #' Calculate the tecnical coefficients matrix.
    tec_coeff = function() {
      # save row and column names
      row_names <- rownames(self$intermediate_transactions)
      col_names <- colnames(self$intermediate_transactions)
      # calculate tecnical coefficients matrix
      tecnical_coefficients_matrix <- tec_coeff(
        intermediate_transactions = self$intermediate_transactions,
        total_production = self$total_production
      )
      # set row and column names
      rownames(tecnical_coefficients_matrix) <- row_names
      colnames(tecnical_coefficients_matrix) <- col_names

      # store matrix
      self$tecnical_coefficients_matrix <- tecnical_coefficients_matrix
      invisible(self)
    },

    #' @description
    #' Calculate the Leontief inverse matrix.
    #' @param tecnical_coefficients_matrix
    #' Tecnical coefficients matrix.
    leontief_inverse = function(tecnical_coefficients_matrix) {
      # save row and column names
      row_names <- rownames(self$tecnical_coefficients_matrix)
      col_names <- colnames(self$tecnical_coefficients_matrix)
      # calculate leontief inverse matrix
      leontief_inverse_matrix <- leontief_inverse(
        tec_coeff = self$tecnical_coefficients_matrix
      )
      # set row and column names
      rownames(leontief_inverse_matrix) <- row_names
      colnames(leontief_inverse_matrix) <- col_names

      # store matrix
      self$leontief_inverse_matrix <- leontief_inverse_matrix
      invisible(self)
    }
  )
)

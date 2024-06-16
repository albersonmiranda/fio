#' @title
#' R6 class for input-output matrix
#' @description
#' R6 class for input-output matrix.
#' @param id
#' Identifier for the input-output matrix.
#' @param intermediate_transactions
#' Intermediate transactions matrix.
#' @param total_production
#' Total production vector.
#' @param final_demand
#' Final demand matrix.
#' @param exports
#' Exports vector.
#' @param imports
#' Imports vector.
#' @param taxes
#' Taxes vector.
#' @param wages
#' Wages vector.
#' @param operating_income
#' Operating income vector.
#' @param added_value_final_demand
#' Added value final demand matrix.
#' @param added_value
#' Added value vector.
#' @param occupation
#' Occupation matrix.
#' @param technical_coefficients_matrix
#' Technical coefficients matrix.
#' @param leontief_inverse_matrix
#' Leontief inverse matrix.
#' @param multiplier_output
#' Output multiplier vector.
#' @param field_influence
#' Influence field matrix.
#' @param key_sectors
#' Key sectors dataframe.
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
    #' Total production vector.
    total_production = NULL,

    #' @field final_demand
    #' Final demand matrix.
    final_demand = NULL,

    #' @field exports
    #' Exports vector.
    exports = NULL,

    #' @field imports
    #' Imports vector.
    imports = NULL,

    #' @field taxes
    #' Taxes vector.
    taxes = NULL,

    #' @field wages
    #' Wages vector.
    wages = NULL,

    #' @field operating_income
    #' Operating income vector.
    operating_income = NULL,

    #' @field added_value_final_demand
    #' Added value final demand matrix.
    added_value_final_demand = NULL,

    #' @field added_value
    #' Added value vector.
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

    #' @field field_influence
    #' Influence field matrix.
    field_influence = NULL,

    #' @field key_sectors
    #' Key sectors dataframe.
    key_sectors = NULL,

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
                          multiplier_output = NULL,
                          field_influence = NULL,
                          key_sectors = NULL) {
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
      self$field_influence <- field_influence
      self$key_sectors <- key_sectors
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
      row_names <- if (is.null(rownames(self$intermediate_transactions))) {
        seq_len(nrow(self$intermediate_transactions))
      } else {
        rownames(self$intermediate_transactions)
      }
      col_names <- if (is.null(colnames(self$intermediate_transactions))) {
        seq_len(ncol(self$intermediate_transactions))
      } else {
        colnames(self$intermediate_transactions)
      }
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
      ) |>
        matrix(nrow = 1)
      # set column names
      colnames(multiplier_output) <- col_names

      # store vector
      self$multiplier_output <- multiplier_output
      invisible(self)
    },

    #' @description
    #' Computes the influence field matrix.
    #' @param technical_coefficients_matrix
    #' Technical coefficients matrix.
    #' @param leontief_inverse_matrix
    #' Leontief inverse matrix.
    #' @param epsilon
    #' Epsilon value. A technical change in the input-output matrix.
    compute_field_influence = function(epsilon) {
      # save row and column names
      row_names <- rownames(self$technical_coefficients_matrix)
      col_names <- colnames(self$technical_coefficients_matrix)
      # compute influence field matrix
      field_influence <- compute_field_influence(
        tech_coeff = self$technical_coefficients_matrix,
        leontief_inverse_matrix = self$leontief_inverse_matrix,
        epsilon = epsilon
      )
      # set row and column names
      rownames(field_influence) <- row_names
      colnames(field_influence) <- col_names

      # store matrix
      self$field_influence <- field_influence
      invisible(self)
    },

    #' @description
    #' Computes the key sectors dataframe.
    #' @param leontief_inverse_matrix
    #' Leontief inverse matrix.
    compute_key_sectors = function(leontief_inverse_matrix) {
      # power of dispersion
      power_dispersion <- compute_power_dispersion(
        leontief_inverse_matrix = self$leontief_inverse_matrix
      )
      # sensitivity of dispersion
      sensitivity_dispersion <- compute_sensitivity_dispersion(
        leontief_inverse_matrix = self$leontief_inverse_matrix
      )
      # power of dispersion coefficients of variation
      power_dispersion_cv <- compute_power_dispersion_cv(
        leontief_inverse_matrix = self$leontief_inverse_matrix
      )
      # sensitivity of dispersion coefficients of variation
      sensitivity_dispersion_cv <- compute_sensitivity_dispersion_cv(
        leontief_inverse_matrix = self$leontief_inverse_matrix
      )
      # compute key sectors dataframe
      key_sectors <- data.frame(
        sector = rownames(self$leontief_inverse_matrix),
        power_dispersion = power_dispersion,
        sensitivity_dispersion = sensitivity_dispersion,
        power_dispersion_cv = power_dispersion_cv,
        sensitivity_dispersion_cv = sensitivity_dispersion_cv
      ) |>
        within({
          key_sectors <- ifelse(sensitivity_dispersion <= 1 & power_dispersion <= 1, "Non-Key Sector", "")
          key_sectors <- ifelse(sensitivity_dispersion > 1 & power_dispersion > 1, "Key Sector", key_sectors)
          key_sectors <- ifelse(sensitivity_dispersion > 1 & power_dispersion <= 1, "Strong Forward Linkage", key_sectors) # nolint
          key_sectors <- ifelse(sensitivity_dispersion <= 1 & power_dispersion > 1, "Strong Backward Linkage", key_sectors) # nolint
        })
      # store dataframe
      self$key_sectors <- key_sectors
      invisible(self)
    }
  )
)

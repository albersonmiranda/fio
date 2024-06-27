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
#' @param household_consumption
#' Household consumption vector.
#' @param government_consumption
#' Government consumption vector.
#' @param exports
#' Exports vector.
#' @param final_demand_others
#' Other vectors of final demand that doesn't have dedicated slots.
#' Setting column names is advised for better readability.
#' @param imports
#' Imports vector.
#' @param taxes
#' Taxes vector.
#' @param wages
#' Wages vector.
#' @param operating_income
#' Operating income vector.
#' @param added_value_others
#' Other vectors of added value that doesn't have dedicated slots.
#' Setting row names is advised for better readability.
#' @param occupation
#' Occupation matrix.
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

    #' @field household_consumption
    #' Household consumption vector.
    household_consumption = NULL,

    #' @field government_consumption
    #' Government consumption vector.
    government_consumption = NULL,

    #' @field exports
    #' Exports vector.
    exports = NULL,

    #' @field final_demand_others
    #' Other vectors of final demand that doesn't have dedicated slots.
    final_demand_others = NULL,

    #' @field final_demand_matrix
    #' Aggregates final demand vectors into a matrix.
    final_demand_matrix = NULL,

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

    #' @field added_value_others
    #' Other vectors of added value that doesn't have dedicated slots.
    added_value_others = NULL,

    #' @field added_value_matrix
    #' Aggregates added value vectors into a matrix.
    added_value_matrix = NULL,

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

    #' @field allocation_coefficients_matrix
    #' Allocation coefficients matrix.
    allocation_coefficients_matrix = NULL,

    #' @field ghosh_inverse_matrix
    #' Ghosh inverse matrix.
    ghosh_inverse_matrix = NULL,

    #' @field hypothetical_extraction
    #' Absolute and relative backward and forward differences in total output after a hypothetical extraction.
    hypothetical_extraction = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(id,
                          intermediate_transactions,
                          total_production,
                          household_consumption = NULL,
                          government_consumption = NULL,
                          exports = NULL,
                          final_demand_others = NULL,
                          imports = NULL,
                          taxes = NULL,
                          wages = NULL,
                          operating_income = NULL,
                          added_value_others = NULL,
                          occupation = NULL) {
      ### assertions ###
      # check class
      for (matrix in private$iom_elements()) {
        if (!is.null(get(matrix)) && !is.matrix(get(matrix))) {
          cli::cli_h1("Error in matrix class")
          alert("Try coerce `{matrix}` to a matrix using as.matrix() function.")
          error("`{matrix}` must be a matrix.")
        }
      }

      # check dimensions
      if (nrow(intermediate_transactions) != ncol(intermediate_transactions)) {
        cli::cli_h1("Error in matrix dimensions")
        error("intermediate_transactions must be a square matrix")
      }

      for (matrix in c(
        "household_consumption",
        "government_consumption",
        "exports",
        "final_demand_others"
      )) {
        if (!is.null(get(matrix)) && nrow(get(matrix)) != nrow(intermediate_transactions)) {
          cli::cli_h1("Error in matrix dimensions")
          error("`{matrix}` must have the same number of rows than `intermediate_transactions`,
          which is {nrow(intermediate_transactions)} rows. But `{matrix}` has {nrow(get(matrix))} rows.")
        }
      }

      for (matrix in c(
        "imports",
        "taxes",
        "wages",
        "operating_income",
        "added_value_others",
        "occupation",
        "total_production"
      )) {
        if (!is.null(get(matrix)) && ncol(get(matrix)) != ncol(intermediate_transactions)) {
          cli::cli_h1("Error in matrix dimensions")
          error("`{matrix}` must have the same number of columns than `intermediate_transactions`,
          which is {ncol(intermediate_transactions)} columns. But `{matrix}` has {ncol(get(matrix))} columns.")
        }
      }

      # check number format
      for (matrix in private$iom_elements()) {
        if (!is.null(get(matrix))) {
          # Check if the matrix storage mode is not double
          if (storage.mode(get(matrix)) != "double") {
            cli::cli_h1("Error in matrix number format")
            alert("Try coerce {matrix} elements to double using as.numeric().")
            error("{matrix} elements must be of type double.")
          }
        }
      }

      # set data members
      self$id <- id
      self$intermediate_transactions <- intermediate_transactions
      self$total_production <- total_production
      self$household_consumption <- set_colnames(household_consumption)
      self$government_consumption <- set_colnames(government_consumption)
      self$exports <- set_colnames(exports)
      self$final_demand_others <- final_demand_others
      self$imports <- set_rownames(imports)
      self$taxes <- set_rownames(taxes)
      self$wages <- set_rownames(wages)
      self$operating_income <- set_rownames(operating_income)
      self$added_value_others <- added_value_others
      self$occupation <- set_rownames(occupation)
    },

    #' @description
    #' Adds a matrix to a previously imported IO matrix.
    #' @param matrix_name
    #' One of household_consumption, government_consumption, exports, final_demand_others,
    #' imports, taxes, wages, operating income, added_value_others or occupation matrix to be added.
    #' @param matrix
    #' Matrix object to be added.
    add = function(matrix_name, matrix) {
      # check arg
      choices <- private$iom_elements
      tryCatch(
        match.arg(matrix_name, choices),
        error = function(e) {
          cli::cli_h1("Error in matrix_name")
          error("matrix_name must be one of {choices}")
        }
      )
      # check class
      if (!is.matrix(matrix)) {
        cli::cli_h1("Error in matrix class")
        alert("Try coerce `matrix` to a matrix using as.matrix() function.")
        error("`matrix` must be a matrix.")
      }
      # check dimensions
      if (matrix_name %in% c("household_consumption", "government_consumption", "exports", "final_demand_others")) {
        if (nrow(matrix) != nrow(self$intermediate_transactions)) {
          cli::cli_h1("Error in matrix dimensions")
          error("`{matrix_name}` must have the same number of rows than `intermediate_transactions`,
          which is {nrow(self$intermediate_transactions)} rows. But {matrix_name} has {nrow(matrix)} rows.")
        }
      } else {
        if (ncol(matrix) != ncol(self$intermediate_transactions)) {
          cli::cli_h1("Error in matrix dimensions")
          error("`{matrix_name}` must have the same number of columns than `intermediate_transactions`,
          which is {ncol(self$intermediate_transactions)} columns. But {matrix_name} has {ncol(matrix)} columns.")
        }
      }
      # import matrix
      self[[matrix_name]] <- matrix
      invisible(self)
    },

    #' @description
    #' Removes a matrix from a previously imported IO matrix.
    #' @param matrix_name
    #' One of household_consumption, government_consumption, exports, final_demand_others,
    #' imports, taxes, wages, operating income, added_value_others or occupation matrix to be removed.
    #' @param matrix
    #' Matrix object to be removed.
    remove = function(matrix_name) {
      # check arg
      choices <- private$iom_elements
      tryCatch(
        match.arg(matrix_name, choices),
        error = function(e) {
          cli::cli_h1("Error in matrix_name")
          error("matrix_name must be one of {choices}")
        }
      )
      # remove matrix
      self[[matrix_name]] <- NULL
      invisible(self)
    },

    #' @description
    #' Updates final demand matrix.
    update_final_demand_matrix = function() {
      # bind final demand vectors
      self$final_demand_matrix <- as.matrix(cbind(
        self$household_consumption,
        self$government_consumption,
        self$exports,
        self$final_demand_others
      ))
    },

    #' @description
    #' Updates added value matrix.
    update_added_value_matrix = function() {
      # bind added value vectors
      self$added_value_matrix <- as.matrix(rbind(
        self$imports,
        self$taxes,
        self$wages,
        self$operating_income,
        self$added_value_others
      ))
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
      # check if technical coefficients matrix is available
      if (is.null(self$technical_coefficients_matrix)) {
        cli::cli_h1("Error in technical_coefficients_matrix")
        error("You must compute the technical coefficients matrix first. Run compute_tech_coeff() method.")
      }
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
      # check if leontief inverse matrix is available
      if (is.null(self$leontief_inverse_matrix)) {
        cli::cli_h1("Error in leontief_inverse_matrix")
        error("You must compute the leontief inverse matrix first. Run compute_leontief_inverse() method.")
      }
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
      # check if epsilon was set
      if (missing(epsilon)) {
        cli::cli_h1("Error in epsilon")
        error("You must set the epsilon value.")
      }
      # check if leontief inverse matrix is available
      if (is.null(self$leontief_inverse_matrix)) {
        cli::cli_h1("Error in leontief_inverse_matrix")
        error("You must compute the leontief inverse matrix first. Run compute_leontief_inverse() method.")
      }
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
      # check if leontief inverse matrix is available
      if (is.null(self$leontief_inverse_matrix)) {
        cli::cli_h1("Error in leontief_inverse_matrix")
        error("You must compute the leontief inverse matrix first. Run compute_leontief_inverse() method.")
      }
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
    },

    #' @description
    #' Computes the allocation coefficients matrix.
    #' @param intermediate_transactions
    #' Intermediate transactions matrix.
    #' @param total_production
    #' Total production vector.
    compute_allocation_coeff = function() {
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
      # compute allocation coefficients matrix
      allocation_coefficients_matrix <- compute_allocation_coeff(
        intermediate_transactions = self$intermediate_transactions,
        total_production = self$total_production
      )
      # set row and column names
      rownames(allocation_coefficients_matrix) <- row_names
      colnames(allocation_coefficients_matrix) <- col_names

      # store matrix
      self$allocation_coefficients_matrix <- allocation_coefficients_matrix
      invisible(self)
    },

    #' @description
    #' Computes the Ghosh inverse matrix.
    #' @param allocation_coefficients_matrix
    #' Allocation coefficients matrix.
    compute_ghosh_inverse = function(allocation_coefficients_matrix) {
      # check if allocation coefficients matrix is available
      if (is.null(self$allocation_coefficients_matrix)) {
        cli::cli_h1("Error in allocation_coefficients_matrix")
        error("You must compute the allocation coefficients matrix first. Run compute_allocation_coeff() method.")
      }
      # save row and column names
      row_names <- rownames(self$allocation_coefficients_matrix)
      col_names <- colnames(self$allocation_coefficients_matrix)
      # compute ghosh inverse matrix
      ghosh_inverse_matrix <- compute_ghosh_inverse(
        allocation_coeff = self$allocation_coefficients_matrix
      )
      # set row and column names
      rownames(ghosh_inverse_matrix) <- row_names
      colnames(ghosh_inverse_matrix) <- col_names

      # store matrix
      self$ghosh_inverse_matrix <- ghosh_inverse_matrix
      invisible(self)
    },

    #' @description
    #' Computes the hypothetical extraction.
    #' @param technical_coefficients_matrix
    #' Technical coefficients matrix.
    #' @param allocation_coefficients_matrix
    #' Allocation coefficients matrix.
    #' @param final_demand_matrix
    #' Final demand matrix.
    #' @param added_value_matrix
    #' Added value matrix.
    #' @param total_production
    #' Total production vector.
    compute_hypothetical_extraction = function(technical_coefficients_matrix,
                                               allocation_coefficients_matrix,
                                               final_demand_matrix,
                                               added_value_matrix,
                                               total_production) {
      # check if arguments are available
      for (matrix in c(
        "technical_coefficients_matrix",
        "allocation_coefficients_matrix"
      )) {
        if (is.null(self[[matrix]])) {
          cli::cli_h1("Error in {matrix}")
          error("You must compute the {matrix} first. Run respective compute_*() method.")
        }
      }
      for (matrix in c(
        "final_demand_matrix",
        "added_value_matrix"
      )) {
        if (is.null(self[[matrix]])) {
          cli::cli_h1("Error in {matrix}")
          error("You must compute the {matrix} first. Run respective update_*() method.")
        }
      }
      # save row and column names
      row_names <- rownames(self$technical_coefficients_matrix)
      # compute backward extraction
      extraction_backward <- compute_extraction_backward(
        technical_coefficients_matrix = self$technical_coefficients_matrix,
        final_demand_matrix = self$final_demand_matrix,
        total_production = self$total_production
      )
      # compute forward extraction
      extraction_forward <- compute_extraction_forward(
        allocation_coeff = self$allocation_coefficients_matrix,
        added_value_matrix = self$added_value_matrix,
        total_production = self$total_production
      )
      # compute total extraction
      extraction_total <- compute_extraction_total(
        backward_linkage_matrix = extraction_backward,
        forward_linkage_matrix = extraction_forward
      )
      # bind
      hypothetical_extraction <- cbind(
        extraction_backward,
        extraction_forward,
        extraction_total
      )
      # set row and column names
      rownames(hypothetical_extraction) <- row_names
      colnames(hypothetical_extraction) <- c(
        "backward_absolute",
        "backward_relative",
        "forward_absolute",
        "foward_relative",
        "total_absolute",
        "total_relative"
      )
      # store matrix
      self$hypothetical_extraction <- hypothetical_extraction
      invisible(self)
    }
  ),

  # private members
  private = list(
    iom_elements = function() {
      c(
        "intermediate_transactions",
        "total_production",
        "household_consumption",
        "government_consumption",
        "exports",
        "final_demand_others",
        "imports",
        "taxes",
        "wages",
        "operating_income",
        "added_value_others",
        "occupation"
      )
    }
  )
)

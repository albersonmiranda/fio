#' @title
#' R6 class for input-output matrix
#'
#' @description
#' R6 class for input-output matrix.
#'
#' @param id (`character`)\cr
#' Identifier for the input-output matrix.
#' @param intermediate_transactions (`matrix`)\cr
#' Intermediate transactions matrix.
#' @param total_production (`matrix`)\cr
#' Total production vector.
#' @param household_consumption (`matrix`)\cr
#' Household consumption vector.
#' @param government_consumption (`matrix`)\cr
#' Government consumption vector.
#' @param exports (`matrix`)\cr
#' Exports vector.
#' @param final_demand_others (`matrix`)\cr
#' Other vectors of final demand that doesn't have dedicated slots.
#' Setting column names is advised for better readability.
#' @param imports (`matrix`)\cr
#' Imports vector.
#' @param taxes (`matrix`)\cr
#' Taxes vector.
#' @param wages (`matrix`)\cr
#' Wages vector.
#' @param operating_income (`matrix`)\cr
#' Operating income vector.
#' @param value_added_others (`matrix`)\cr
#' Other vectors of value-added that doesn't have dedicated slots.
#' Setting row names is advised for better readability.
#' @param occupation (`matrix`)\cr
#' Occupation matrix.
#' @param threads (`integer`)\cr
#' Number of threads available for Rust to run in parallel.
#'
#' @return A new instance of the `iom` class.
#'
#' @examples
#' # data
#' intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
#' total_production <- matrix(c(100, 200, 300), 1, 3)
#' exports <- matrix(c(10, 20, 30), 3, 1)
#' households <- matrix(as.numeric(4:6), 3, 1)
#' imports <- matrix(c(5, 10, 15), 1, 3)
#' jobs <- matrix(c(10, 12, 15), 1, 3)
#' taxes <- matrix(c(2, 5, 10), 1, 3)
#' wages <- matrix(c(11, 12, 13), 1, 3)
#'
#' # a new iom instance can be created by passing just intermediate transactions and total production
#' my_iom <- iom$new(
#'  "example_1",
#'  intermediate_transactions,
#'  total_production
#' )
#'
#' # or by passing optional arguments
#' my_iom <- iom$new(
#' "example_2",
#' intermediate_transactions,
#' total_production,
#' household_consumption = households,
#' exports = exports,
#' imports = imports,
#' taxes = taxes,
#' wages = wages,
#' occupation = jobs
#' )
#'
#' @importFrom Rdpack reprompt
#' @import R6
#' @export

# input-output matrix class
iom <- R6Class(
  classname = "iom",
  public = list(
    #' @field id (`character`)\cr
    #' Identifier of the new instance.
    id = NULL,

    #' @field intermediate_transactions (`matrix`)\cr
    #' Intermediate transactions matrix.
    intermediate_transactions = NULL,

    #' @field total_production (`matrix`)\cr
    #' Total production vector.
    total_production = NULL,

    #' @field household_consumption (`matrix`)\cr
    #' Household consumption vector.
    household_consumption = NULL,

    #' @field government_consumption (`matrix`)\cr
    #' Government consumption vector.
    government_consumption = NULL,

    #' @field exports (`matrix`)\cr
    #' Exports vector.
    exports = NULL,

    #' @field final_demand_others (`matrix`)\cr
    #' Other vectors of final demand that doesn't have dedicated slots.
    final_demand_others = NULL,

    #' @field final_demand_matrix (`matrix`)\cr
    #' Aggregates final demand vectors into a matrix.
    final_demand_matrix = NULL,

    #' @field imports (`matrix`)\cr
    #' Imports vector.
    imports = NULL,

    #' @field taxes (`matrix`)\cr
    #' Taxes vector.
    taxes = NULL,

    #' @field wages (`matrix`)\cr
    #' Wages vector.
    wages = NULL,

    #' @field operating_income (`matrix`)\cr
    #' Operating income vector.
    operating_income = NULL,

    #' @field value_added_others (`matrix`)\cr
    #' Other vectors of value-added that doesn't have dedicated slots.
    value_added_others = NULL,

    #' @field value_added_matrix (`matrix`)\cr
    #' Aggregates value-added vectors into a matrix.
    value_added_matrix = NULL,

    #' @field occupation (`matrix`)\cr
    #' Occupation vector.
    occupation = NULL,

    #' @field technical_coefficients_matrix (`matrix`)\cr
    #' Technical coefficients matrix.
    technical_coefficients_matrix = NULL,

    #' @field leontief_inverse_matrix (`matrix`)\cr
    #' Leontief inverse matrix.
    leontief_inverse_matrix = NULL,

    #' @field multiplier_output (`data.frame`)\cr
    #' Output multiplier dataframe.
    multiplier_output = NULL,

    #' @field multiplier_employment (`data.frame`)\cr
    #' Employment multiplier dataframe.
    multiplier_employment = NULL,

    #' @field multiplier_taxes (`data.frame`)\cr
    #' Taxes multiplier dataframe.
    multiplier_taxes = NULL,

    #' @field multiplier_wages (`data.frame`)\cr
    #' Wages multiplier dataframe.
    multiplier_wages = NULL,

    #' @field field_influence (`matrix`)\cr
    #' Influence field matrix.
    field_influence = NULL,

    #' @field key_sectors (`data.frame`)\cr
    #' Key sectors dataframe.
    key_sectors = NULL,

    #' @field allocation_coefficients_matrix (`matrix`)\cr
    #' Allocation coefficients matrix.
    allocation_coefficients_matrix = NULL,

    #' @field ghosh_inverse_matrix (`matrix`)\cr
    #' Ghosh inverse matrix.
    ghosh_inverse_matrix = NULL,

    #' @field hypothetical_extraction (`matrix`)\cr
    #' Absolute and relative backward and forward differences in total output after a hypothetical extraction
    hypothetical_extraction = NULL,

    #' @field threads (`integer`)\cr
    #' Number of threads available for Rust to run in parallel
    threads = 0,

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
                          value_added_others = NULL,
                          occupation = NULL,
                          threads = 0) {
      ### assertions ###
      # check class
      for (matrix in private$iom_elements()) {
        if (!is.null(get_var(matrix)) && !is.matrix(get_var(matrix))) {
          cli::cli_h1("Error in matrix class")
          alert(paste("Try coerce", matrix, "to a matrix using as.matrix() function."))
          error(paste(matrix, "must be a matrix."))
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
        if (
          !is.null(get_var(matrix))
          && nrow(get_var(matrix)) != nrow(intermediate_transactions)
        ) {
          cli::cli_h1("Error in matrix dimensions")
          error(
            paste(
              matrix,
              "must have the same number of rows than `intermediate_transactions`,
              which is",
              nrow(intermediate_transactions),
              "rows. But has",
              nrow(get_var(matrix)),
              "rows."
            )
          )
        }
      }

      for (matrix in c(
        "imports",
        "taxes",
        "wages",
        "operating_income",
        "value_added_others",
        "occupation",
        "total_production"
      )) {
        if (!is.null(get_var(matrix)) && ncol(get_var(matrix)) != ncol(intermediate_transactions)) {
          cli::cli_h1("Error in matrix dimensions")
          error(
            paste(
              matrix,
              "must have the same number of columns than `intermediate_transactions`, which is",
              ncol(intermediate_transactions),
              "columns. But",
              matrix,
              "has",
              ncol(get_var(matrix)),
              "columns."
            )
          )
        }
      }

      # check number format
      for (matrix in private$iom_elements()) {
        if (!is.null(get_var(matrix))) {
          # Check if the matrix storage mode is not double
          if (storage.mode(get_var(matrix)) != "double") {
            cli::cli_h1("Error in matrix number format")
            alert(
              paste(
                "Try coerce",
                matrix,
                "elements to double using as.numeric()."
              )
            )
            error(paste(matrix, "elements must be of type double."))
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
      self$value_added_others <- value_added_others
      self$occupation <- set_rownames(occupation)
    },

    #' @description
    #' Adds a `matrix` to the `iom` object.
    #' @param matrix_name (`character`)\cr
    #' One of household_consumption, government_consumption, exports, final_demand_others,
    #' imports, taxes, wages, operating income, value_added_others or occupation matrix to be added.
    #' @param matrix (`matrix`)\cr
    #' Matrix object to be added.
    #' @return
    #' Self (invisibly).
    #' @examples
    #' # data
    #' intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
    #' total_production <- matrix(c(100, 200, 300), 1, 3)
    #' # instantiate iom object
    #' my_iom <- iom$new("mock", intermediate_transactions, total_production)
    #' # Create a dummy matrix
    #' exports_data <- matrix(as.numeric(1:3), 3, 1)
    #' # Add the matrix
    #' my_iom$add("exports", exports_data)
    add = function(matrix_name, matrix) {
      # check arg
      choices <- private$iom_elements()
      if (!matrix_name %in% choices) {
        cli::cli_h1("Error in matrix_name")
        error(paste("matrix_name must be one of", paste(choices, collapse = ", ")))
      }

      # check class
      if (!is.matrix(matrix)) {
        cli::cli_h1("Error in matrix class")
        alert(paste("Try coerce", matrix_name, "to a matrix using as.matrix() function."))
        error(paste(matrix_name, "must be a matrix."))
      }

      # check dimensions
      if (matrix_name %in% c("household_consumption", "government_consumption", "exports", "final_demand_others")) {
        if (nrow(matrix) != nrow(self$intermediate_transactions)) {
          cli::cli_h1("Error in matrix dimensions")
          error(
            paste(
              matrix_name,
              "must have the same number of rows than intermediate_transactions, which is",
              nrow(self$intermediate_transactions),
              "rows. But",
              matrix_name,
              "has",
              nrow(matrix),
              "rows."
            )
          )
        }
      } else {
        if (ncol(matrix) != ncol(self$intermediate_transactions)) {
          cli::cli_h1("Error in matrix dimensions")
          error(
            paste(
              matrix_name,
              "must have the same number of columns than intermediate_transactions, which is",
              ncol(self$intermediate_transactions),
              "columns. But", matrix_name, "has", ncol(matrix), "columns."
            )
          )
        }
      }
      # import matrix
      self[[matrix_name]] <- matrix
      invisible(self)
    },

    #' @description
    #' Removes a `matrix` from the `iom` object.
    #' @param matrix_name (`character`)\cr
    #' One of household_consumption, government_consumption, exports, final_demand_others,
    #' imports, taxes, wages, operating_income, value_added_others or occupation matrix to be removed.
    #' @return Self (invisibly).
    #' @examples
    #' # data
    #' intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
    #' total_production <- matrix(c(100, 200, 300), 1, 3)
    #'  exports_data <- matrix(as.numeric(1:3), 3, 1)
    #' # instantiate iom object
    #' my_iom <- iom$new("mock", intermediate_transactions, total_production, exports = exports_data)
    #' # Remove the matrix
    #' my_iom$remove("exports")
    remove = function(matrix_name) {
      # check arg
      choices <- private$iom_elements()
      if (!matrix_name %in% choices) {
        cli::cli_h1("Error in matrix_name")
        error(paste("matrix_name must be one of", paste(choices, collapse = ", ")))
      }
      # remove matrix
      self[[matrix_name]] <- NULL
      invisible(self)
    },

    #' @description
    #' Aggregates final demand vectors into the `final_demand_matrix` field.
    #' @details
    #' Some methods, as `$compute_hypothetical_extraction()`, require the final demand and value-added vectors
    #' to be aggregated into a matrix. This method does this aggregation, binding the vectors into
    #' `$final_demand_matrix`.
    #' @return
    #' This functions doesn't returns a value.
    #' @examples
    #' # data
    #' intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
    #' total_production <- matrix(c(100, 200, 300), 1, 3)
    #' exports_data <- matrix(c(10, 20, 30), 3, 1)
    #' households <- matrix(as.numeric(4:6), 3, 1)
    #' # instantiate iom object
    #' my_iom <- iom$new(
    #'  "mock",
    #'  intermediate_transactions,
    #'  total_production,
    #'  exports = exports_data,
    #'  household_consumption = households
    #' )
    #' # aggregate all final demand vectors
    #' my_iom$update_final_demand_matrix()
    #' # check final demand matrix
    #' my_iom$final_demand_matrix
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
    #' Aggregates value-added vectors into the `value_added_matrix` field.
    #' @details
    #' Some methods, as `$compute_hypothetical_extraction()`, require the final demand and value-added vectors
    #' to be aggregated into a matrix. This method does this aggregation, binding the vectors into
    #' `$value_added_matrix`.
    #' @return
    #' This functions doesn't returns a value.
    #' @examples
    #' # data
    #' intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
    #' total_production <- matrix(c(100, 200, 300), 1, 3)
    #' imports_data <- matrix(c(5, 10, 15), 1, 3)
    #' taxes_data <- matrix(c(2, 5, 10), 1, 3)
    #' # instantiate iom object
    #' my_iom <- iom$new(
    #' "mock",
    #' intermediate_transactions,
    #' total_production,
    #' imports = imports_data,
    #' taxes = taxes_data
    #' )
    #' # aggregate all value-added vectors
    #' my_iom$update_value_added_matrix()
    #' # check value-added matrix
    #' my_iom$value_added_matrix
    update_value_added_matrix = function() {
      # bind value-added vectors
      self$value_added_matrix <- as.matrix(rbind(
        self$imports,
        self$taxes,
        self$wages,
        self$operating_income,
        self$value_added_others
      ))
    },

    #' @description
    #' Computes the technical coefficients matrix and populate the `technical_coefficients_matrix` field with the
    #' resulting `(matrix)`.
    #' @details
    #' It computes the technical coefficients matrix, a \eqn{n x n} matrix known as `A` matrix which is the column-wise
    #' ratio of intermediate transactions to total production \insertCite{leontief_economia_1983}{fio}.
    #' @return
    #' Self (invisibly).
    #' @references
    #' \insertAllCited{}
    #' @examples
    #' intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
    #' total_production <- matrix(c(100, 200, 300), 1, 3)
    #' # instantiate iom object
    #' my_iom <- iom$new("test", intermediate_transactions, total_production)
    #' # Calculate the technical coefficients
    #' my_iom$compute_tech_coeff()
    #' # show the technical coefficients
    #' my_iom$technical_coefficients_matrix
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
    #' Computes the Leontief inverse matrix and populate the `leontief_inverse_matrix` field with the resulting
    #' `(matrix)`.
    #' @details
    #' It computes the Leontief inverse matrix \insertCite{leontief_economia_1983}{fio}, which is the inverse of the
    #' Leontief matrix, defined as:
    #'
    #' \deqn{L = I - A}
    #'
    #' where I is the identity matrix and A is the technical coefficients matrix.
    #' The Leontief inverse matrix is calculated by solving the following equation:
    #'
    #' \deqn{L^{-1} = (I - A)^{-1}}
    #'
    #' Since the Leontief matrix is a square matrix and the subtraction of the technical coefficients matrix from the
    #' identity matrix guarantees that the Leontief matrix is invertible, underlined Rust function uses LU decomposition
    #' to solve the equation.
    #' @return
    #' Self (invisibly).
    #' @references
    #' \insertAllCited{}
    #' @examples
    #' intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
    #' total_production <- matrix(c(100, 200, 300), 1, 3)
    #' # instantiate iom object
    #' my_iom <- fio::iom$new("test", intermediate_transactions, total_production)
    #' # calculate the technical coefficients
    #' my_iom$compute_tech_coeff()
    #' # calculate the Leontief inverse
    #' my_iom$compute_leontief_inverse()
    #' # show the Leontief inverse
    #' my_iom$leontief_inverse_matrix
    compute_leontief_inverse = function() {
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
    #' Computes the output multiplier and populate the `multiplier_output` field with the resulting `(data.frame)`.
    #' @details
    #' An output multiplier for sector *j* is defined as the total value of production in all sectors of the economy
    #' that is necessary in order to satisfy a monetary unit (e.g., a dollar) worth of final demand for sector *j*'s
    #' output \insertCite{miller_input-output_2009}{fio}.
    #'
    #' This method computes the simple output multiplier, defined as the column sums of the Leontief inverse matrix,
    #' the direct and indirect output multipliers, which are the column sums of the technical
    #' coefficients matrix and the difference between total and direct output multipliers, respectively
    #' \insertCite{vale_alise_2020}{fio}.
    #' @return
    #' Self (invisibly).
    #' @references \insertAllCited{}
    #' @examples
    #' # data
    #' intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
    #' total_production <- matrix(c(100, 200, 300), 1, 3)
    #' # instantiate iom object
    #' my_iom <- fio::iom$new("test", intermediate_transactions, total_production)
    #' # calculate the technical coefficients
    #' my_iom$compute_tech_coeff()
    #' # calculate the Leontief inverse
    #' my_iom$compute_leontief_inverse()
    #' # calculate the output multiplier
    #' my_iom$compute_multiplier_output()
    #' # show the output multiplier
    #' my_iom$multiplier_output
    compute_multiplier_output = function() {
      # check if leontief inverse matrix is available
      if (is.null(self$leontief_inverse_matrix)) {
        cli::cli_h1("Error in leontief_inverse_matrix")
        error("You must compute the leontief inverse matrix first. Run compute_leontief_inverse() method.")
      }
      # save column names
      col_names <- colnames(self$leontief_inverse_matrix)
      # compute output multiplier vector
      multiplier_output_simple <- compute_multiplier_output(
        leontief_inverse_matrix = self$leontief_inverse_matrix
      )
      # compute direct output multiplier vector
      multiplier_output_direct <- compute_multiplier_output_direct(
        technical_coefficients_matrix = self$technical_coefficients_matrix
      )
      # compute indirect output multiplier vector
      multiplier_output_indirect <- compute_multiplier_output_indirect(
        technical_coefficients_matrix = self$technical_coefficients_matrix,
        leontief_inverse_matrix = self$leontief_inverse_matrix
      )

      multiplier_output <- data.frame(
        sector = col_names,
        multiplier_simple = multiplier_output_simple,
        multiplier_direct = multiplier_output_direct,
        multiplier_indirect = multiplier_output_indirect
      )

      # store vector
      self$multiplier_output <- multiplier_output
      invisible(self)
    },

    #' @description
    #' Computes the employment multiplier and populate the `multiplier_employment` field with the resulting
    #' `(data.frame)`.
    #' @details
    #' The employment multiplier for sector *j* relates the jobs created in each sector in response to a
    #' initial exogenous shock \insertCite{miller_input-output_2009}{fio}.
    #'
    #' Current implementation follows \insertCite{vale_alise_2020}{fio}.
    #' @return
    #' Self (invisibly).
    #' @references
    #' \insertAllCited{}
    #' @examples
    #' # data
    #' intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
    #' total_production <- matrix(c(100, 200, 300), 1, 3)
    #' jobs_data <- matrix(c(10, 12, 15), 1, 3)
    #' # instantiate iom object
    #' my_iom <- fio::iom$new("test", intermediate_transactions, total_production, occupation = jobs_data)
    #' # calculate the technical coefficients
    #' my_iom$compute_tech_coeff()
    #' # calculate the Leontief inverse
    #' my_iom$compute_leontief_inverse()
    #' # calculate the employment multiplier
    #' my_iom$compute_multiplier_employment()
    #' # show the employment multiplier
    #' my_iom$multiplier_employment
    compute_multiplier_employment = function() {
      # check if leontief inverse matrix is available
      if (is.null(self$leontief_inverse_matrix)) {
        cli::cli_h1("Error in leontief_inverse_matrix")
        error("You must compute the leontief inverse matrix first. Run compute_leontief_inverse() method.")
      }
      # save column names
      col_names <- colnames(self$leontief_inverse_matrix)
      # compute employment requirements
      employment_requirements <- compute_requirements_value_added(
        value_added_element = self$occupation,
        total_production = self$total_production
      )
      # compute employment multiplier vector
      multiplier_employment_simple <- compute_multiplier_value_added(
        value_added_requirements = employment_requirements,
        leontief_inverse_matrix = self$leontief_inverse_matrix
      )
      # compute indirect employment multiplier
      multiplier_employment_indirect <- compute_multiplier_value_added_indirect(
        value_added_element = self$occupation,
        total_production = self$total_production,
        leontief_inverse_matrix = self$leontief_inverse_matrix
      )

      multiplier_employment <- data.frame(
        sector = col_names,
        multiplier_simple = multiplier_employment_simple,
        multiplier_direct = employment_requirements,
        multiplier_indirect = multiplier_employment_indirect
      )

      # store vector
      self$multiplier_employment <- multiplier_employment
      invisible(self)
    },

    #' @description
    #' Computes the wages multiplier dataframe and populate the `multiplier_wages` field with the resulting
    #' `(data.frame)`.
    #' @details
    #' The wages multiplier for sector *j* relates increases in wages for each
    #' sector in response to a initial exogenous shock
    #' \insertCite{miller_input-output_2009}{fio}.
    #'
    #' Current implementation follows \insertCite{vale_alise_2020}{fio}.
    #' @return
    #' Self (invisibly).
    #' @references
    #' \insertAllCited{}
    #' @examples
    #' # data
    #' intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
    #' total_production <- matrix(c(100, 200, 300), 1, 3)
    #' wages_data <- matrix(c(10, 12, 15), 1, 3)
    #' # instantiate iom object
    #' my_iom <- fio::iom$new("test", intermediate_transactions, total_production, wages = wages_data)
    #' # calculate the technical coefficients
    #' my_iom$compute_tech_coeff()
    #' # calculate the Leontief inverse
    #' my_iom$compute_leontief_inverse()
    #' # calculate the wages multiplier
    #' my_iom$compute_multiplier_wages()
    #' # show the wages multiplier
    #' my_iom$multiplier_wages
    compute_multiplier_wages = function() {
      # check if leontief inverse matrix is available
      if (is.null(self$leontief_inverse_matrix)) {
        cli::cli_h1("Error in leontief_inverse_matrix")
        error("You must compute the leontief inverse matrix first. Run compute_leontief_inverse() method.")
      }
      # save column names
      col_names <- colnames(self$leontief_inverse_matrix)
      # compute wages requirements
      wages_requirements <- compute_requirements_value_added(
        value_added_element = self$wages,
        total_production = self$total_production
      )
      # compute wages multiplier vector
      multiplier_wages_simple <- compute_multiplier_value_added(
        value_added_requirements = wages_requirements,
        leontief_inverse_matrix = self$leontief_inverse_matrix
      )
      # compute indirect wages multiplier
      multiplier_wages_indirect <- compute_multiplier_value_added_indirect(
        value_added_element = self$wages,
        total_production = self$total_production,
        leontief_inverse_matrix = self$leontief_inverse_matrix
      )

      multiplier_wages <- data.frame(
        sector = col_names,
        multiplier_simple = multiplier_wages_simple,
        multiplier_direct = wages_requirements,
        multiplier_indirect = multiplier_wages_indirect
      )

      # store vector
      self$multiplier_wages <- multiplier_wages
      invisible(self)
    },

    #' @description
    #' Computes the taxes multiplier and populate the `multiplier_taxes` field with
    #' the resulting `(data.frame)`.
    #' @details
    #' The taxes multiplier for sector *j* relates the increases on tax revenue from
    #' each sector in response to a initial exogenous shock
    #' \insertCite{miller_input-output_2009}{fio}.
    #'
    #' Current implementation follows \insertCite{vale_alise_2020}{fio}.
    #' @return
    #' Self (invisibly).
    #' @references
    #' \insertAllCited{}
    #' @examples
    #' # data
    #' intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
    #' total_production <- matrix(c(100, 200, 300), 1, 3)
    #' tax_data <- matrix(c(10, 12, 15), 1, 3)
    #' # instantiate iom object
    #' my_iom <- fio::iom$new("test", intermediate_transactions, total_production, taxes = tax_data)
    #' # calculate the technical coefficients
    #' my_iom$compute_tech_coeff()
    #' # calculate the Leontief inverse
    #' my_iom$compute_leontief_inverse()
    #' # calculate the tax multiplier
    #' my_iom$compute_multiplier_taxes()
    #' # show the taxes multiplier
    #' my_iom$multiplier_taxes
    compute_multiplier_taxes = function() {
      # check if leontief inverse matrix is available
      if (is.null(self$leontief_inverse_matrix)) {
        cli::cli_h1("Error in leontief_inverse_matrix")
        error("You must compute the leontief inverse matrix first. Run compute_leontief_inverse() method.")
      }
      # save column names
      col_names <- colnames(self$leontief_inverse_matrix)
      # compute taxes requirements
      taxes_requirements <- compute_requirements_value_added(
        value_added_element = self$taxes,
        total_production = self$total_production
      )
      # compute taxes multiplier vector
      multiplier_taxes_simple <- compute_multiplier_value_added(
        value_added_requirements = taxes_requirements,
        leontief_inverse_matrix = self$leontief_inverse_matrix
      )
      # compute indirect taxes multiplier
      multiplier_taxes_indirect <- compute_multiplier_value_added_indirect(
        value_added_element = self$taxes,
        total_production = self$total_production,
        leontief_inverse_matrix = self$leontief_inverse_matrix
      )

      multiplier_taxes <- data.frame(
        sector = col_names,
        multiplier_simple = multiplier_taxes_simple,
        multiplier_direct = taxes_requirements,
        multiplier_indirect = multiplier_taxes_indirect
      )

      # store vector
      self$multiplier_taxes <- multiplier_taxes
      invisible(self)
    },

    #' @description
    #' Computes the field of influence for all sectors and populate the
    #' `field_influence` field with the resulting `(matrix)`.
    #' @details
    #' The field of influence shows how changes in direct coefficients are
    #' distributed throughout the entire economic system, allowing for the
    #' determination of which relationships between sectors are most important
    #' within the production process.
    #'
    #' It determines which sectors have the greatest influence over others,
    #' specifically, which coefficients, when altered, would have the greatest
    #' impact on the system as a whole \insertCite{vale_alise_2020}{fio}.
    #' @param epsilon (`numeric`)\cr
    #' Epsilon value. A technical change in the input-output matrix, caused by a variation of size `epsilon` into each
    #' element of technical coefficients matrix.
    #' @return
    #' Self (invisibly).
    #' @references
    #' \insertAllCited{}
    #' @examples
    #' # data
    #' intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
    #' total_production <- matrix(c(100, 200, 300), 1, 3)
    #' # instantiate iom object
    #' my_iom <- fio::iom$new("test", intermediate_transactions, total_production)
    #' # calculate the technical coefficients
    #' my_iom$compute_tech_coeff()
    #' # calculate the Leontief inverse
    #' my_iom$compute_leontief_inverse()
    #' # calculate field of influence
    #' my_iom$compute_field_influence(epsilon = 0.01)
    #' # show the field of influence
    #' my_iom$field_influence
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
    #' Computes the key sectors dataframe, based on it's power and sensitivity of dispersion,
    #' and populate the `key_sectors` field with the resulting `(data.frame)`.
    #' @details
    #' Increased production from a sector *j* means that the sector *j* will need to
    #' purchase more goods from other sectors. At the same time, it means that more goods from sector *j* will be
    #' available for other sectors to purchase. Sectors that are above average in the demand sense (stronger backward
    #' linkage) have power of dispersion indices greater than 1. Sectors that are above average in the supply sense
    #' (stronger forward linkage) have sensitivity of dispersion indices greater than 1
    #' \insertCite{miller_input-output_2009}{fio}.
    #'
    #' As both power and sensitivity of dispersion are related to average values on the economy, coefficients of
    #' variation are also calculated for both indices. The lesser the coefficient of variation, greater the number of
    #' sectors on the demand or supply structure of that sector \insertCite{vale_alise_2020}{fio}.
    #' @return
    #' Self (invisibly).
    #' @references
    #' \insertAllCited{}
    #' @examples
    #' # data
    #' intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
    #' total_production <- matrix(c(100, 200, 300), 1, 3)
    #' # instantiate iom object
    #' my_iom <- fio::iom$new("test", intermediate_transactions, total_production)
    #' # calculate the technical coefficients
    #' my_iom$compute_tech_coeff()
    #' # calculate the Leontief inverse
    #' my_iom$compute_leontief_inverse()
    #' # calculate key sectors
    #' my_iom$compute_key_sectors()
    #' # show the key sectors
    #' my_iom$key_sectors
    compute_key_sectors = function() {
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
    #' Computes the allocation coefficients matrix and populate the `allocation_coefficients_matrix` field with the
    #' resulting `(matrix)`.
    #' @details
    #' It computes the allocation coefficients matrix, a \eqn{n x n} matrix known as `B` matrix which is the row-wise
    #' ratio of intermediate transactions to total production \insertCite{miller_input-output_2009}{fio}.
    #' @return
    #' Self (invisibly).
    #' @references
    #' \insertAllCited{}
    #' @examples
    #' intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
    #' total_production <- matrix(c(100, 200, 300), 1, 3)
    #' # instantiate iom object
    #' my_iom <- fio::iom$new("test", intermediate_transactions, total_production)
    #' # Calculate the allocation coefficients
    #' my_iom$compute_allocation_coeff()
    #' # show the allocation coefficients
    #' my_iom$allocation_coefficients_matrix
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
    #' Computes the Ghosh inverse matrix and populate the `ghosh_inverse_matrix` field with the resulting `(matrix)`.
    #' @details
    #' It computes the Ghosh inverse matrix \insertCite{miller_input-output_2009}{fio}, defined as:
    #' \deqn{G = (I - B)^{-1}}
    #' where I is the identity matrix and B is the allocation coefficients matrix.
    #' @return
    #' Self (invisibly).
    #' @references
    #' \insertAllCited{}
    #' @examples
    #' intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
    #' total_production <- matrix(c(100, 200, 300), 1, 3)
    #' # instantiate iom object
    #' my_iom <- fio::iom$new("test", intermediate_transactions, total_production)
    #' # Calculate the allocation coefficients
    #' my_iom$compute_allocation_coeff()
    #' # Calculate the Ghosh inverse
    #' my_iom$compute_ghosh_inverse()
    #' # show the Ghosh inverse
    #' my_iom$ghosh_inverse_matrix
    compute_ghosh_inverse = function() {
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
    #' Computes total impact after extracting a each sector and populate the `hypothetical_extraction` field with the
    #' resulting `(data.frame)`.
    #' @details
    #' Computes impact on demand and supply structures after extracting each
    #' sector \insertCite{miller_input-output_2009}{fio}.
    #'
    #' The total impact is calculated by the sum of the direct and indirect impacts.
    #' @return
    #' Self (invisibly).
    #' @references
    #' \insertAllCited{}
    #' @examples
    #' # data
    #' intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
    #' total_production <- matrix(c(100, 200, 300), 1, 3)
    #' exports_data <- matrix(c(5, 10, 15), 3, 1)
    #' holsehold_consumption_data <- matrix(c(20, 25, 30), 3, 1)
    #' operating_income_data <- matrix(c(2, 5, 10), 1, 3)
    #' taxes_data <- matrix(c(1, 2, 3), 1, 3)
    #' # instantiate iom object
    #' my_iom <- fio::iom$new(
    #'  "test",
    #'  intermediate_transactions,
    #'  total_production,
    #'  exports = exports_data,
    #'  household_consumption = holsehold_consumption_data,
    #'  operating_income = operating_income_data,
    #'  taxes = taxes_data
    #' )
    #' # update value-added matrix
    #' my_iom$update_value_added_matrix()
    #' # update final demand matrix
    #' my_iom$update_final_demand_matrix()
    #' # calculate the technical coefficients
    #' my_iom$compute_tech_coeff()
    #' # calculate the Leontief inverse
    #' my_iom$compute_leontief_inverse()
    #' # calculate allocation coefficients
    #' my_iom$compute_allocation_coeff()
    #' # calculate Ghosh inverse
    #' my_iom$compute_ghosh_inverse()
    #' # calculate hypothetical extraction
    #' my_iom$compute_hypothetical_extraction()
    #' # show results
    #' my_iom$hypothetical_extraction
    compute_hypothetical_extraction = function() {
      # check if arguments are available
      for (matrix_name in c(
        "technical_coefficients_matrix",
        "allocation_coefficients_matrix"
      )) {
        if (is.null(self[[matrix_name]])) {
          cli::cli_h1("Error in {matrix_name}")
          error(paste("You must compute the", matrix_name, "first. Run respective compute_*() method."))
        }
      }
      for (matrix in c(
        "final_demand_matrix",
        "value_added_matrix"
      )) {
        if (is.null(self[[matrix_name]])) {
          cli::cli_h1("Error in {matrix_name}")
          error("You must compute the {matrix_name} first. Run respective update_*() method.")
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
        value_added_matrix = self$value_added_matrix,
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
        "forward_relative",
        "total_absolute",
        "total_relative"
      )
      # store matrix
      self$hypothetical_extraction <- hypothetical_extraction
      invisible(self)
    },

    #' @description
    #' Sets max number of threads used by fio and populate the `threads` field with the resulting `(integer)`.
    #' @param max_threads (`integer`)\cr
    #' Number of threads enabled for parallel computing. Defaults to 0, meaning all
    #' threads available.
    #' @details
    #' Calling this function sets a global limit of threads to Rayon crate, affecting
    #' all computations that runs in parallel by default.
    #'
    #' Default behavior of Rayon is to use all available threads (including logical). Setting to 1 will result in
    #' single threaded (sequential) computations.
    #'
    #' Initialization of the global thread pool happens exactly once. Once started, the configuration cannot be changed
    #' in the current session. If `$set_max_threads()` is called again in the same session, it'll result in an error.
    #'
    #' Methods that deals with linear algebra computations, like `$compute_leontief_inverse()` and
    #' `$compute_ghosh_inverse()`, will try to use all available threads by default, so they also initializes global
    #' thread pool. In order to choose a maximum number of threads other than default, `$set_max_threads()` must be
    #' called before any computation, preferably right after `iom$new()`.
    #' @return
    #' This function does not return a value.
    #' @examples
    #' intermediate_transactions <- matrix(c(1, 2, 3, 4, 5, 6, 7, 8, 9), 3, 3)
    #' total_production <- matrix(c(100, 200, 300), 1, 3)
    #' # instantiate iom object
    #' my_iom <- fio::iom$new("test", intermediate_transactions, total_production)
    #' # to run single threaded (sequential)
    #' my_iom$set_max_threads(1L)
    #' my_iom$threads
    set_max_threads = function(max_threads) {
      # assert type
      if (!(is.integer(max_threads) && max_threads >= 0)) {
        error("max_threads must be a positive integer.")
      }

      if (self$threads == 0 && max_threads == 0) {
        alert("0 means all available threads, which is default behavior. Nothing changed")
      }

      if (self$threads > 0) {
        error("Max threads already been set in this session.")
      } else {
        set_max_threads(max_threads)
        self$threads <- max_threads
      }
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
        "value_added_others",
        "occupation"
      )
    }
  )
)

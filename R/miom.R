#' @title
#' R6 class for multi-regional input-output matrix
#'
#' @description
#' R6 class for multi-regional input-output matrix (MRIO). This class inherits from the
#' `iom` class and extends its functionality to handle multi-regional input-output tables
#' such as the World Input-Output Database (WIOD) and EXIOBASE tables.
#'
#' @param id (`character`)\cr
#' Identifier for the multi-regional input-output matrix.
#' @param intermediate_transactions (`matrix`)\cr
#' Multi-regional intermediate transactions matrix. Rows and columns should follow
#' the structure: Country1_Sector1, Country1_Sector2, ..., Country2_Sector1 etc.
#' @param total_production (`matrix`)\cr
#' Total production vector by country and sector.
#' @param countries (`character`)\cr
#' Vector of region names in the matrix.
#' @param sectors (`character`)\cr
#' Vector of sector names in the matrix.
#' @param household_consumption (`matrix`)\cr
#' Household consumption vector by region and sector.
#' @param government_consumption (`matrix`)\cr
#' Government consumption vector by region and sector.
#' @param exports (`matrix`)\cr
#' Exports vector by region and sector.
#' @param final_demand_others (`matrix`)\cr
#' Other vectors of final demand that doesn't have dedicated slots.
#' @param imports (`matrix`)\cr
#' Imports vector by region and sector.
#' @param taxes (`matrix`)\cr
#' Taxes vector by region and sector.
#' @param wages (`matrix`)\cr
#' Wages vector by region and sector.
#' @param operating_income (`matrix`)\cr
#' Operating income vector by region and sector.
#' @param value_added_others (`matrix`)\cr
#' Other vectors of value-added that doesn't have dedicated slots.
#' @param occupation (`matrix`)\cr
#' Occupation matrix by region and sector.
#'
#' @return A new instance of the `miom` class.
#'
#' @examples
#' # Sample multi-regional data (2 countries, 2 sectors each)
#' countries <- c("BRA", "CHN")
#' sectors <- c("Agriculture", "Manufacturing")
#'
#' # Create country-sector labels
#' labels <- paste(rep(countries, each = 2), rep(sectors, 2), sep = "_")
#'
#' # Sample intermediate transactions matrix (4x4)
#' intermediate_transactions <- matrix(
#'   c(
#'     10, 5, 2, 1,
#'     8, 15, 3, 2,
#'     1, 2, 12, 4,
#'     2, 3, 6, 18
#'   ),
#'   nrow = 4, ncol = 4,
#'   dimnames = list(labels, labels)
#' )
#'
#' # Total production vector
#' total_production <- matrix(c(100, 120, 80, 110),
#'   nrow = 1, ncol = 4,
#'   dimnames = list(NULL, labels)
#' )
#'
#' # Create MIOM instance
#' my_miom <- miom$new(
#'   id = "sample_miom",
#'   intermediate_transactions = intermediate_transactions,
#'   total_production = total_production,
#'   countries = countries,
#'   sectors = sectors
#' )
#'
#' @importFrom Rdpack reprompt
#' @import R6
#' @export

# multi-regional input-output matrix class (inherits from iom)
miom <- R6Class(
  classname = "miom",
  inherit = iom,
  public = list(
    #' @field countries (`character`)\cr
    #' Vector of region names.
    countries = NULL,

    #' @field sectors (`character`)\cr
    #' Vector of sector names.
    sectors = NULL,

    #' @field n_countries (`integer`)\cr
    #' Number of regions in the matrix.
    n_countries = NULL,

    #' @field n_sectors (`integer`)\cr
    #' Number of sectors per country.
    n_sectors = NULL,

    #' @field bilateral_trade (`list`)\cr
    #' Bilateral trade flows between regions by sector.
    bilateral_trade = NULL,

    #' @field domestic_intermediate_transactions (`list`)\cr
    #' List of domestic intermediate transaction matrices by region.
    domestic_intermediate_transactions = NULL,

    #' @field international_intermediate_transactions (`list`)\cr
    #' List of international intermediate transaction matrices between regions.
    international_intermediate_transactions = NULL,

    #' @field multiregional_multipliers (`data.frame`)\cr
    #' Multi-regional output multipliers including intra-regional, inter-regional, and spillover effects.
    multiregional_multipliers = NULL,

    #' @description
    #' Creates a new instance of this [R6][R6::R6Class] class.
    initialize = function(id,
                          intermediate_transactions,
                          total_production,
                          countries,
                          sectors,
                          household_consumption = NULL,
                          government_consumption = NULL,
                          exports = NULL,
                          final_demand_others = NULL,
                          imports = NULL,
                          taxes = NULL,
                          wages = NULL,
                          operating_income = NULL,
                          value_added_others = NULL,
                          occupation = NULL) {
      # Validate multi-regional specific inputs
      if (!is.character(countries) || length(countries) == 0) {
        stop("countries must be a non-empty character vector")
      }
      if (!is.character(sectors) || length(sectors) == 0) {
        stop("sectors must be a non-empty character vector")
      }

      # Set multi-regional specific fields
      self$countries <- countries
      self$sectors <- sectors
      self$n_countries <- length(countries)
      self$n_sectors <- length(sectors)

      # Validate dimensions match countries × sectors
      expected_dim <- self$n_countries * self$n_sectors
      if (nrow(intermediate_transactions) != expected_dim || ncol(intermediate_transactions) != expected_dim) {
        stop(paste0(
          "intermediate_transactions must be a ", expected_dim, "x", expected_dim, " matrix for ",
          self$n_countries, " countries and ", self$n_sectors, " sectors"
        ))
      }

      # Generate country-sector labels if not present
      private$ensure_labels(intermediate_transactions, total_production)

      # Call parent constructor
      super$initialize(
        id = id,
        intermediate_transactions = intermediate_transactions,
        total_production = total_production,
        household_consumption = household_consumption,
        government_consumption = government_consumption,
        exports = exports,
        final_demand_others = final_demand_others,
        imports = imports,
        taxes = taxes,
        wages = wages,
        operating_income = operating_income,
        value_added_others = value_added_others,
        occupation = occupation
      )

      # Decompose into domestic and international transactions
      private$decompose_transactions()
    },

    #' @description
    #' Extract domestic input-output matrix for a specific country.
    #' @param country (`character`)\cr
    #' Country name/code to extract.
    #' @return
    #' An `iom` object for the specified country.
    extract_country = function(country) {
      if (!country %in% self$countries) {
        stop(paste0("Country ", country, " not found in the matrix"))
      }

      # Get indices for this country
      country_idx <- which(self$countries == country)
      sector_indices <- ((country_idx - 1) * self$n_sectors + 1):(country_idx * self$n_sectors)

      # Extract domestic transactions
      domestic_trans <- self$intermediate_transactions[sector_indices, sector_indices]

      # Extract production (ensure it remains a matrix)
      domestic_prod <- matrix(self$total_production[, sector_indices], nrow = 1)
      colnames(domestic_prod) <- colnames(self$total_production)[sector_indices]

      # Extract other matrices if available
      domestic_household <- if (!is.null(self$household_consumption)) {
        self$household_consumption[sector_indices, , drop = FALSE]
      } else {
        NULL
      }
      domestic_government <- if (!is.null(self$government_consumption)) {
        self$government_consumption[sector_indices, , drop = FALSE]
      } else {
        NULL
      }
      domestic_exports <- if (!is.null(self$exports)) {
        self$exports[sector_indices, , drop = FALSE]
      } else {
        NULL
      }
      domestic_imports <- if (!is.null(self$imports)) {
        self$imports[, sector_indices, drop = FALSE]
      } else {
        NULL
      }
      domestic_taxes <- if (!is.null(self$taxes)) {
        self$taxes[, sector_indices, drop = FALSE]
      } else {
        NULL
      }
      domestic_wages <- if (!is.null(self$wages)) {
        self$wages[, sector_indices, drop = FALSE]
      } else {
        NULL
      }
      domestic_operating <- if (!is.null(self$operating_income)) {
        self$operating_income[, sector_indices, drop = FALSE]
      } else {
        NULL
      }
      domestic_occupation <- if (!is.null(self$occupation)) {
        self$occupation[, sector_indices, drop = FALSE]
      } else {
        NULL
      }

      # Create new iom object
      iom$new(
        id = paste0(self$id, "_", country),
        intermediate_transactions = domestic_trans,
        total_production = domestic_prod,
        household_consumption = domestic_household,
        government_consumption = domestic_government,
        exports = domestic_exports,
        imports = domestic_imports,
        taxes = domestic_taxes,
        wages = domestic_wages,
        operating_income = domestic_operating,
        occupation = domestic_occupation
      )
    },

    #' @description
    #' Get bilateral trade flows between two countries by sector.
    #' @param origin_country (`character`)\cr
    #' Origin country name/code.
    #' @param destination_country (`character`)\cr
    #' Destination country name/code.
    #' @return
    #' A matrix of trade flows by sector from origin to destination.
    get_bilateral_trade = function(origin_country, destination_country) {
      if (!origin_country %in% self$countries) {
        stop(paste0("Origin country ", origin_country, " not found"))
      }
      if (!destination_country %in% self$countries) {
        stop(paste0("Destination country ", destination_country, " not found"))
      }

      origin_idx <- which(self$countries == origin_country)
      dest_idx <- which(self$countries == destination_country)

      origin_indices <- ((origin_idx - 1) * self$n_sectors + 1):(origin_idx * self$n_sectors)
      dest_indices <- ((dest_idx - 1) * self$n_sectors + 1):(dest_idx * self$n_sectors)

      trade_matrix <- self$intermediate_transactions[dest_indices, origin_indices]
      rownames(trade_matrix) <- paste(destination_country, self$sectors, sep = "_")
      colnames(trade_matrix) <- paste(origin_country, self$sectors, sep = "_")

      trade_matrix
    },

    #' @description
    #' Get summary statistics by country for multipliers.
    #' @return A data.frame with summary statistics by country.
    get_country_summary = function() {
      if (is.null(self$multiplier_output)) {
        self$compute_multiplier_output()
      }

      # Add country and sector columns if they don't exist
      if (!"country" %in% names(self$multiplier_output)) {
        self$multiplier_output$country <- rep(self$countries, each = self$n_sectors)
        self$multiplier_output$sector_name <- rep(self$sectors, self$n_countries)
      }

      # Calculate country-level aggregates
      country_summary <- aggregate(
        cbind(multiplier_simple, multiplier_direct, multiplier_indirect) ~ country,
        data = self$multiplier_output,
        FUN = function(x) c(mean = mean(x), sum = sum(x), sd = sd(x))
      )

      # Flatten the matrix columns
      result <- data.frame(
        country = country_summary$country,
        multiplier_simple_mean = country_summary$multiplier_simple[, "mean"],
        multiplier_simple_sum = country_summary$multiplier_simple[, "sum"],
        multiplier_simple_sd = country_summary$multiplier_simple[, "sd"],
        multiplier_direct_mean = country_summary$multiplier_direct[, "mean"],
        multiplier_direct_sum = country_summary$multiplier_direct[, "sum"],
        multiplier_direct_sd = country_summary$multiplier_direct[, "sd"],
        multiplier_indirect_mean = country_summary$multiplier_indirect[, "mean"],
        multiplier_indirect_sum = country_summary$multiplier_indirect[, "sum"],
        multiplier_indirect_sd = country_summary$multiplier_indirect[, "sd"],
        stringsAsFactors = FALSE
      )

      result
    },

    #' @description
    #' Override the parent compute_multiplier_output to add country/sector information.
    #' @return Self (invisibly).
    compute_multiplier_output = function() {
      # Call parent method
      super$compute_multiplier_output()

      # Add country and sector information to the result
      if (!is.null(self$multiplier_output)) {
        self$multiplier_output$country <- rep(self$countries, each = self$n_sectors)
        self$multiplier_output$sector_name <- rep(self$sectors, self$n_countries)
      }

      invisible(self)
    },

    #' @description
    #' Override the parent compute_key_sectors to add country/sector information.
    #' @param matrix (`character`)\cr
    #' Which matrix to use for forward linkage computation: "leontief" or "ghosh".
    #' @return Self (invisibly).
    compute_key_sectors = function(matrix = "leontief") {
      # Call parent method
      super$compute_key_sectors(matrix = matrix)

      # Add country and sector information to the result
      if (!is.null(self$key_sectors)) {
        self$key_sectors$country <- rep(self$countries, each = self$n_sectors)
        self$key_sectors$sector_name <- rep(self$sectors, self$n_countries)
      }

      invisible(self)
    },

    #' @description
    #' Compute multi-regional output multipliers following Miller & Blair (2009).
    #' This includes intra-regional, inter-regional, and spillover multipliers.
    #' @return Self (invisibly).
    compute_multiregional_multipliers = function() {
      if (is.null(self$technical_coefficients_matrix)) {
        self$compute_tech_coeff()
      }
      if (is.null(self$leontief_inverse_matrix)) {
        self$compute_leontief_inverse()
      }

      # Initialize storage for results
      multiplier_results <- list()

      # For each country r (destination of the shock)
      for (r in 1:self$n_countries) {
        country_r <- self$countries[r]
        r_indices <- ((r - 1) * self$n_sectors + 1):(r * self$n_sectors)

        # For each sector j in country r
        for (j in 1:self$n_sectors) {
          sector_j <- self$sectors[j]
          col_index <- (r - 1) * self$n_sectors + j

          # Extract column j of country r from Leontief inverse
          leontief_col <- self$leontief_inverse_matrix[, col_index]

          # Intra-regional multiplier (impact within the same region)
          intra_regional <- sum(leontief_col[r_indices])

          # Inter-regional multipliers (spillover to other regions)
          inter_regional <- numeric(self$n_countries)
          names(inter_regional) <- self$countries

          for (s in 1:self$n_countries) {
            s_indices <- ((s - 1) * self$n_sectors + 1):(s * self$n_sectors)
            inter_regional[s] <- sum(leontief_col[s_indices])
          }

          # Total multiplier
          total_multiplier <- sum(leontief_col)

          # Spillover multiplier (total minus intra-regional)
          spillover <- total_multiplier - intra_regional

          # Store results
          result_row <- data.frame(
            destination_country = country_r,
            destination_sector = sector_j,
            destination_label = paste(country_r, sector_j, sep = "_"),
            intra_regional_multiplier = intra_regional,
            spillover_multiplier = spillover,
            total_multiplier = total_multiplier,
            stringsAsFactors = FALSE
          )

          # Add inter-regional multipliers as separate columns
          for (s in 1:self$n_countries) {
            result_row[[paste0("multiplier_to_", self$countries[s])]] <- inter_regional[s]
          }

          multiplier_results[[paste(country_r, sector_j, sep = "_")]] <- result_row
        }
      }

      # Combine all results
      self$multiregional_multipliers <- do.call(rbind, multiplier_results)
      rownames(self$multiregional_multipliers) <- NULL

      invisible(self)
    },

    #' @description
    #' Compute spillover effects matrix showing how shocks in each region-sector
    #' affect output in all other regions. Returns the inter-regional elements
    #' from the Leontief inverse matrix (excluding intra-regional effects).
    #' @return A matrix of spillover effects.
    get_spillover_matrix = function() {
      if (is.null(self$leontief_inverse_matrix)) {
        self$compute_leontief_inverse()
      }


      spillover_matrix <- self$leontief_inverse_matrix

      # Set intra-regional effects to zero
      for (r in 1:self$n_countries) {
        r_indices <- ((r - 1) * self$n_sectors + 1):(r * self$n_sectors)
        spillover_matrix[r_indices, r_indices] <- 0
      }

      spillover_matrix
    },

    #' @description
    #' Compute net spillover effects for each country pair. Net spillover represents
    #' the difference in total spillover effects between country pairs, showing
    #' which country benefits more from economic shocks in the other. Uses the
    #' spillover matrix (Leontief inverse with intra-regional effects set to zero).
    #' @return A matrix showing net spillover effects between countries.
    get_net_spillover_matrix = function() {
      # Get the spillover matrix
      spillover_matrix <- self$get_spillover_matrix()

      # Initialize net spillover matrix
      net_spillover <- matrix(0, nrow = self$n_countries, ncol = self$n_countries)
      rownames(net_spillover) <- self$countries
      colnames(net_spillover) <- self$countries

      # Calculate net spillovers between country pairs
      for (r in 1:self$n_countries) {
        for (s in 1:self$n_countries) {
          if (r != s) {
            # Indices for countries r and s
            r_indices <- ((r - 1) * self$n_sectors + 1):(r * self$n_sectors)
            s_indices <- ((s - 1) * self$n_sectors + 1):(s * self$n_sectors)

            # Total spillover from shocks in country s to country r
            # (sum of spillover matrix elements from s-sectors to r-sectors)
            spillover_s_to_r <- sum(spillover_matrix[r_indices, s_indices])

            # Total spillover from shocks in country r to country s
            # (sum of spillover matrix elements from r-sectors to s-sectors)
            spillover_r_to_s <- sum(spillover_matrix[s_indices, r_indices])

            # Net spillover (positive means r benefits more from shocks in s than vice versa)
            net_spillover[r, s] <- spillover_s_to_r - spillover_r_to_s
          }
        }
      }

      net_spillover
    },

    #' @description
    #' Compute regional self-reliance and interdependence measures.
    #' @return A data.frame with self-reliance and interdependence measures by country.
    get_regional_interdependence = function() {
      if (is.null(self$multiregional_multipliers)) {
        self$compute_multiregional_multipliers()
      }

      interdependence_results <- data.frame(
        country = self$countries,
        self_reliance = numeric(self$n_countries),
        total_spillover_out = numeric(self$n_countries),
        total_spillover_in = numeric(self$n_countries),
        interdependence_index = numeric(self$n_countries),
        stringsAsFactors = FALSE
      )

      for (r in 1:self$n_countries) {
        country_r <- self$countries[r]

        # Self-reliance: average intra-regional multiplier
        self_reliance <- mean(self$multiregional_multipliers[
          self$multiregional_multipliers$destination_country == country_r,
          "intra_regional_multiplier"
        ])

        # Total spillover out: average spillover when this country is shocked
        spillover_out <- mean(self$multiregional_multipliers[
          self$multiregional_multipliers$destination_country == country_r,
          "spillover_multiplier"
        ])

        # Total spillover in: average multiplier effect on this country from other countries
        spillover_in <- mean(sapply(1:self$n_countries, function(s) {
          if (s != r) {
            mean(self$multiregional_multipliers[
              self$multiregional_multipliers$destination_country == self$countries[s],
              paste0("multiplier_to_", country_r)
            ])
          } else {
            0
          }
        }))

        # Interdependence index: ratio of spillover to self-reliance
        interdependence_idx <- spillover_out / self_reliance

        interdependence_results[r, ] <- list(
          country = country_r,
          self_reliance = self_reliance,
          total_spillover_out = spillover_out,
          total_spillover_in = spillover_in,
          interdependence_index = interdependence_idx
        )
      }

      interdependence_results
    }
  ),

  # private members
  private = list(
    ensure_labels = function(intermediate_transactions, total_production) {
      # Generate country-sector labels if not present
      expected_labels <- paste(
        rep(self$countries, each = self$n_sectors),
        rep(self$sectors, self$n_countries),
        sep = "_"
      )

      if (is.null(rownames(intermediate_transactions))) {
        rownames(intermediate_transactions) <- expected_labels
      }
      if (is.null(colnames(intermediate_transactions))) {
        colnames(intermediate_transactions) <- expected_labels
      }
      if (is.null(colnames(total_production))) {
        colnames(total_production) <- expected_labels
      }
    },
    decompose_transactions = function() {
      # Decompose into domestic and international transactions
      self$domestic_intermediate_transactions <- list()
      self$international_intermediate_transactions <- list()

      for (i in 1:self$n_countries) {
        country <- self$countries[i]
        indices_i <- ((i - 1) * self$n_sectors + 1):(i * self$n_sectors)

        # Domestic transactions
        self$domestic_intermediate_transactions[[country]] <- self$intermediate_transactions[indices_i, indices_i]

        # International transactions
        for (j in 1:self$n_countries) {
          if (i != j) {
            country_j <- self$countries[j]
            indices_j <- ((j - 1) * self$n_sectors + 1):(j * self$n_sectors)

            key <- paste(country, "to", country_j, sep = "_")
            self$international_intermediate_transactions[[key]] <-
              self$intermediate_transactions[indices_i, indices_j]
          }
        }
      }
    }
  )
)

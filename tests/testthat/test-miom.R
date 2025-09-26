test_that("miom class can be created and basic methods work", {
  # Sample multi-regional data (2 countries, 2 sectors each)
  countries <- c("USA", "CHN")
  sectors <- c("Agriculture", "Manufacturing")

  # Create country-sector labels
  labels <- paste(rep(countries, each = 2), rep(sectors, 2), sep = "_")

  # Sample intermediate transactions matrix (4x4)
  intermediate_transactions <- matrix(
    c(
      10, 5, 2, 1,
      8, 15, 3, 2,
      1, 2, 12, 4,
      2, 3, 6, 18
    ),
    nrow = 4, ncol = 4,
    dimnames = list(labels, labels)
  )

  # Total production vector
  total_production <- matrix(c(100, 120, 80, 110),
    nrow = 1, ncol = 4,
    dimnames = list(NULL, labels)
  )

  # Create MIOM instance
  my_miom <- miom$new(
    id = "test_miom",
    intermediate_transactions = intermediate_transactions,
    total_production = total_production,
    countries = countries,
    sectors = sectors
  )

  # Test basic properties
  expect_equal(my_miom$id, "test_miom")
  expect_equal(my_miom$countries, countries)
  expect_equal(my_miom$sectors, sectors)
  expect_equal(my_miom$n_countries, 2)
  expect_equal(my_miom$n_sectors, 2)

  # Test technical coefficients computation
  my_miom$compute_tech_coeff()
  expect_false(is.null(my_miom$technical_coefficients_matrix))
  expect_equal(dim(my_miom$technical_coefficients_matrix), c(4, 4))

  # Test Leontief inverse computation
  my_miom$compute_leontief_inverse()
  expect_false(is.null(my_miom$leontief_inverse_matrix))
  expect_equal(dim(my_miom$leontief_inverse_matrix), c(4, 4))

  # Test output multiplier computation
  my_miom$compute_multiplier_output()
  expect_false(is.null(my_miom$multiplier_output))
  expect_equal(nrow(my_miom$multiplier_output), 4)
  expect_true("country" %in% colnames(my_miom$multiplier_output))
  expect_true("sector_name" %in% colnames(my_miom$multiplier_output))
})

test_that("miom bilateral trade extraction works", {
  # Sample multi-regional data
  countries <- c("USA", "CHN")
  sectors <- c("Agriculture", "Manufacturing")
  labels <- paste(rep(countries, each = 2), rep(sectors, 2), sep = "_")

  intermediate_transactions <- matrix(
    c(
      10, 5, 2, 1,
      8, 15, 3, 2,
      1, 2, 12, 4,
      2, 3, 6, 18
    ),
    nrow = 4, ncol = 4,
    dimnames = list(labels, labels)
  )

  total_production <- matrix(c(100, 120, 80, 110),
    nrow = 1, ncol = 4,
    dimnames = list(NULL, labels)
  )

  my_miom <- miom$new(
    id = "test_miom",
    intermediate_transactions = intermediate_transactions,
    total_production = total_production,
    countries = countries,
    sectors = sectors
  )

  # Test bilateral trade extraction
  usa_to_chn <- my_miom$get_bilateral_trade("USA", "CHN")
  expect_equal(dim(usa_to_chn), c(2, 2))
  expect_equal(rownames(usa_to_chn), paste("CHN", sectors, sep = "_"))
  expect_equal(colnames(usa_to_chn), paste("USA", sectors, sep = "_"))
})

test_that("miom country extraction works", {
  # Sample multi-regional data
  countries <- c("USA", "CHN")
  sectors <- c("Agriculture", "Manufacturing")
  labels <- paste(rep(countries, each = 2), rep(sectors, 2), sep = "_")

  intermediate_transactions <- matrix(
    c(
      10, 5, 2, 1,
      8, 15, 3, 2,
      1, 2, 12, 4,
      2, 3, 6, 18
    ),
    nrow = 4, ncol = 4,
    dimnames = list(labels, labels)
  )

  total_production <- matrix(c(100, 120, 80, 110),
    nrow = 1, ncol = 4,
    dimnames = list(NULL, labels)
  )

  my_miom <- miom$new(
    id = "test_miom",
    intermediate_transactions = intermediate_transactions,
    total_production = total_production,
    countries = countries,
    sectors = sectors
  )

  # Test country extraction
  usa_iom <- my_miom$extract_country("USA")
  expect_s3_class(usa_iom, "iom")
  expect_equal(usa_iom$id, "test_miom_USA")
  expect_equal(dim(usa_iom$intermediate_transactions), c(2, 2))
  expect_equal(ncol(usa_iom$total_production), 2)
})

test_that("miom matrix aggregation works", {
  # Sample multi-regional data
  countries <- c("USA", "CHN")
  sectors <- c("Agriculture", "Manufacturing")
  labels <- paste(rep(countries, each = 2), rep(sectors, 2), sep = "_")

  intermediate_transactions <- matrix(
    c(
      10, 5, 2, 1,
      8, 15, 3, 2,
      1, 2, 12, 4,
      2, 3, 6, 18
    ),
    nrow = 4, ncol = 4,
    dimnames = list(labels, labels)
  )

  total_production <- matrix(c(100, 120, 80, 110),
    nrow = 1, ncol = 4,
    dimnames = list(NULL, labels)
  )

  # Add some final demand and value added components
  exports <- matrix(c(10, 15, 5, 8), nrow = 4, ncol = 1)
  imports <- matrix(c(2, 3, 1, 2), nrow = 1, ncol = 4)

  my_miom <- miom$new(
    id = "test_miom",
    intermediate_transactions = intermediate_transactions,
    total_production = total_production,
    countries = countries,
    sectors = sectors,
    exports = exports,
    imports = imports
  )

  # Test matrix aggregation
  my_miom$update_final_demand_matrix()
  my_miom$update_value_added_matrix()

  expect_false(is.null(my_miom$final_demand_matrix))
  expect_false(is.null(my_miom$value_added_matrix))
  expect_equal(nrow(my_miom$final_demand_matrix), 4)
  expect_equal(ncol(my_miom$value_added_matrix), 4)
})

test_that("miom multiregional multipliers work correctly", {
  # Sample multi-regional data
  countries <- c("USA", "CHN")
  sectors <- c("Agriculture", "Manufacturing")
  labels <- paste(rep(countries, each = 2), rep(sectors, 2), sep = "_")

  intermediate_transactions <- matrix(
    c(
      10, 5, 2, 1,
      8, 15, 3, 2,
      1, 2, 12, 4,
      2, 3, 6, 18
    ),
    nrow = 4, ncol = 4,
    dimnames = list(labels, labels)
  )

  total_production <- matrix(c(100, 120, 80, 110),
    nrow = 1, ncol = 4,
    dimnames = list(NULL, labels)
  )

  my_miom <- miom$new(
    id = "test_miom",
    intermediate_transactions = intermediate_transactions,
    total_production = total_production,
    countries = countries,
    sectors = sectors
  )

  # Test multiregional multipliers computation
  my_miom$compute_multiregional_multipliers()
  expect_false(is.null(my_miom$multiregional_multipliers))
  expect_equal(nrow(my_miom$multiregional_multipliers), 4) # 2 countries × 2 sectors

  # Check required columns exist
  expected_cols <- c(
    "destination_country", "destination_sector", "destination_label",
    "intra_regional_multiplier", "spillover_multiplier", "total_multiplier",
    "multiplier_to_USA", "multiplier_to_CHN"
  )
  expect_true(all(expected_cols %in% colnames(my_miom$multiregional_multipliers)))

  # Check that intra-regional + spillover = total
  multipliers <- my_miom$multiregional_multipliers
  expect_equal(
    multipliers$intra_regional_multiplier + multipliers$spillover_multiplier,
    multipliers$total_multiplier,
    tolerance = 1e-10
  )

  # Test spillover matrix
  spillover_matrix <- my_miom$get_spillover_matrix()
  expect_equal(dim(spillover_matrix), c(4, 4))
  expect_equal(rownames(spillover_matrix), labels)
  expect_equal(colnames(spillover_matrix), labels)

  # Test net spillover matrix
  net_spillover <- my_miom$get_net_spillover_matrix()
  expect_equal(dim(net_spillover), c(2, 2))
  expect_equal(rownames(net_spillover), countries)
  expect_equal(colnames(net_spillover), countries)
  expect_equal(as.numeric(diag(net_spillover)), c(0, 0)) # diagonal should be zero

  # Test regional interdependence
  interdependence <- my_miom$get_regional_interdependence()
  expect_equal(nrow(interdependence), 2)
  expect_true(all(c("country", "self_reliance", "total_spillover_out", 
                   "total_spillover_in", "interdependence_index") %in% 
                  colnames(interdependence)))
  expect_equal(interdependence$country, countries)
})

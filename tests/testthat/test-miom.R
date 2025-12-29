test_that("miom initialization validation", {
  # sample data
  countries <- c("A", "B")
  sectors <- c("S1", "S2")
  n_dim <- 4

  # valid inputs
  it <- matrix(1, nrow = n_dim, ncol = n_dim)
  tp <- matrix(1, nrow = 1, ncol = n_dim)

  # wrong dimensions for intermediate_transactions
  expect_error(
    miom$new(
      id = "test",
      intermediate_transactions = matrix(1, nrow = 3, ncol = 3),
      total_production = tp,
      countries = countries,
      sectors = sectors
    ),
    "intermediate_transactions must be a 4x4 matrix"
  )

  # missing countries
  expect_error(miom$new(
    id = "test_miom",
    intermediate_transactions = it,
    total_production = tp,
    countries = 2,
    sectors = sectors
  ), "countries must be a non-empty character vector")

  # Missing sectors
  expect_error(miom$new(
    id = "test_miom",
    intermediate_transactions = it,
    total_production = tp,
    countries = countries,
    sectors = 2
  ), "sectors must be a non-empty character vector")
})

test_that("miom functionality", {
  # two region, two sector example
  countries <- c("R1", "R2")
  sectors <- c("S1", "S2")

  # transactions matrix:
  it <- matrix(c(
    10, 5, 2, 1,
    8, 15, 3, 2,
    1, 2, 12, 4,
    2, 3, 6, 18
  ), nrow = 4, ncol = 4, byrow = TRUE)

  # create labels
  labels <- paste(rep(countries, each = 2), rep(sectors, 2), sep = "_")
  dimnames(it) <- list(labels, labels)

  # total production
  tp <- matrix(c(100, 120, 80, 110), nrow = 1, ncol = 4)
  colnames(tp) <- labels

  my_miom <- miom$new(
    id = "miom_test",
    intermediate_transactions = it,
    total_production = tp,
    countries = countries,
    sectors = sectors
  )

  # basic properties
  expect_equal(my_miom$id, "miom_test")
  expect_equal(my_miom$countries, countries)
  expect_equal(my_miom$sectors, sectors)
  expect_equal(my_miom$n_countries, 2)
  expect_equal(my_miom$n_sectors, 2)

  # bilateral trade
  expect_error(my_miom$get_bilateral_trade("C", "R2"), "Origin country C not found")
  expect_error(my_miom$get_bilateral_trade("R1", "C"), "Destination country C not found")

  # valid trade
  trade_r1_r2 <- my_miom$get_bilateral_trade("R1", "R2")
  # R2 buys from R1: this corresponds to block R2 rows, R1 cols
  # R2 indices: 3, 4. R1 indices: 1, 2.
  # Matrix[3:4, 1:2] ->
  # Row 3 (R2S1): 1, 2
  # Row 4 (R2S2): 2, 3
  expected_trade <- matrix(c(1, 2, 2, 3), nrow = 2, byrow = TRUE)
  expect_equal(trade_r1_r2, expected_trade, ignore_attr = TRUE)

  # multipliers and override
  expect_invisible(my_miom$compute_multiregional_multipliers())
  expect_snapshot(my_miom$multiregional_multipliers)

  # country summary
  summary <- my_miom$get_country_summary()
  expect_snapshot(summary)

  # check that the underlying multiplier_output has the extra columns
  expect_true("country" %in% names(my_miom$multiplier_output))
  expect_true("sector_name" %in% names(my_miom$multiplier_output))
  expect_snapshot(head(my_miom$multiplier_output))

  # key sectors override
  expect_invisible(my_miom$compute_key_sectors())
  expect_true("country" %in% names(my_miom$key_sectors))
  expect_true("sector_name" %in% names(my_miom$key_sectors))
  expect_snapshot(my_miom$key_sectors)

  # regional interdependence
  interdependence <- my_miom$get_regional_interdependence()
  expect_snapshot(interdependence)

  # spillover matrix
  spillover_matrix <- my_miom$get_spillover_matrix()
  expect_snapshot(spillover_matrix)

  # diagonal blocks should be zero
  n_sec <- my_miom$n_sectors
  for (i in 1:my_miom$n_countries) {
    indices <- ((i - 1) * n_sec + 1):(i * n_sec)
    block_sum <- sum(abs(spillover_matrix[indices, indices]))
    expect_equal(block_sum, 0)
  }

  # net spillover
  net_spillover <- my_miom$get_net_spillover_matrix()
  expect_snapshot(net_spillover)
  # check anti-symmetry
  expect_true(max(abs(net_spillover + t(net_spillover))) < 1e-10)

  # extract country
  r1_iom <- my_miom$extract_country("R1")
  expect_s3_class(r1_iom, "iom")
  expect_equal(r1_iom$id, "miom_test_R1")
  expect_error(my_miom$extract_country("HELLO"), "Country HELLO not found in the matrix")

  # check production matches
  expect_equal(as.vector(r1_iom$total_production), c(100, 120))

  # verify we can compute domestic multipliers on extracted object
  r1_iom$compute_tech_coeff()
  r1_iom$compute_leontief_inverse()
  r1_iom$compute_multiplier_output()
  expect_false(is.null(r1_iom$multiplier_output))
})

test_that("miom integration functionality (real data)", {
  # load data
  data("world_2000", package = "fio")
  expect_true(!is.null(world_2000))

  # compute multipliers
  world_2000$compute_multiregional_multipliers()
  multipliers <- world_2000$multiregional_multipliers

  # snapshot check for real data stability
  expect_snapshot(head(multipliers))

  # check consistency: total = intra + spillover
  diffs <- abs(multipliers$total_multiplier - (multipliers$intra_regional_multiplier + multipliers$spillover_multiplier))
  expect_true(all(diffs < 1e-10))

  # smoke checks for other methods
  expect_true(is.data.frame(world_2000$get_regional_interdependence()))
  expect_true(is.matrix(world_2000$get_spillover_matrix()))
  expect_true(is.matrix(world_2000$get_net_spillover_matrix()))
})

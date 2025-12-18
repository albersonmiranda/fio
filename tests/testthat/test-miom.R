# sample multi-regional data (2 countries, 2 sectors each)
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

test_that("miom class can be instantiated", {
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
})

test_that("miom functionality", {
  # Load data
  data("world_2000", package = "fio")
  expect_true(!is.null(world_2000))

  # Compute Multipliers
  world_2000$compute_multiregional_multipliers()
  multipliers <- world_2000$multiregional_multipliers

  expect_false(is.null(multipliers))
  expect_equal(nrow(multipliers), world_2000$n_countries * world_2000$n_sectors)

  # Check consistency: Total = Intra + Spillover
  diffs <- abs(multipliers$total_multiplier - (multipliers$intra_regional_multiplier + multipliers$spillover_multiplier))
  expect_true(all(diffs < 1e-10))

  # Regional Interdependence
  interdependence <- world_2000$get_regional_interdependence()
  expect_equal(nrow(interdependence), world_2000$n_countries)
  expect_true(all(c("self_reliance", "interdependence_index") %in% names(interdependence)))

  # Bilateral Trade
  # BRA to USA
  trade_bra_usa <- world_2000$get_bilateral_trade("BRA", "USA")
  expect_equal(nrow(trade_bra_usa), world_2000$n_sectors)
  expect_equal(ncol(trade_bra_usa), world_2000$n_sectors)
  expect_true(all(grepl("USA", rownames(trade_bra_usa))))
  expect_true(all(grepl("BRA", colnames(trade_bra_usa))))

  # Spillover Matrix
  spillover_matrix <- world_2000$get_spillover_matrix()

  # Diagonal blocks should be zero
  n_sec <- world_2000$n_sectors
  for (i in 1:world_2000$n_countries) {
    indices <- ((i - 1) * n_sec + 1):(i * n_sec)
    block_sum <- sum(abs(spillover_matrix[indices, indices]))
    expect_equal(block_sum, 0)
  }

  # Net Spillover
  net_spillover <- world_2000$get_net_spillover_matrix()
  expect_equal(sum(diag(abs(net_spillover))), 0)
  # Check anti-symmetry
  expect_true(max(abs(net_spillover + t(net_spillover))) < 1e-10)

  # Extract Country
  deu_iom <- world_2000$extract_country("DEU")
  expect_s3_class(deu_iom, "iom")
  expect_equal(deu_iom$id, paste0(world_2000$id, "_DEU"))

  # Check production matches
  deu_idx <- which(world_2000$countries == "DEU")
  indices <- ((deu_idx - 1) * n_sec + 1):(deu_idx * n_sec)
  expect_equal(as.vector(deu_iom$total_production), as.vector(world_2000$total_production[, indices]))

  # Verify we can compute domestic multipliers on extracted object
  deu_iom$compute_tech_coeff()
  deu_iom$compute_leontief_inverse()
  deu_iom$compute_multiplier_output()

  expect_false(is.null(deu_iom$multiplier_output))
})
